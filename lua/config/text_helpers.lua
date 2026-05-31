local M = {}

local function line_indent(line)
  local text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
  if text:match "^%s*$" then
    return nil
  end
  return #(text:match "^%s*" or "")
end

function M.indent_last_change(direction)
  local start_mark = vim.api.nvim_buf_get_mark(0, "[")
  local end_mark = vim.api.nvim_buf_get_mark(0, "]")
  if start_mark[1] == 0 or end_mark[1] == 0 then
    vim.notify("No recent changed text marks", vim.log.levels.WARN)
    return
  end

  local command = direction == "<" and "<<" or ">>"
  vim.cmd(string.format("%d,%dnormal! %s", start_mark[1], end_mark[1], command))
end

function M.rest_of_paragraph()
  if vim.fn.mode() ~= "V" then
    vim.cmd.normal { "V", bang = true }
  end

  vim.cmd.normal { "}", bang = true }

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local last_line = vim.api.nvim_buf_line_count(0)
  if cursor_line ~= last_line then
    vim.cmd.normal { "k", bang = true }
  end
end

function M.delete_surrounding_indentation()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local current_indent = line_indent(cursor_line)
  if current_indent == nil then
    vim.notify("Current line is blank", vim.log.levels.WARN)
    return
  end

  local line_count = vim.api.nvim_buf_line_count(0)
  local inner_start = cursor_line
  while inner_start > 1 do
    local previous_indent = line_indent(inner_start - 1)
    if previous_indent ~= nil and previous_indent < current_indent then
      break
    end
    inner_start = inner_start - 1
  end

  local inner_end = cursor_line
  while inner_end < line_count do
    local next_indent = line_indent(inner_end + 1)
    if next_indent ~= nil and next_indent < current_indent then
      break
    end
    inner_end = inner_end + 1
  end

  local start_border = inner_start - 1
  local end_border = inner_end + 1
  if start_border < 1 or end_border > line_count then
    vim.notify("Could not find surrounding indentation borders", vim.log.levels.WARN)
    return
  end

  vim.cmd(string.format("%d,%dnormal! <<", inner_start, inner_end))
  vim.api.nvim_buf_set_lines(0, end_border - 1, end_border, false, {})
  vim.api.nvim_buf_set_lines(0, start_border - 1, start_border, false, {})
end

function M.setup()
  local keymaps = require "config.keymaps"
  local group = "text-helpers"

  keymaps.set({ "o", "x" }, "r", M.rest_of_paragraph, { desc = "Rest of paragraph text object", group = group })
  keymaps.set("n", "dsi", M.delete_surrounding_indentation, { desc = "Delete surrounding indentation", group = group })
  keymaps.set("n", ">p", function()
    M.indent_last_change ">"
  end, { desc = "Indent last change", group = group })
  keymaps.set("n", "<p", function()
    M.indent_last_change "<"
  end, { desc = "Unindent last change", group = group })
end

return M
