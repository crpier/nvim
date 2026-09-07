-- Run from the config root: nvim --headless -u NONE -l scripts/test-change-review.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
package.loaded["config.keymaps"] = {
  set = function(mode, lhs, rhs, opts)
    opts = vim.deepcopy(opts)
    opts.group = nil
    vim.keymap.set(mode, lhs, rhs, opts)
  end,
}
local review = require "config.change_review"
local state_dir = vim.fn.tempname()
review.setup { state_dir = state_dir }
local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")
local function git(...)
  local args = { "git", "-C", root }
  vim.list_extend(args, { ... })
  local result = vim.system(args, { text = true }):wait()
  assert(result.code == 0, result.stderr)
  return result.stdout
end
local function write(path, lines)
  vim.fn.writefile(lines, root .. "/" .. path)
end
local function eq(actual, expected)
  assert(vim.deep_equal(actual, expected), vim.inspect { actual = actual, expected = expected })
end
local function file(session, path)
  for _, entry in ipairs(session.files) do
    if entry.path == path then
      return entry
    end
  end
  error("Missing file " .. path)
end
local ok, err = xpcall(function()
  git("init", "-q")
  git("config", "user.name", "Review Test")
  git("config", "user.email", "review@example.invalid")
  write("edited.txt", { "one", "two", "three" })
  write("deleted.txt", { "gone" })
  write("staged.txt", { "before" })
  write(".gitignore", { "ignored.txt" })
  git("add", ".")
  git("commit", "-qm", "baseline")
  write("edited.txt", { "one", "changed", "three" })
  write("new file.txt", { "new" })
  write("ignored.txt", { "ignored" })
  write("staged.txt", { "after" })
  git("add", "staged.txt")
  vim.fn.delete(root .. "/deleted.txt")
  vim.cmd.edit(vim.fn.fnameescape(root .. "/edited.txt"))
  local session = review.refresh()
  local diff_args
  vim.api.nvim_create_user_command("DiffviewOpen", function(opts)
    diff_args = opts.fargs
  end, { nargs = "*" })
  vim.cmd "ChangeReview open"
  eq(diff_args, {}) -- Main entry point behaves exactly like plain :DiffviewOpen.
  eq(#session.files, 4)
  eq(file(session, "deleted.txt").deleted, true)
  local staged_before = git("diff", "--cached", "--binary")
  local status_before = git("status", "--porcelain=v1")
  review.toggle_file(session, file(session, "edited.txt"))
  review.refresh(session)
  eq(file(session, "edited.txt").reviewed, true)
  review.toggle_file(session, file(session, "edited.txt"))
  review.refresh(session)
  eq(file(session, "edited.txt").reviewed, false)
  review.toggle_file(session, file(session, "edited.txt"))
  review.toggle_file(session, file(session, "staged.txt"))
  review.toggle_file(session, file(session, "deleted.txt"))
  eq(git("diff", "--cached", "--binary"), staged_before)
  eq(git("status", "--porcelain=v1"), status_before)

  local c = review.add_comment("Please simplify this.\nKeep the error handling.", 2, 2)
  local ns = vim.api.nvim_create_namespace "change-review"
  local mark = vim.api.nvim_buf_get_extmark_by_id(0, ns, c.mark, { details = true })[3]
  eq(mark.virt_lines[2][1][1], "│ Please simplify this.")
  eq(mark.virt_lines[3][1][1], "│ Keep the error handling.")
  eq(mark.virt_text, nil)
  -- The same range opens the existing comment, not an empty new one.
  vim.cmd "2ChangeReview comment"
  eq(vim.api.nvim_win_get_config(0).title[1][1], " Line review · edited.txt:2 ")
  eq(vim.api.nvim_buf_get_lines(0, 0, -1, false), { "Please simplify this.", "Keep the error handling." })
  vim.api.nvim_win_close(0, true)
  eq(#session.comments, 1)
  vim.cmd "1,3ChangeReview comment"
  eq(vim.api.nvim_win_get_config(0).title[1][1], " Hunk/range review · edited.txt:1-3 ")
  vim.cmd "quit"
  local text = review.export(session)
  assert(text:find("Address these comments within the current work part. Don't commit or expand scope.", 1, true))
  local setreg = vim.fn.setreg
  local copied
  vim.fn.setreg = function(register, value)
    eq(register, "+")
    copied = value
  end
  local window = vim.api.nvim_get_current_win()
  local windows = #vim.api.nvim_list_wins()
  vim.cmd "ChangeReview copy"
  vim.fn.setreg = setreg
  eq(copied, text)
  eq(vim.api.nvim_get_current_win(), window)
  eq(#vim.api.nvim_list_wins(), windows)
  eq(#session.comments, 1)
  vim.cmd "ChangeReview refresh" -- Works without Diffview loaded.
  local diff_refreshes = 0
  vim.api.nvim_create_user_command("DiffviewRefresh", function()
    diff_refreshes = diff_refreshes + 1
  end, {})
  vim.cmd "ChangeReview refresh"
  eq(diff_refreshes, 1)
  eq(#session.comments, 1)
  eq(review.export(session), text)
  assert(text:find("edited.txt", 1, true))
  assert(text:find("    changed", 1, true))
  eq(review.export(session), text) -- Export never consumes comments.
  vim.api.nvim_buf_set_lines(0, 0, 0, false, { "inserted" })
  assert(review.export(session):find("3-3", 1, true))
  assert(not review.export(session):find("Location needs checking", 1, true))
  eq(pcall(review.toggle_file, session, file(session, "edited.txt")), false)
  vim.api.nvim_buf_set_lines(0, 2, 3, false, { "rewritten" })
  assert(review.export(session):find("Location needs checking", 1, true))
  assert(review.export(session):find("    changed", 1, true))
  vim.cmd.write()
  review.refresh(session)
  eq(file(session, "edited.txt").reviewed, false)
  eq(file(session, "staged.txt").reviewed, true)
  eq(#session.comments, 1)
  eq(c.text, "Please simplify this.\nKeep the error handling.")

  local fc = review.add_comment("Consider splitting this file.", 1, 1, true)
  eq(fc.file_level, true)
  eq(vim.fn.maparg("]n", "n"):lower(), "<cmd>changereview next<cr>")
  eq(vim.fn.maparg("[n", "n"):lower(), "<cmd>changereview prev<cr>")
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.cmd "ChangeReview next"
  eq(vim.api.nvim_win_get_cursor(0)[1], 3)
  vim.cmd "ChangeReview next"
  eq(vim.api.nvim_win_get_cursor(0)[1], 4) -- File-level comment at EOF.
  vim.cmd "ChangeReview next"
  eq(vim.api.nvim_win_get_cursor(0)[1], 3) -- Wrap forward.
  vim.cmd "ChangeReview prev"
  eq(vim.api.nvim_win_get_cursor(0)[1], 4) -- Wrap backward.
  c.resolved = true
  vim.cmd "ChangeReview prev"
  eq(vim.api.nvim_win_get_cursor(0)[1], 4) -- Resolved comments are skipped.
  c.resolved = false
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  local function file_comment_row()
    return vim.api.nvim_buf_get_extmark_by_id(0, ns, fc.mark, {})[1]
  end
  eq(file_comment_row(), vim.api.nvim_buf_line_count(0) - 1)
  vim.api.nvim_buf_set_lines(0, -1, -1, false, { "appended" })
  review.attach(vim.api.nvim_get_current_buf())
  eq(file_comment_row(), vim.api.nvim_buf_line_count(0) - 1)
  vim.api.nvim_buf_set_lines(0, -2, -1, false, {})
  review.attach(vim.api.nvim_get_current_buf())
  eq(file_comment_row(), vim.api.nvim_buf_line_count(0) - 1)
  vim.cmd.write()
  assert(review.export(session):find("· file", 1, true))
  vim.cmd "ChangeReview file-comment"
  local draft = vim.api.nvim_get_current_buf()
  eq(vim.api.nvim_win_get_config(0).title[1][1], " File review · edited.txt ")
  eq(vim.bo[draft].buftype, "acwrite")
  vim.api.nvim_buf_set_lines(draft, 0, -1, false, { "Saved feedback" })
  vim.cmd "write"
  eq(vim.api.nvim_get_current_buf(), draft) -- :w does not close the editor.
  eq(fc.text, "Saved feedback")
  eq(vim.bo[draft].modified, false)
  vim.api.nvim_buf_set_lines(draft, 0, -1, false, { "Unsaved feedback" })
  vim.cmd "quit!"
  eq(fc.text, "Saved feedback")
  vim.cmd "ChangeReview file-comment"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Saved with x" })
  vim.cmd "xit"
  eq(fc.text, "Saved with x")
  vim.cmd "ChangeReview file-comment"
  vim.cmd "quit" -- Unchanged editors close normally.

  vim.cmd "1ChangeReview comment"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "New draft" })
  vim.cmd "write"
  local count = #session.comments
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Updated draft" })
  vim.cmd "xit"
  eq(#session.comments, count) -- Repeated saves update rather than duplicate.
  eq(session.comments[count].text, "Updated draft")
  local added = session.comments[count]
  local source_buf = vim.api.nvim_get_current_buf()
  vim.cmd "1ChangeReview comment"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
  vim.cmd "quit!"
  eq(#session.comments, count) -- Unsaved deletion changes nothing.
  vim.cmd "1ChangeReview comment"
  local old_mark = added.mark
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "  ", "\t" })
  vim.cmd "write"
  eq(#session.comments, count - 1)
  eq(vim.api.nvim_buf_get_extmark_by_id(source_buf, ns, old_mark, {}), {})
  assert(not review.export(session):find("Updated draft", 1, true))
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Restored draft" })
  vim.cmd "write"
  eq(#session.comments, count)
  eq(session.comments[count], added)
  eq(added.text, "Restored draft")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
  vim.cmd "xit"
  eq(#session.comments, count - 1)
  vim.cmd "1ChangeReview comment"
  vim.cmd "write" -- Saving an empty new draft is a no-op.
  vim.cmd "quit"
  eq(#session.comments, count - 1)
  vim.cmd "ChangeReview file-comment"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
  vim.cmd "xit"
  assert(not review.export(session):find("Saved with x", 1, true))
  c.resolved = true
  assert(not review.export(session):find("Please simplify", 1, true))
  c.resolved = false

  -- Stale picker selections cannot approve a newer version.
  local old = file(session, "new file.txt")
  write("new file.txt", { "different" })
  eq(pcall(review.toggle_file, session, old), false)

  -- Missing files retain feedback, with original context.
  local original_buf = vim.api.nvim_get_current_buf()
  vim.cmd.enew()
  vim.api.nvim_buf_delete(original_buf, { force = true })
  vim.fn.delete(root .. "/edited.txt")
  assert(review.export(session):find("Location needs checking", 1, true))
  assert(review.export(session):find("Please simplify", 1, true))

  -- Historical/scratch buffers must never be mistaken for working files.
  vim.api.nvim_buf_set_name(0, "diffview:///tmp/fake/.git/abcdef/edited.txt")
  eq(pcall(review.add_comment, "Wrong side", 1, 1), false)

  -- Sessions are isolated by repository, not whichever cwd happens to be active.
  local other = vim.fn.tempname()
  vim.fn.mkdir(other, "p")
  assert(vim.system({ "git", "-C", other, "init", "-q" }):wait().code == 0)
  vim.cmd.enew()
  vim.api.nvim_buf_set_name(0, other .. "/other.txt")
  review.add_comment("Separate repo", 1, 1, true)
  assert(not review.export():find("Please simplify", 1, true))
  assert(not review.export(session):find("Separate repo", 1, true))
  vim.fn.delete(other, "rf")
  review.clear(session)
end, debug.traceback)
vim.fn.delete(root, "rf")
vim.fn.delete(state_dir, "rf")
if not ok then
  error(err)
end
print "change-review tests passed"
vim.cmd "qa!"
