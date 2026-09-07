-- Run after startup for screen-row assertions; see docs/change-review.md.
-- Do not use -l: it can run before Neovim has initialized its screen grid.
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.o.columns = 140
vim.o.lines = 45
vim.o.diffopt = "internal,filler,closeoff,linematch:60"
local source_ns = vim.api.nvim_create_namespace "change-review"
local padding_ns = vim.api.nvim_create_namespace "change-review-padding"
local padding = require "config.change_review_padding"

local function check(old_lines, new_lines, anchor, old_tail, new_tail)
  vim.cmd "silent only!"
  local left = vim.api.nvim_get_current_win()
  local old = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(left, old)
  vim.api.nvim_buf_set_lines(old, 0, -1, false, old_lines)
  vim.cmd "rightbelow vnew"
  local right = vim.api.nvim_get_current_win()
  local new = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(new, 0, -1, false, new_lines)
  for _, win in ipairs { left, right } do
    vim.api.nvim_win_call(win, function()
      vim.cmd "diffthis"
      vim.wo.foldenable = false
      vim.wo.wrap = false
    end)
  end
  vim.cmd "diffupdate"
  local mark = vim.api.nvim_buf_set_extmark(new, source_ns, anchor - 1, 0, {
    virt_lines = { { { "Review", "Normal" } }, { { "Feedback", "Normal" } }, { { "End", "Normal" } } },
  })
  padding.refresh(source_ns)
  padding.refresh(source_ns) -- Idempotent; no accumulated blank rows.
  local mirrors = vim.api.nvim_buf_get_extmarks(old, padding_ns, 0, -1, { details = true })
  assert(#mirrors == 1, vim.inspect(mirrors))
  assert(#mirrors[1][4].virt_lines == 3)
  vim.cmd "redraw"
  local old_row = vim.fn.screenpos(left, old_tail, 1).row
  local new_row = vim.fn.screenpos(right, new_tail, 1).row
  assert(old_row > 0 and old_row == new_row, vim.inspect { old_row = old_row, new_row = new_row, anchor = anchor })
  vim.api.nvim_buf_del_extmark(new, source_ns, mark)
  padding.refresh(source_ns)
  assert(#vim.api.nvim_buf_get_extmarks(old, padding_ns, 0, -1, {}) == 0)
  vim.api.nvim_win_call(left, function()
    vim.cmd "diffoff"
  end)
  vim.api.nvim_win_call(right, function()
    vim.cmd "diffoff"
  end)
end

check({ "a", "old", "z" }, { "a", "new", "z" }, 2, 3, 3)
check({ "a", "z" }, { "a", "added", "z" }, 2, 2, 3)
check({ "a", "z" }, { "added", "a", "z" }, 1, 2, 3)
check({ "a", "removed", "same", "z" }, { "a", "same", "z" }, 2, 4, 3)
print "change-review padding tests passed"
vim.cmd "qa!"
