local M = {}

local function is_upper(byte)
  return byte ~= nil and byte >= 65 and byte <= 90
end

local function is_lower(byte)
  return byte ~= nil and byte >= 97 and byte <= 122
end

local function is_digit(byte)
  return byte ~= nil and byte >= 48 and byte <= 57
end

local function is_alpha(byte)
  return is_upper(byte) or is_lower(byte)
end

local function is_token_byte(byte)
  return is_alpha(byte) or is_digit(byte) or byte == 95 -- _
end

local function is_separator(byte)
  return byte == 95 -- _
end

local function is_camel_boundary(text, index)
  local prev = text:byte(index - 1)
  local cur = text:byte(index)
  local next_byte = text:byte(index + 1)

  if is_upper(cur) and (is_lower(prev) or is_digit(prev)) then
    return true
  end

  -- XMLParser -> XML | Parser
  if is_upper(prev) and is_upper(cur) and is_lower(next_byte) then
    return true
  end

  return false
end

local function find_token(line, col)
  if line == "" then
    return nil
  end

  col = math.max(1, math.min(col, #line))
  if not is_token_byte(line:byte(col)) then
    if col > 1 and is_token_byte(line:byte(col - 1)) then
      col = col - 1
    else
      return nil
    end
  end

  local start_col = col
  while start_col > 1 and is_token_byte(line:byte(start_col - 1)) do
    start_col = start_col - 1
  end

  local end_col = col
  while end_col < #line and is_token_byte(line:byte(end_col + 1)) do
    end_col = end_col + 1
  end

  return { start_col = start_col, end_col = end_col, text = line:sub(start_col, end_col) }
end

local function add_segment_parts(text, start_col, end_col, parts)
  local part_start = start_col
  for index = start_col + 1, end_col do
    if is_camel_boundary(text, index) then
      table.insert(parts, { start_col = part_start, end_col = index - 1 })
      part_start = index
    end
  end
  table.insert(parts, { start_col = part_start, end_col = end_col })
end

local function parse_parts(text)
  local parts = {}
  local index = 1

  while index <= #text do
    while index <= #text and is_separator(text:byte(index)) do
      index = index + 1
    end
    if index > #text then
      break
    end

    local segment_start = index
    while index <= #text and not is_separator(text:byte(index)) do
      index = index + 1
    end
    add_segment_parts(text, segment_start, index - 1, parts)
  end

  return parts
end

local function part_at(parts, rel_col)
  for _, part in ipairs(parts) do
    if rel_col >= part.start_col and rel_col <= part.end_col then
      return part
    end
  end

  for _, part in ipairs(parts) do
    if rel_col < part.start_col then
      return part
    end
  end

  return parts[#parts]
end

local function expand_around(text, part)
  local start_col = part.start_col
  local end_col = part.end_col

  if is_separator(text:byte(end_col + 1)) then
    while end_col < #text and is_separator(text:byte(end_col + 1)) do
      end_col = end_col + 1
    end
    return start_col, end_col
  end

  if is_separator(text:byte(start_col - 1)) then
    while start_col > 1 and is_separator(text:byte(start_col - 1)) do
      start_col = start_col - 1
    end
  end

  return start_col, end_col
end

function M.range_at(line, cursor_col0, around)
  local token = find_token(line, cursor_col0 + 1)
  if token == nil then
    return nil
  end

  local parts = parse_parts(token.text)
  if #parts == 0 then
    return nil
  end

  local rel_col = math.max(1, math.min(cursor_col0 + 1 - token.start_col + 1, #token.text))
  local part = part_at(parts, rel_col)
  if part == nil then
    return nil
  end

  local start_col = part.start_col
  local end_col = part.end_col
  if around then
    start_col, end_col = expand_around(token.text, part)
  end

  return {
    start_col = token.start_col + start_col - 1,
    end_col = token.start_col + end_col - 1,
  }
end

local function select_range(range)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.cmd "normal! \27"
  vim.api.nvim_win_set_cursor(0, { row, range.start_col - 1 })
  vim.cmd "normal! v"
  vim.api.nvim_win_set_cursor(0, { row, range.end_col - 1 })
end

function M.select(around)
  local row, col0 = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  local range = M.range_at(line, col0, around)

  if range == nil then
    vim.notify("No variable part under cursor", vim.log.levels.WARN)
    return
  end

  select_range(range)
end

function M.setup()
  local keymaps = require "config.keymaps"
  keymaps.set({ "o", "x" }, "is", function()
    M.select(false)
  end, { desc = "Inner variable name part", group = "operators", silent = true })
  keymaps.set({ "o", "x" }, "as", function()
    M.select(true)
  end, { desc = "Around variable name part", group = "operators", silent = true })
end

M._parse_parts = parse_parts
M._find_token = find_token

return M
