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

local document_highlight_method = vim.lsp.protocol.Methods.textDocument_documentHighlight

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

local function client_supports_method(client, method, bufnr)
  if vim.fn.has "nvim-0.11" == 1 then
    return client:supports_method(method, bufnr)
  end
  return client.supports_method(method, { bufnr = bufnr })
end

local function document_highlight_clients(bufnr)
  local clients = {}
  for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
    if client_supports_method(client, document_highlight_method, bufnr) then
      clients[#clients + 1] = client
    end
  end
  return clients
end

local function byte_col(line, character, offset_encoding)
  local ok, col = pcall(vim.str_byteindex, line, offset_encoding or "utf-16", character, false)
  if ok then
    return col
  end
  return character
end

local function lsp_range_item(bufnr, range, offset_encoding)
  local start_line = vim.api.nvim_buf_get_lines(bufnr, range.start.line, range.start.line + 1, true)[1] or ""
  local end_line = vim.api.nvim_buf_get_lines(bufnr, range["end"].line, range["end"].line + 1, true)[1] or ""

  return {
    start_row = range.start.line,
    start_col = byte_col(start_line, range.start.character, offset_encoding),
    end_row = range["end"].line,
    end_col = byte_col(end_line, range["end"].character, offset_encoding),
  }
end

local function lsp_highlight_key(item)
  return table.concat({ item.start_row, item.start_col, item.end_row, item.end_col }, ":")
end

local function lsp_document_highlights(bufnr)
  local clients = document_highlight_clients(bufnr)
  if #clients == 0 then
    return {}
  end

  local params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding or "utf-16")
  local responses = vim.lsp.buf_request_sync(bufnr, document_highlight_method, params, 500)
  if responses == nil then
    return {}
  end

  local highlights = {}
  local seen = {}
  for client_id, response in pairs(responses) do
    local client = vim.lsp.get_client_by_id(client_id)
    local result = response.result or {}
    for _, highlight in ipairs(result) do
      if highlight.range ~= nil then
        local item = lsp_range_item(bufnr, highlight.range, client and client.offset_encoding or "utf-16")
        local key = lsp_highlight_key(item)
        if not seen[key] then
          seen[key] = true
          highlights[#highlights + 1] = item
        end
      end
    end
  end

  table.sort(highlights, function(left, right)
    return left.start_row < right.start_row or (left.start_row == right.start_row and left.start_col < right.start_col)
  end)

  return highlights
end

local function cursor_is_in_lsp_highlight(item, cursor_row, cursor_col)
  local starts_before_or_at_cursor = item.start_row < cursor_row
    or (item.start_row == cursor_row and item.start_col <= cursor_col)
  local ends_after_cursor = item.end_row > cursor_row or (item.end_row == cursor_row and item.end_col > cursor_col)
  return starts_before_or_at_cursor and ends_after_cursor
end

local function lsp_highlight_starts_before_cursor(item, cursor_row, cursor_col)
  return item.start_row < cursor_row or (item.start_row == cursor_row and item.start_col < cursor_col)
end

local function next_lsp_highlight_index(highlights, cursor_row, cursor_col, delta)
  local current_index
  for index, item in ipairs(highlights) do
    if cursor_is_in_lsp_highlight(item, cursor_row, cursor_col) then
      current_index = index
      break
    end
  end

  if current_index ~= nil then
    return (current_index + delta + #highlights - 1) % #highlights + 1
  end

  if delta > 0 then
    for index, item in ipairs(highlights) do
      if not lsp_highlight_starts_before_cursor(item, cursor_row, cursor_col) then
        return index
      end
    end
    return 1
  end

  for index = #highlights, 1, -1 do
    if lsp_highlight_starts_before_cursor(highlights[index], cursor_row, cursor_col) then
      return index
    end
  end
  return #highlights
end

local function goto_lsp_highlight(item)
  vim.cmd "normal! m'"
  vim.api.nvim_win_set_cursor(0, { item.start_row + 1, item.start_col })
end

local function goto_adjacent_lsp_document_highlight(bufnr, delta)
  local highlights = lsp_document_highlights(bufnr)
  if #highlights < 2 then
    return false
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  goto_lsp_highlight(highlights[next_lsp_highlight_index(highlights, cursor[1] - 1, cursor[2], delta)])
  return true
end

--- Jump to the next or previous usage under the cursor.
---
--- Prefer LSP document highlights when available so `<C-n>` / `<C-p>` move
--- through the same symbols that CursorHold highlights. Fall back to each
--- parser's `locals.scm` query when LSP highlights are unavailable.
---@param delta 1|-1
function M.goto_adjacent_usage(delta)
  local bufnr = vim.api.nvim_get_current_buf()
  if goto_adjacent_lsp_document_highlight(bufnr, delta) then
    return
  end

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
