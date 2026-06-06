local M = {}

local function node_text(bufnr, node)
  local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)
  if ok then
    return text
  end
end

local function node_at_cursor(bufnr)
  if vim.treesitter.get_node then
    local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr })
    if ok and node ~= nil then
      return node
    end
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok then
    return nil
  end

  local tree = parser:parse()[1]
  if tree == nil then
    return nil
  end

  local row = cursor[1] - 1
  local col = cursor[2]
  return tree:root():named_descendant_for_range(row, col, row, col + 1)
end

local function node_range(node)
  local start_row, start_col, end_row, end_col = node:range()
  return start_row, start_col, end_row, end_col
end

local function range_key(node)
  local start_row, start_col, end_row, end_col = node_range(node)
  return table.concat({ node:type(), start_row, start_col, end_row, end_col }, ":")
end

local function node_contains(outer, inner)
  local outer_start_row, outer_start_col, outer_end_row, outer_end_col = node_range(outer)
  local inner_start_row, inner_start_col, inner_end_row, inner_end_col = node_range(inner)

  local starts_after_outer = inner_start_row > outer_start_row
    or (inner_start_row == outer_start_row and inner_start_col >= outer_start_col)
  local ends_before_outer = inner_end_row < outer_end_row
    or (inner_end_row == outer_end_row and inner_end_col <= outer_end_col)

  return starts_after_outer and ends_before_outer
end

local function node_size(node)
  local start_row, start_col, end_row, end_col = node_range(node)
  return (end_row - start_row) * 100000 + (end_col - start_col)
end

local function is_usage_capture(capture_name)
  return capture_name == "local.reference" or capture_name:find "^local%.definition" ~= nil
end

local function is_scope_capture(capture_name)
  return capture_name == "local.scope"
end

local function query_for_buffer(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok then
    return nil, nil, nil
  end

  local tree = parser:parse()[1]
  if tree == nil then
    return nil, nil, nil
  end

  local ok_query, query = pcall(vim.treesitter.query.get, parser:lang(), "locals")
  if not ok_query or query == nil then
    return nil, nil, nil
  end

  return tree:root(), query, parser:lang()
end

local function innermost_scope(scopes, node)
  local best
  for _, scope in ipairs(scopes) do
    if node_contains(scope, node) and (best == nil or node_size(scope) < node_size(best)) then
      best = scope
    end
  end
  return best
end

local function collect_local_captures(bufnr, root, query)
  local scopes = {}
  local usages = {}

  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    local capture_name = query.captures[id]
    if is_scope_capture(capture_name) then
      scopes[#scopes + 1] = node
    elseif is_usage_capture(capture_name) then
      local text = node_text(bufnr, node)
      if text ~= nil and text ~= "" and not text:find "\n" then
        usages[#usages + 1] = {
          node = node,
          name = capture_name,
          text = text,
        }
      end
    end
  end

  for _, usage in ipairs(usages) do
    usage.scope = innermost_scope(scopes, usage.node) or root
  end

  return usages
end

local function current_usage(captures, cursor_node)
  local best
  for _, capture in ipairs(captures) do
    if node_contains(capture.node, cursor_node) or node_contains(cursor_node, capture.node) then
      if best == nil or node_size(capture.node) < node_size(best.node) then
        best = capture
      end
    end
  end
  return best
end

local function same_scope(left, right)
  return range_key(left) == range_key(right)
end

local function matching_usages(captures, current)
  local matches = {}
  local seen = {}

  for _, capture in ipairs(captures) do
    local key = range_key(capture.node)
    if capture.text == current.text and same_scope(capture.scope, current.scope) and not seen[key] then
      seen[key] = true
      matches[#matches + 1] = capture.node
    end
  end

  table.sort(matches, function(left, right)
    local left_row, left_col = left:start()
    local right_row, right_col = right:start()
    return left_row < right_row or (left_row == right_row and left_col < right_col)
  end)

  return matches
end

local function node_starts_before_cursor(node, cursor_row, cursor_col)
  local row, col = node:start()
  return row < cursor_row or (row == cursor_row and col < cursor_col)
end

local function cursor_is_in_node(node, cursor_row, cursor_col)
  local start_row, start_col, end_row, end_col = node_range(node)
  local starts_before_or_at_cursor = start_row < cursor_row or (start_row == cursor_row and start_col <= cursor_col)
  local ends_after_cursor = end_row > cursor_row or (end_row == cursor_row and end_col > cursor_col)
  return starts_before_or_at_cursor and ends_after_cursor
end

local function next_index(matches, cursor_row, cursor_col, delta)
  local current_index
  for index, node in ipairs(matches) do
    if cursor_is_in_node(node, cursor_row, cursor_col) then
      current_index = index
      break
    end
  end

  if current_index ~= nil then
    return (current_index + delta + #matches - 1) % #matches + 1
  end

  if delta > 0 then
    for index, node in ipairs(matches) do
      if not node_starts_before_cursor(node, cursor_row, cursor_col) then
        return index
      end
    end
    return 1
  end

  for index = #matches, 1, -1 do
    if node_starts_before_cursor(matches[index], cursor_row, cursor_col) then
      return index
    end
  end
  return #matches
end

local function goto_node(node)
  local row, col = node:start()
  vim.cmd "normal! m'"
  vim.api.nvim_win_set_cursor(0, { row + 1, col })
end

--- Jump to the next or previous Treesitter local usage under the cursor.
---
--- This uses each parser's `locals.scm` query directly instead of
--- nvim-treesitter-refactor's `nvim-treesitter.locals` helpers, which have been
--- brittle on newer Neovim/Treesitter builds.
---@param delta 1|-1
function M.goto_adjacent_usage(delta)
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_node = node_at_cursor(bufnr)
  if cursor_node == nil then
    return
  end

  local root, query = query_for_buffer(bufnr)
  if root == nil or query == nil then
    return
  end

  local captures = collect_local_captures(bufnr, root, query)
  local current = current_usage(captures, cursor_node)
  if current == nil then
    return
  end

  local matches = matching_usages(captures, current)
  if #matches < 2 then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  goto_node(matches[next_index(matches, cursor[1] - 1, cursor[2], delta)])
end

function M.goto_next_usage()
  M.goto_adjacent_usage(1)
end

function M.goto_previous_usage()
  M.goto_adjacent_usage(-1)
end

return M
