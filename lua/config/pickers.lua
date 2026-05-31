local M = {}

local default_project_dirs = {
  "~/Projects",
  "~/.config/nvim",
  "~/.dotfiles",
  "~/vault",
}

local function snacks_picker()
  return require("snacks").picker
end

local function project_dirs()
  local dirs = vim.deepcopy(default_project_dirs)
  for _, dir in ipairs(require("config.utils").load_local_options().project_base_dirs) do
    if type(dir) == "string" then
      table.insert(dirs, dir)
    elseif type(dir) == "table" and dir.path then
      table.insert(dirs, dir.path)
    end
  end
  return dirs
end

local function register_items()
  local items = {}
  for i = 0, 9 do
    local register = tostring(i)
    local value = vim.fn.getreg(register)
    if value ~= "" then
      table.insert(items, {
        text = string.format("[%s] %s", register, value:gsub("\n", "\\n")),
        register = register,
      })
    end
  end
  return items
end

function M.non_daily_notes()
  snacks_picker().files {
    cwd = "~/vault",
    exclude = { "daily" },
    title = "Notes (excluding daily)",
  }
end

function M.registers_0_to_9()
  snacks_picker() {
    title = "Registers 0-9 (Yank/Delete)",
    items = register_items(),
    format = function(item)
      return { { item.text } }
    end,
    confirm = function(picker, item)
      picker:close()
      vim.fn.setreg('"', vim.fn.getreg(item.register))
      vim.cmd('normal! ""p')
    end,
  }
end

function M.projects()
  snacks_picker().projects {
    dev = project_dirs(),
    max_depth = 2,
  }
end

function M.keys()
  return {
    {
      "sf",
      function()
        snacks_picker().git_files()
      end,
      desc = "Search git files",
    },
    {
      "sF",
      function()
        snacks_picker().files { hidden = true }
      end,
      desc = "Find all files (including hidden)",
    },
    {
      "stp",
      function()
        snacks_picker().git_files { search = "!tests .py", title = "Python files (no tests)" }
      end,
      desc = "Search Python files (excluding tests)",
    },
    {
      "stP",
      function()
        snacks_picker().git_files { search = "tests .py", title = "Python test files" }
      end,
      desc = "Search Python test files only",
    },
    {
      "stl",
      function()
        snacks_picker().git_files { search = ".lua", title = "Lua files" }
      end,
      desc = "Search Lua files",
    },
    {
      "sl",
      function()
        snacks_picker().grep()
      end,
      desc = "Search live grep",
    },
    {
      "su",
      function()
        snacks_picker().lines()
      end,
      desc = "Fuzzy find in current buffer",
    },
    {
      "so",
      function()
        snacks_picker().recent()
      end,
      desc = "Search old files",
    },
    {
      "s/",
      function()
        snacks_picker().grep { search = vim.fn.input "Grep > " }
      end,
      desc = "Search word from user input",
    },
    {
      "sd",
      function()
        snacks_picker().diagnostics()
      end,
      desc = "Open all diagnostics",
    },
    {
      "sk",
      function()
        snacks_picker().keymaps()
      end,
      desc = "Search all keymaps",
    },
    {
      "s<space>",
      function()
        snacks_picker().buffers()
      end,
      desc = "Search buffers",
    },
    {
      "sw",
      function()
        snacks_picker().grep_word()
      end,
      desc = "Search word under cursor",
    },
    {
      "sm",
      function()
        snacks_picker().marks()
      end,
      desc = "Search marks",
    },
    {
      "sgc",
      function()
        snacks_picker().git_status()
      end,
      desc = "Search files with git changes",
    },
    {
      "sgb",
      function()
        snacks_picker().git_branches()
      end,
      desc = "Search git branches",
    },
    {
      "sp",
      M.projects,
      desc = "Search projects",
    },
    {
      "sra",
      function()
        snacks_picker().registers()
      end,
      desc = "Search all registers",
    },
    {
      "srd",
      M.registers_0_to_9,
      desc = "Search registers 0-9 (yank/delete only)",
    },
  }
end

return M
