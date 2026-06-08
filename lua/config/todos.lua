local M = {}

local todo_pattern = [[\v<(TODO|FIXME|HACK|NOTE|BUG|XXX)>]]
local rg_pattern = [[\b(TODO|FIXME|HACK|NOTE|BUG|XXX)\b]]
local python_todo_namespace = vim.api.nvim_create_namespace "python-todo-comment-blocks"

function M.jump_next()
  if vim.fn.search(todo_pattern, "W") == 0 then
    vim.notify("No next TODO", vim.log.levels.INFO)
  end
end

function M.jump_prev()
  if vim.fn.search(todo_pattern, "bW") == 0 then
    vim.notify("No previous TODO", vim.log.levels.INFO)
  end
end

function M.open_picker()
  if vim.fn.executable "rg" ~= 1 then
    vim.notify("rg is required for TODO search", vim.log.levels.ERROR)
    return
  end

  require("snacks").picker.grep {
    title = "TODOs",
    search = rg_pattern,
    live = false,
    need_search = false,
    hidden = true,
    exclude = { ".git" },
  }
end

local function comment_start(line)
  local start_col = line:find "#"
  if start_col == nil then
    return nil
  end
  return start_col - 1
end

local function comment_indent(line)
  return line:match "^(%s*)#"
end

local function is_todo_comment(line)
  return line:find "^%s*#%s*TODO:?" ~= nil
end

local function is_comment(line)
  return comment_indent(line) ~= nil
end

function M.highlight_python_todo_blocks(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, python_todo_namespace, 0, -1)
  if vim.bo[bufnr].filetype ~= "python" then
    return
  end

  local in_todo_block = false
  local todo_indent = nil
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for index, line in ipairs(lines) do
    local current_indent = comment_indent(line)
    if is_todo_comment(line) then
      in_todo_block = true
      todo_indent = current_indent
    elseif not (in_todo_block and is_comment(line) and current_indent == todo_indent) then
      in_todo_block = false
      todo_indent = nil
    end

    if in_todo_block then
      local start_col = comment_start(line)
      if start_col ~= nil then
        vim.api.nvim_buf_set_extmark(bufnr, python_todo_namespace, index - 1, start_col, {
          end_col = #line,
          hl_group = "@comment.todo",
          priority = 110,
        })
      end
    end
  end
end

function M.setup()
  local keymaps = require "config.keymaps"
  keymaps.set("n", "sto", M.open_picker, { desc = "Open TODOs in Snacks picker", group = "todos" })
  keymaps.set("n", "]t", M.jump_next, { desc = "Next TODO", group = "todos" })
  keymaps.set("n", "[t", M.jump_prev, { desc = "Previous TODO", group = "todos" })

  vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "TextChanged", "TextChangedI", "InsertLeave" }, {
    group = vim.api.nvim_create_augroup("PythonTodoCommentBlocks", { clear = true }),
    callback = function(event)
      M.highlight_python_todo_blocks(event.buf)
    end,
  })
end

return M
