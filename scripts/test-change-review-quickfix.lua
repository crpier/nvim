-- nvim --headless -u NONE -l scripts/test-change-review-quickfix.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
package.loaded["config.keymaps"] = { set = function() end }
local review = require "config.change_review"
local qf = require "config.change_review_quickfix"
local root, state = vim.fn.tempname(), vim.fn.tempname()
review.setup { state_dir = state }
vim.fn.mkdir(root, "p")
local function git(...)
  local args = { "git", "-C", root }
  vim.list_extend(args, { ... })
  local result = vim.system(args, { text = true }):wait()
  assert(result.code == 0, result.stderr)
end
local function eq(a, b)
  assert(vim.deep_equal(a, b), vim.inspect { actual = a, expected = b })
end
local function list(id)
  return vim.fn.getqflist { id = id or 0, items = 0, context = 0, idx = 0 }
end
local ok, err = xpcall(function()
  git("init", "-q")
  git("config", "user.name", "Test")
  git("config", "user.email", "test@example.invalid")
  local text = {}
  for i = 1, 12 do
    text[i] = "line " .. i
  end
  vim.fn.writefile(text, root .. "/edit.txt")
  vim.fn.writefile({ "gone forever" }, root .. "/gone.txt")
  git("add", ".")
  git("commit", "-qm", "baseline")
  text[2], text[10] = "early", "late"
  vim.fn.writefile(text, root .. "/edit.txt")
  vim.fn.delete(root .. "/gone.txt")
  vim.fn.writefile({ "new" }, root .. "/new.txt")
  vim.cmd.edit(vim.fn.fnameescape(root .. "/edit.txt"))
  local source = vim.api.nvim_get_current_buf()
  local session = review.refresh()
  local snapshot = session.snapshot
  review.quickfix()
  eq(vim.bo.buftype, "quickfix")
  local initial = list()
  eq(#initial.items, 4)
  eq(initial.items[1].user_data.review_unit, 1)
  eq(initial.items[1].lnum, 2)
  eq(initial.items[2].lnum, 10)
  eq(initial.context.change_review.root, root)
  -- Selection is the quickfix cursor, not the last entry jumped to.
  vim.api.nvim_win_set_cursor(0, { 2, 0 })
  review.toggle()
  eq(snapshot.units[1].reviewed, false)
  eq(snapshot.units[2].reviewed, true)
  assert(list().items[2].text:find("[x]", 1, true))
  eq(vim.api.nvim_win_get_cursor(0)[1], 2)
  vim.cmd "cc 2"
  eq(vim.api.nvim_get_current_buf(), source)
  eq(vim.api.nvim_win_get_cursor(0)[1], 10)
  review.toggle()
  assert(list().items[2].text:find("[ ]", 1, true))
  -- Snapshot previews can toggle the same review entry.
  review.preview_hunk()
  local preview = vim.api.nvim_get_current_buf()
  eq(vim.bo.modifiable, false)
  eq(vim.bo.filetype, "diff")
  assert(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"):find("-line 10", 1, true))
  review.toggle()
  assert(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]:find("[x]", 1, true))
  eq(snapshot.units[2].reviewed, true)
  vim.cmd "close"
  -- Standard quickfix navigation opens deleted content, never a new empty file.
  vim.cmd "cc 3"
  eq(vim.bo.buftype, "nofile")
  eq(vim.bo.modifiable, false)
  assert(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"):find("-gone forever", 1, true))
  review.toggle()
  eq(snapshot.units[3].reviewed, true)
  eq(vim.fn.filereadable(root .. "/gone.txt"), 0)
  -- Another list stays current and unchanged while our hidden list updates.
  vim.fn.setqflist({}, " ", {
    title = "Unrelated",
    items = {
      { filename = root .. "/edit.txt", lnum = 1, text = "compiler result" },
    },
  })
  local other = list()
  vim.cmd "copen"
  review.toggle()
  eq(list(), other) -- Unrelated quickfix does not route into review.
  vim.cmd "cc 1"
  vim.api.nvim_win_set_cursor(0, { 2, 0 })
  review.toggle()
  eq(list(), other)
  assert(list(initial.id).items[1].text:find("[x]", 1, true))
  -- Reopening selects the existing review list, without pushing another list.
  review.quickfix()
  eq(list().id, initial.id)
  vim.cmd "cc 1"
  vim.api.nvim_buf_set_lines(source, 0, 0, false, { "inserted" })
  review.attach(source)
  qf.sync(snapshot)
  eq(list().items[1].lnum, 3)
  eq(list().items[2].lnum, 11)
  assert(list().items[1].text:find("[x]", 1, true))
  vim.cmd "write"
  -- A location list never masquerades as the global review list.
  vim.fn.setloclist(
    0,
    {},
    " ",
    { items = {
      { filename = root .. "/edit.txt", lnum = 3, text = "location result" },
    } }
  )
  vim.cmd "lopen"
  review.toggle()
  eq(snapshot.units[1].reviewed, true)
  vim.cmd "lclose"
  review.rebuild(session)
  assert(session.snapshot.id ~= snapshot.id)
  eq(list().id, initial.id)
  eq(list().context.change_review.snapshot, session.snapshot.id)
  for _, unit in ipairs(session.snapshot.units) do
    eq(unit.reviewed, false)
  end
  eq(list(other.id).items[1].text, "compiler result")
  -- Old previews cannot approve a hunk with a reused numeric ID.
  vim.api.nvim_set_current_buf(preview)
  review.toggle()
  for _, unit in ipairs(session.snapshot.units) do
    eq(unit.reviewed, false)
  end
  review.clear(session)
  eq(#list(initial.id).items, 0)
end, debug.traceback)
vim.fn.delete(root, "rf")
vim.fn.delete(state, "rf")
if not ok then
  error(err)
end
print "change-review quickfix tests passed"
vim.cmd "qa!"
