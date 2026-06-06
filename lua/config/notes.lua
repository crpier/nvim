local M = {}

local vault_dir = vim.fn.expand "~/vault"
local daily_folder = "daybook"
local templates_folder = "templates"
local daily_template = "daybook.md"

local function joinpath(...)
  return vim.fs.joinpath(...)
end

local function read_file(path)
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end
  return table.concat(vim.fn.readfile(path), "\n") .. "\n"
end

local function write_new_file(path, content)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  if vim.fn.filereadable(path) == 0 then
    vim.fn.writefile(vim.split(content, "\n", { plain = true }), path)
  end
end

local function open_file(path)
  vim.cmd.edit(vim.fn.fnameescape(path))
end

local function trim(value)
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function note_filename(title)
  title = trim(title)
  if title == "" then
    return nil
  end

  if not title:match "%.md$" then
    title = title .. ".md"
  end

  return joinpath(vault_dir, title)
end

local function note_content(title)
  return table.concat({
    "---",
    "tags: []",
    "---",
    "",
    "# " .. title,
    "",
  }, "\n")
end

local function today_path()
  local year = os.date "%Y"
  local date = os.date "%Y-%m-%d"
  return joinpath(vault_dir, daily_folder, year, date .. ".md")
end

local function today_content()
  local template_path = joinpath(vault_dir, templates_folder, daily_template)
  local template = read_file(template_path)
  local date = os.date "%Y-%m-%d"

  if template ~= nil then
    return template:gsub("{{date}}", date)
  end

  return table.concat({
    "---",
    "tags:",
    "  - daybook",
    "---",
    "",
    "# " .. date,
    "",
  }, "\n")
end

function M.pick_notes()
  require("config.pickers").non_daily_notes()
end

function M.new_note()
  vim.ui.input({ prompt = "New note title: " }, function(title)
    if title == nil then
      return
    end

    local path = note_filename(title)
    if path == nil then
      vim.notify("Note title cannot be empty", vim.log.levels.WARN)
      return
    end

    write_new_file(path, note_content(trim(title:gsub("%.md$", ""))))
    open_file(path)
  end)
end

function M.today()
  local path = today_path()
  write_new_file(path, today_content())
  open_file(path)
end

function M.setup()
  local keymaps = require "config.keymaps"
  keymaps.set("n", "<leader>of", M.pick_notes, { desc = "Open notes picker", group = "notes" })
  keymaps.set("n", "<leader>on", M.new_note, { desc = "Create new note", group = "notes" })
  keymaps.set("n", "<leader>ot", M.today, { desc = "Open today's daily note", group = "notes" })
end

return M
