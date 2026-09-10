-- nvim --headless -u NONE -l scripts/test-change-review-persistence.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
local root = vim.env.CHANGE_REVIEW_TEST_ROOT
if root then
  package.loaded["config.keymaps"] = { set = function() end }
  local review = require "config.change_review"
  review.setup { state_dir = vim.env.CHANGE_REVIEW_TEST_STATE }
  vim.cmd.edit(vim.fn.fnameescape(root .. "/file.txt"))
  local phase = vim.env.CHANGE_REVIEW_TEST_PHASE
  if phase == "save" then
    review.add_comment("Initial feedback", 2, 2)
    review.add_comment("Resolved feedback", 1, 1, true)
    local select = vim.ui.select
    vim.ui.select = function(items, _, callback)
      if type(items[1]) == "table" then
        callback(items[2])
      else
        callback "Resolve"
      end
    end
    vim.cmd "ChangeReview comments"
    vim.ui.select = select
    vim.cmd "2ChangeReview comment"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Saved feedback" })
    vim.cmd "write"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Unsaved draft" })
    vim.cmd "quit!"
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { "inserted" })
    vim.cmd "write"
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.cmd "ChangeReview toggle"
    assert(review.refresh().snapshot.units[1].reviewed)
  elseif phase == "restore" then
    local ns = vim.api.nvim_create_namespace "change-review"
    local marks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})
    assert(#marks == 1 and marks[1][2] == 2, "Comments did not restore automatically at saved position")
    local session = review.refresh()
    assert(#session.comments == 2)
    for _, unit in ipairs(session.snapshot.units) do
      assert(not unit.reviewed, "Approvals should not persist")
    end
    local text = review.export()
    assert(text:find("Saved feedback", 1, true))
    assert(not text:find("Unsaved draft", 1, true))
    assert(not text:find("Resolved feedback", 1, true))
    vim.cmd "3ChangeReview comment"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
    vim.cmd "xit"
  elseif phase == "deleted" then
    local session = review.refresh()
    assert(#session.comments == 1 and session.comments[1].resolved)
    assert(not review.export():find("Saved feedback", 1, true))
    review.clear(session)
  elseif phase == "cleared" then
    assert(#review.refresh().comments == 0)
  end
  vim.cmd "qa!"
  return
end

root = vim.fn.tempname()
local state = vim.fn.tempname()
vim.fn.mkdir(root, "p")
local function run(args, opts)
  local result = vim.system(args, opts):wait(20000)
  assert(result.code == 0, (result.stdout or "") .. (result.stderr or ""))
end
local ok, err = xpcall(function()
  run { "git", "-C", root, "init", "-q" }
  vim.fn.writefile({ "one", "two", "three" }, root .. "/file.txt")
  run { "git", "-C", root, "add", "." }
  run {
    "git",
    "-C",
    root,
    "-c",
    "user.name=Test",
    "-c",
    "user.email=t@example.invalid",
    "commit",
    "-qm",
    "baseline",
  }
  for _, phase in ipairs { "save", "restore", "deleted", "cleared" } do
    run({ vim.v.progpath, "--headless", "-u", "NONE", "-l", "scripts/test-change-review-persistence.lua" }, {
      text = true,
      env = { CHANGE_REVIEW_TEST_ROOT = root, CHANGE_REVIEW_TEST_STATE = state, CHANGE_REVIEW_TEST_PHASE = phase },
    })
  end
  local store = require "config.change_review_store"
  store.setup { state_dir = state }
  local _, token = store.load(root)
  store.save(root, {}, token)
  -- A stale writer cannot overwrite newer feedback.
  local other = root .. "/other"
  local _, missing = store.load(other)
  store.save(other, {}, missing)
  assert(not pcall(store.save, other, {}, missing))
  -- Corruption fails visibly rather than silently replacing saved feedback.
  local filename = state .. "/" .. vim.fn.sha256(other) .. ".json"
  vim.fn.writefile({ "not json" }, filename)
  assert(not pcall(store.load, other))
  assert(vim.fn.readfile(filename)[1] == "not json")
end, debug.traceback)
vim.fn.delete(root, "rf")
vim.fn.delete(state, "rf")
if not ok then
  error(err)
end
print "change-review persistence tests passed across four Neovim processes"
vim.cmd "qa!"
