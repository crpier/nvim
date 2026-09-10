-- nvim --headless -u NONE -l scripts/test-change-review-hunks.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
package.loaded["config.keymaps"] = { set = function() end }
local review = require "config.change_review"
local hunks = require "config.change_review_hunks"
local root, state = vim.fn.tempname(), vim.fn.tempname()
review.setup { state_dir = state }
vim.fn.mkdir(root, "p")
local function git(...)
  local args = { "git", "-C", root }
  vim.list_extend(args, { ... })
  local result = vim.system(args, { text = true }):wait()
  assert(result.code == 0, result.stderr)
  return result.stdout
end
local function write(path, text)
  vim.fn.writefile(text, root .. "/" .. path)
end
local function eq(a, b)
  assert(vim.deep_equal(a, b), vim.inspect { actual = a, expected = b })
end
local function find(session, path)
  for _, file in ipairs(session.files) do
    if file.path == path then
      return file
    end
  end
  error("Missing file: " .. path)
end
local function open(path)
  vim.cmd.edit(vim.fn.fnameescape(root .. "/" .. path))
end
local ok, err = xpcall(function()
  git("init", "-q")
  git("config", "user.name", "Test")
  git("config", "user.email", "test@example.invalid")
  local base = {}
  for i = 1, 20 do
    base[i] = "line " .. i
  end
  write("edit.txt", base)
  write("delete-lines.txt", { "first", "middle", "last" })
  write("gone.txt", { "deleted content" })
  write("binary.dat", { "before\nNUL" }) -- writefile encodes embedded NL as NUL.
  write("mode.txt", { "unchanged text" })
  write(":(glob)*.txt", { "literal" })
  assert(vim.uv.fs_symlink("edit.txt", root .. "/link"))
  git("add", ".")
  git("commit", "-qm", "baseline")
  base[2], base[3], base[18] = "changed early", "also changed", "changed late"
  write("edit.txt", base)
  write("delete-lines.txt", { "middle" }) -- BOF and EOF deletions share a boundary.
  vim.fn.delete(root .. "/gone.txt")
  write("new file.txt", { "one", "two" })
  write("empty.txt", {})
  write("staged-new.txt", { "staged new" })
  write("binary.dat", { "after\nNUL" })
  vim.uv.fs_chmod(root .. "/mode.txt", 493)
  write(":(glob)*.txt", { "changed literal" })
  assert(vim.uv.fs_unlink(root .. "/link"))
  assert(vim.uv.fs_symlink("mode.txt", root .. "/link"))
  assert(vim.uv.fs_symlink("edit.txt", root .. "/new-link"))
  git("add", "staged-new.txt", "edit.txt")
  -- Additional unstaged edit: review is cumulative against HEAD.
  base[10] = "changed middle"
  write("edit.txt", base)
  open "edit.txt"
  local buf = vim.api.nvim_get_current_buf()
  local session = review.refresh()
  local snapshot = session.snapshot
  local file = find(session, "edit.txt")
  eq(#file.units, 3)
  eq({ hunks.range(file.units[1]) }, { 2, 3 })
  eq({ hunks.range(file.units[2]) }, { 10, 10 })
  eq({ hunks.range(file.units[3]) }, { 18, 18 })
  eq(#find(session, "new file.txt").units, 1)
  eq(#find(session, "staged-new.txt").units, 1)
  eq(#find(session, "empty.txt").units, 1)
  eq(find(session, "binary.dat").whole, true)
  eq(find(session, "binary.dat").preview_only, true)
  eq(find(session, "link").preview_only, true)
  eq(find(session, "new-link").preview_only, true)
  eq(find(session, "mode.txt").whole, true)
  eq(#find(session, ":(glob)*.txt").units, 1)
  eq(find(session, "gone.txt").deleted, true)
  local status, staged = git("status", "--porcelain=v1"), git("diff", "--cached", "--binary")
  local ns = vim.api.nvim_create_namespace "change-review-hunks"
  eq(#vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {}), 3)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  review.toggle() -- No hunk under cursor: silent no-op.
  eq(file.reviewed, false)
  vim.api.nvim_win_set_cursor(0, { 2, 0 })
  review.toggle()
  eq(file.units[1].reviewed, true)
  vim.api.nvim_win_set_cursor(0, { 3, 0 })
  eq(hunks.at(snapshot, buf, 3)[1], file.units[1])
  eq(file.reviewed, false)
  local marks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })
  assert(marks[1][4].virt_text[1][1]:find("[x]", 1, true))
  eq(review.status(), "")
  review.toggle_file(session, file)
  eq(file.reviewed, true)
  review.toggle()
  eq(file.reviewed, false)
  eq(file.units[2].reviewed, true)
  review.add_comment("Retain this comment", 10, 10)
  vim.api.nvim_buf_set_lines(buf, 0, 0, false, { "inserted" })
  review.attach(buf)
  eq({ hunks.range(file.units[2]) }, { 11, 11 })
  eq(file.units[2].reviewed, true)
  eq(pcall(review.rebuild, session), false) -- Failed rebuild leaves progress intact.
  eq(session.snapshot, snapshot)
  vim.cmd "write"
  review.refresh(session)
  eq(session.snapshot, snapshot)
  eq(file.units[2].reviewed, true)
  eq(git("diff", "--cached", "--binary"), staged)
  -- Only the intentional source edit changed Git status; toggles never stage.
  assert(status:find("MM edit.txt", 1, true))
  open "new file.txt"
  vim.api.nvim_win_set_cursor(0, { 2, 0 })
  review.toggle()
  eq(find(session, "new file.txt").reviewed, true)
  eq(review.status(), "[x] Reviewed")
  open "delete-lines.txt"
  review.attach(vim.api.nvim_get_current_buf())
  local matches = hunks.at(snapshot, vim.api.nvim_get_current_buf(), 1)
  eq(#matches, 2)
  local select = vim.ui.select
  vim.ui.select = function(entries, _, callback)
    callback(entries[2])
  end
  review.toggle()
  vim.ui.select = select
  eq(matches[1].reviewed, false)
  eq(matches[2].reviewed, true)
  assert(table.concat(matches[2].preview, "\n"):find("-last", 1, true))
  local historical = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(historical, "diffview://fake/HEAD/edit.txt")
  hunks.attach(snapshot, historical)
  eq(#vim.api.nvim_buf_get_extmarks(historical, ns, 0, -1, {}), 0)
  vim.api.nvim_buf_delete(historical, { force = true })
  -- HEAD changes also wait for an explicit rebuild.
  git("commit", "-qm", "staged changes")
  review.refresh(session)
  eq(session.snapshot, snapshot)
  eq(file.units[2].reviewed, true)
  review.rebuild(session)
  assert(session.snapshot ~= snapshot)
  eq(#session.comments, 1)
  for _, unit in ipairs(session.snapshot.units) do
    eq(unit.reviewed, false)
  end
  eq(pcall(review.toggle_file, session, file), false)
  review.clear(session)
  eq(#vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {}), 0)
end, debug.traceback)
vim.fn.delete(root, "rf")
vim.fn.delete(state, "rf")
if not ok then
  error(err)
end
print "change-review hunk tests passed"
vim.cmd "qa!"
