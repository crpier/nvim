local M = {}

local todo_pattern = [[\v<(TODO|FIXME|HACK|NOTE|BUG|XXX)>]]
local rg_pattern = [[\b(TODO|FIXME|HACK|NOTE|BUG|XXX)\b]]

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

return M
