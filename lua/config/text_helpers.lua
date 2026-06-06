local M = {}

local function line_indent(line)
  local text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
  if text:match "^%s*$" then
    return nil
  end
  return #(text:match "^%s*" or "")
end

local function line_text(line)
  return vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
end

local function line_end_col(line)
  return #line_text(line) + 1
end

local function line_last_col(line)
  return math.max(#line_text(line), 1)
end

local function line_first_non_blank_col(line)
  return line_text(line):find "%S"
end

local function position_before_or_equal(a, b)
  return a.line < b.line or (a.line == b.line and a.col <= b.col)
end

local function position_after_or_equal(a, b)
  return a.line > b.line or (a.line == b.line and a.col >= b.col)
end

local function position_before(a, b)
  return a.line < b.line or (a.line == b.line and a.col < b.col)
end

local function is_escaped(text, col)
  local backslashes = 0
  local index = col - 1
  while index >= 1 and text:sub(index, index) == "\\" do
    backslashes = backslashes + 1
    index = index - 1
  end
  return backslashes % 2 == 1
end

local function triple_quote_positions()
  local positions = {}
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for line_number, text in ipairs(lines) do
    local index = 1
    while index <= #text - 2 do
      local token = text:sub(index, index + 2)
      if (token == [["""]] or token == "'''") and not is_escaped(text, index) then
        table.insert(positions, { line = line_number, col = index, quote = token })
        index = index + 3
      else
        index = index + 1
      end
    end
  end
  return positions
end

local function containing_triple_quote_pair()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_pos = { line = cursor[1], col = cursor[2] + 1 }
  local open = nil

  for _, position in ipairs(triple_quote_positions()) do
    if open == nil then
      open = position
    elseif open.quote == position.quote then
      local close = position
      local close_end = { line = close.line, col = close.col + 2 }
      if position_before_or_equal(open, cursor_pos) and position_after_or_equal(close_end, cursor_pos) then
        return open, close
      end
      open = nil
    end
  end

  return nil, nil
end

local function select_range(start_pos, end_pos, from_visual_mode)
  if not position_before_or_equal(start_pos, end_pos) then
    vim.notify("Docstring is empty", vim.log.levels.WARN)
    return
  end

  if from_visual_mode then
    vim.fn.setpos("'<", { 0, start_pos.line, start_pos.col, 0 })
    vim.fn.setpos("'>", { 0, end_pos.line, end_pos.col, 0 })
    vim.cmd "normal! gv"
    return
  end

  vim.api.nvim_win_set_cursor(0, { start_pos.line, start_pos.col - 1 })
  vim.cmd "normal! v"
  vim.api.nvim_win_set_cursor(0, { end_pos.line, end_pos.col - 1 })
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

--- Select the current line as a characterwise text object, excluding the newline.
---
--- When `include_indentation` is false, selection starts at the first non-space
--- character. Otherwise, selection starts at column 1.
---
---@param include_indentation boolean Include leading whitespace in the selection.
---@param from_visual_mode boolean Re-select via visual marks instead of starting a new operator-pending selection.
function M.select_line(include_indentation, from_visual_mode)
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local text = line_text(line)
  if text == "" then
    vim.notify("Line is empty", vim.log.levels.WARN)
    return
  end

  local start_col = 1
  if not include_indentation then
    start_col = line_first_non_blank_col(line)
    if start_col == nil then
      vim.notify("Line has no non-space characters", vim.log.levels.WARN)
      return
    end
  end

  select_range({ line = line, col = start_col }, { line = line, col = #text }, from_visual_mode)
end

function M.select_python_docstring(include_delimiters, from_visual_mode)
  local open, close = containing_triple_quote_pair()
  if open == nil or close == nil then
    vim.notify("No containing Python docstring", vim.log.levels.WARN)
    return
  end

  if include_delimiters then
    select_range(open, { line = close.line, col = close.col + 2 }, from_visual_mode)
    return
  end

  local start_pos = { line = open.line, col = open.col + 3 }
  local end_pos = { line = close.line, col = close.col - 1 }

  if open.line ~= close.line then
    local open_suffix = line_text(open.line):sub(start_pos.col)
    local close_prefix = line_text(close.line):sub(1, close.col - 1)
    if start_pos.col >= line_end_col(start_pos.line) or open_suffix:match "^%s*$" then
      start_pos = { line = start_pos.line + 1, col = 1 }
    end
    if end_pos.col < 1 or close_prefix:match "^%s*$" then
      local previous_line = end_pos.line - 1
      end_pos = { line = previous_line, col = line_last_col(previous_line) }
    end
  end

  if position_before(close, start_pos) or position_before(end_pos, open) then
    vim.notify("Docstring is empty", vim.log.levels.WARN)
    return
  end

  select_range(start_pos, end_pos, from_visual_mode)
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
  keymaps.set("o", "a_", function()
    M.select_line(true, false)
  end, { desc = "Around line text object", group = group })
  keymaps.set("o", "i_", function()
    M.select_line(false, false)
  end, { desc = "Inside line text object", group = group })
  keymaps.set("x", "a_", function()
    M.select_line(true, true)
  end, { desc = "Around line text object", group = group })
  keymaps.set("x", "i_", function()
    M.select_line(false, true)
  end, { desc = "Inside line text object", group = group })
  keymaps.set("o", "ay", function()
    M.select_python_docstring(true, false)
  end, { desc = "Around Python docstring", group = group })
  keymaps.set("o", "iy", function()
    M.select_python_docstring(false, false)
  end, { desc = "Inside Python docstring", group = group })
  keymaps.set("x", "ay", function()
    M.select_python_docstring(true, true)
  end, { desc = "Around Python docstring", group = group })
  keymaps.set("x", "iy", function()
    M.select_python_docstring(false, true)
  end, { desc = "Inside Python docstring", group = group })
  keymaps.set("n", "dsi", M.delete_surrounding_indentation, { desc = "Delete surrounding indentation", group = group })
  keymaps.set("n", ">p", function()
    M.indent_last_change ">"
  end, { desc = "Indent last change", group = group })
  keymaps.set("n", "<p", function()
    M.indent_last_change "<"
  end, { desc = "Unindent last change", group = group })
end

return M
