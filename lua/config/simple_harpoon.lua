local M = {}

local state_path = vim.fn.stdpath "state" .. "/simple-harpoon.json"
local terminals = {}

local function read_state()
  if vim.fn.filereadable(state_path) == 0 then
    return { projects = {} }
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(state_path), "\n"))
  if not ok or type(decoded) ~= "table" then
    return { projects = {} }
  end

  decoded.projects = decoded.projects or {}
  return decoded
end

local function write_state(state)
  vim.fn.mkdir(vim.fn.fnamemodify(state_path, ":h"), "p")
  vim.fn.writefile({ vim.json.encode(state) }, state_path)
end

local function project_key()
  return vim.uv.cwd() or vim.fn.getcwd()
end

local function project_marks(state)
  local key = project_key()
  state.projects[key] = state.projects[key] or { marks = {} }
  state.projects[key].marks = state.projects[key].marks or {}
  return state.projects[key].marks
end

local function relative_to_project(path)
  local absolute = vim.fn.fnamemodify(path, ":p")
  local root = vim.fn.fnamemodify(project_key(), ":p")
  if vim.startswith(absolute, root) then
    return absolute:sub(#root + 1)
  end
  return absolute
end

local function resolve_path(path)
  if vim.fn.fnamemodify(path, ":p") == path then
    return path
  end
  return project_key() .. "/" .. path
end

function M.add_file()
  local current = vim.api.nvim_buf_get_name(0)
  if current == "" then
    vim.notify("Current buffer has no file name", vim.log.levels.WARN)
    return
  end

  local state = read_state()
  local marks = project_marks(state)
  local path = relative_to_project(current)

  for _, mark in ipairs(marks) do
    if mark == path then
      vim.notify("Already marked: " .. path)
      return
    end
  end

  table.insert(marks, path)
  write_state(state)
  vim.notify("Marked: " .. path)
end

function M.nav_file(index)
  local state = read_state()
  local marks = project_marks(state)
  local path = marks[index]
  if not path then
    vim.notify("No harpoon mark " .. index, vim.log.levels.WARN)
    return
  end

  vim.cmd.edit(vim.fn.fnameescape(resolve_path(path)))
end

function M.toggle_quick_menu()
  local state = read_state()
  local marks = project_marks(state)
  if vim.tbl_isempty(marks) then
    vim.notify("No harpoon marks for this project", vim.log.levels.WARN)
    return
  end

  vim.ui.select(marks, {
    prompt = "Harpoon marks",
    format_item = function(item)
      for index, mark in ipairs(marks) do
        if mark == item then
          return string.format("%d  %s", index, mark)
        end
      end
      return item
    end,
  }, function(choice)
    if choice then
      vim.cmd.edit(vim.fn.fnameescape(resolve_path(choice)))
    end
  end)
end

function M.goto_terminal(index)
  local key = project_key()
  terminals[key] = terminals[key] or {}
  local bufnr = terminals[key][index]

  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_set_current_buf(bufnr)
  else
    vim.cmd.enew()
    vim.cmd.terminal()
    bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(bufnr, string.format("harpoon-terminal://%s/%d", key, index))
    vim.bo[bufnr].buflisted = true
    terminals[key][index] = bufnr
  end

  vim.cmd "startinsert"
end

return M
