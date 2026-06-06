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

local function find_mark_index(marks, path)
  for index, mark in ipairs(marks) do
    if mark == path then
      return index
    end
  end
  return nil
end

local function picker_items(marks)
  return vim.tbl_map(function(mark)
    local index = find_mark_index(marks, mark)
    return {
      text = string.format("%d  %s", index, mark),
      file = resolve_path(mark),
      mark = mark,
      mark_index = index,
    }
  end, marks)
end

local function open_mark(mark)
  vim.cmd.edit(vim.fn.fnameescape(resolve_path(mark)))
end

--- Add the current file to this project's harpoon list.
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

--- Open a file by its 1-based harpoon mark index.
---@param index integer
function M.nav_file(index)
  local state = read_state()
  local marks = project_marks(state)
  local path = marks[index]
  if not path then
    vim.notify("No harpoon mark " .. index, vim.log.levels.WARN)
    return
  end

  open_mark(path)
end

local function refresh_after_change(picker, marks)
  if vim.tbl_isempty(marks) then
    picker:close()
    vim.notify "No harpoon marks left for this project"
    return
  end

  picker:refresh()
end

local function remove_picker_mark(picker, item, state, marks)
  if item == nil then
    return
  end

  local removed = table.remove(marks, item.mark_index)
  if removed == nil then
    return
  end

  write_state(state)
  vim.notify("Removed mark " .. item.mark_index .. ": " .. removed)
  refresh_after_change(picker, marks)
end

local function move_picker_mark(picker, item, state, marks, delta)
  if item == nil then
    return
  end

  local target = item.mark_index + delta
  if target < 1 or target > #marks then
    vim.notify("Mark is already at the edge of the list", vim.log.levels.WARN)
    return
  end

  marks[item.mark_index], marks[target] = marks[target], marks[item.mark_index]
  write_state(state)
  vim.notify(string.format("Moved mark to %d: %s", target, marks[target]))
  picker:refresh()
end

--- Open a picker for this project's harpoon list.
function M.toggle_quick_menu()
  local state = read_state()
  local marks = project_marks(state)
  if vim.tbl_isempty(marks) then
    vim.notify("No harpoon marks for this project", vim.log.levels.WARN)
    return
  end

  require("snacks").picker {
    title = "Harpoon marks (dd: remove, J/K: move)",
    finder = function()
      return picker_items(marks)
    end,
    format = "text",
    preview = "file",
    confirm = function(picker, item)
      picker:close()
      if item then
        open_mark(item.mark)
      end
    end,
    actions = {
      harpoon_remove = function(picker, item)
        remove_picker_mark(picker, item, state, marks)
      end,
      harpoon_move_up = function(picker, item)
        move_picker_mark(picker, item, state, marks, -1)
      end,
      harpoon_move_down = function(picker, item)
        move_picker_mark(picker, item, state, marks, 1)
      end,
    },
    win = {
      input = {
        keys = {
          dd = { "harpoon_remove", mode = "n", desc = "Remove mark" },
          K = { "harpoon_move_up", mode = "n", desc = "Move mark up" },
          J = { "harpoon_move_down", mode = "n", desc = "Move mark down" },
        },
      },
      list = {
        keys = {
          dd = { "harpoon_remove", desc = "Remove mark" },
          K = { "harpoon_move_up", desc = "Move mark up" },
          J = { "harpoon_move_down", desc = "Move mark down" },
        },
      },
    },
  }
end

--- Open or return to a project-local terminal slot.
---@param index integer
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

function M.setup()
  local keymaps = require "config.keymaps"
  local function map(lhs, rhs, desc)
    keymaps.set("n", lhs, rhs, { desc = desc, group = "harpoon" })
  end

  map("mm", M.add_file, "Mark file")
  map("mq", M.toggle_quick_menu, "Show marked files")
  map("ma", function()
    M.nav_file(1)
  end, "Go to mark 1")
  map("ms", function()
    M.nav_file(2)
  end, "Go to mark 2")
  map("md", function()
    M.nav_file(3)
  end, "Go to mark 3")
  map("mf", function()
    M.nav_file(4)
  end, "Go to mark 4")
  map("mg", function()
    M.goto_terminal(1)
  end, "Go to terminal 1")
end

return M
