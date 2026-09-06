-- Tabout: <Tab> jumps past the nearest closing pair, <S-Tab> jumps back.
-- Ported from kawre/neotab.nvim (AGPL-3): plain string scanning, no treesitter.
-- Skipped: logging, luasnip integration, smart_punctuators, toggle.

local M = {}

-- Config -------------------------------------------------------------------

local pairs_list = {
  { open = "(", close = ")" },
  { open = "[", close = "]" },
  { open = "{", close = "}" },
  { open = "'", close = "'" },
  { open = '"', close = '"' },
  { open = "`", close = "`" },
  { open = "<", close = ">" },
}

-- "nested": prefer valid nested pairs; "closing": prefer the closing pair
local behavior = "nested"

local exclude = {} ---@type string[] filetypes where tabout is disabled

-- Scan helpers ---------------------------------------------------------------

local function get_pair(char)
  if not char then
    return nil
  end
  for _, p in ipairs(pairs_list) do
    if p.open == char or p.close == char then
      return p
    end
  end
end

local function find_opening(info, line, col)
  if info.open == info.close then
    local idx = line:sub(1, col):reverse():find(info.open, 1, true)
    return idx and (#line - idx)
  end

  local depth = 1
  for i = col, 1, -1 do
    local char = line:sub(i, i)
    if char == info.open then
      depth = depth - 1
    elseif char == info.close then
      depth = depth + 1
    end
    if depth == 0 then
      return i
    end
  end
end

local function find_closing(info, line, col)
  if info.open == info.close then
    return line:find(info.close, col + 1, true)
  end

  local depth = 1
  for i = col + 1, #line do
    local char = line:sub(i, i)
    if char == info.open then
      depth = depth + 1
    elseif char == info.close then
      depth = depth - 1
    end
    if depth == 0 then
      return i
    end
  end
end

-- Is there a complete pair of `info` in line[l..r]?
local function valid_pair(info, line, l, r)
  if info.open == info.close and line:sub(l, r):find(info.open, 1, true) then
    return true
  end

  local depth = 1
  for i = l, r do
    local char = line:sub(i, i)
    if char == info.open then
      depth = depth + 1
    elseif char == info.close then
      depth = depth - 1
    end
    if depth == 0 then
      return true
    end
  end
  return false
end

-- Same, but scanning as if moving leftwards (mirrored depth signs)
local function valid_pair_rev(info, line, l, r)
  if info.open == info.close and line:sub(l, r):find(info.open, 1, true) then
    return true
  end

  local depth = 1
  for i = l, r do
    local char = line:sub(i, i)
    if char == info.open then
      depth = depth - 1
    elseif char == info.close then
      depth = depth + 1
    end
    if depth == 0 then
      return true
    end
  end
  return false
end

-- Forward target: next pair char at/after `col`, respecting nesting
local function find_next_nested(info, line, col)
  local char = line:sub(col - 1, col - 1)

  if info.open == info.close or info.close == char then
    for i = col, #line do
      char = line:sub(i, i)
      if get_pair(char) then
        return i
      end
    end
  else
    local closing_idx = find_closing(info, line, col - 1)
    local r = closing_idx or #line
    local first

    for i = col, r do
      char = line:sub(i, i)
      local char_info = get_pair(char)
      if char_info and char == char_info.open then
        first = first or i
        if valid_pair(char_info, line, i + 1, r) then
          return i
        end
      end
    end

    return closing_idx or first
  end
end

-- Backward target: prev pair char before `col`, respecting nesting
local function find_prev_nested(info, line, col)
  local char = line:sub(col, col)

  if info.open == info.close or info.open == char then
    for i = col - 1, 1, -1 do
      char = line:sub(i, i)
      if get_pair(char) then
        return i + 1
      end
    end
  else
    local opening_idx = find_opening(info, line, col - 1)
    if opening_idx then
      local last

      for i = col - 1, opening_idx, -1 do
        char = line:sub(i, i)
        local char_info = get_pair(char)
        if char_info and char == char_info.close then
          last = last or i
          if valid_pair_rev(char_info, line, opening_idx, i - 1) then
            return i + 1
          end
        end
      end

      return (opening_idx + 1) or last
    end
  end
end

---@return integer|nil 1-based column to jump to
local function find_next(pair, line, col)
  local i
  if behavior == "closing" then
    local open_char = line:sub(col - 1, col - 1)
    if pair.open == pair.close then
      i = line:find(pair.close, col, true)
    elseif open_char ~= pair.close then
      i = find_closing(pair, line, col) or line:find(pair.close, col, true)
    end
    i = i or find_next_nested(pair, line, col)
  else
    i = find_next_nested(pair, line, col)
  end
  return i
end

---@return integer|nil 1-based column to jump to
local function find_prev(pair, line, col)
  local i
  if behavior == "closing" then
    local char = line:sub(col, col)
    local idx = line:sub(1, col - 1):reverse():find(pair.open, 1, true)
    if pair.open == pair.close then
      i = idx and (col - idx)
    elseif char ~= pair.open then
      i = find_opening(pair, line, col - 1) or (idx and (col - idx))
    end
    i = (i and (i + 1)) or find_prev_nested(pair, line, col)
  else
    i = find_prev_nested(pair, line, col)
  end
  return i
end

-- Tabout / tabreverse ---------------------------------------------------------

---@param lines string[]
---@param pos integer[] 1-based row, 0-based col
---@return integer|nil target col (1-based) to move to
local function out(lines, pos)
  local line = lines[pos[1]]
  if not line then
    return nil
  end

  -- Don't tabout when only whitespace precedes the cursor (keep tabs working)
  if vim.trim(line:sub(1, pos[2])) == "" then
    return nil
  end

  local col = pos[2] + 1

  -- Cursor right after an open (or any pair char): find where to jump
  local prev_pair = get_pair(line:sub(col - 1, col - 1))
  if prev_pair then
    local i = find_next(prev_pair, line, col)
    if i then
      return math.max(col + 1, i)
    end
  end

  -- Cursor on a pair char itself: jump one right (inside an empty pair, this
  -- exits it; the general case mirrors neotab's behavior)
  local curr_pair = get_pair(line:sub(col, col))
  if curr_pair then
    return col + 1
  end
end

---@param lines string[]
---@param pos integer[] 1-based row, 0-based col
---@return integer|nil target col (1-based) to move to
local function reverse(lines, pos)
  local line = lines[pos[1]]
  if not line then
    return nil
  end

  if vim.trim(line:sub(1, pos[2])) == "" then
    return nil
  end

  local col = pos[2] + 1

  local curr_pair = get_pair(line:sub(col, col))
  if curr_pair then
    local i = find_prev(curr_pair, line, col)
    if i then
      return math.min(col - 1, i)
    end
  end

  local prev_pair = get_pair(line:sub(col - 1, col - 1))
  if prev_pair then
    return col - 1
  end
end

-- Actions ----------------------------------------------------------------------

local function raw_tab()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<Tab>", true, true, true),
    "n", -- noremap: don't re-trigger our own <Tab> mapping
    false
  )
end

local function enabled()
  return not vim.tbl_contains(exclude, vim.bo.filetype)
end

function M.tabout()
  if not enabled() then
    return raw_tab()
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local target = out(lines, vim.api.nvim_win_get_cursor(0))
  if target then
    local cur = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_win_set_cursor(0, { cur[1], target - 1 })
  else
    raw_tab()
  end
end

function M.tabout_reverse()
  if not enabled() then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local target = reverse(lines, vim.api.nvim_win_get_cursor(0))
  if target then
    local cur = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_win_set_cursor(0, { cur[1], target - 1 })
  end
end

function M.setup()
  vim.keymap.set("i", "<Tab>", M.tabout, { silent = true })
  vim.keymap.set("i", "<S-Tab>", M.tabout_reverse, { silent = true })
end

return M
