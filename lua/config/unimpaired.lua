local M = {}

local function cmd(command)
  return function()
    local ok, err = pcall(vim.cmd, command)
    if not ok then
      vim.notify(err, vim.log.levels.WARN)
    end
  end
end

local function get_option(option)
  local ok, value = pcall(vim.api.nvim_get_option_value, option, { scope = "local" })
  if ok then
    return value
  end
  return vim.api.nvim_get_option_value(option, {})
end

local function set_option_value(option, value)
  local ok = pcall(function()
    vim.opt_local[option] = value
  end)
  if not ok then
    vim.opt[option] = value
  end
end

local function toggle_option(option)
  return function()
    set_option_value(option, not get_option(option))
  end
end

local function toggle_option_between(option, off_value, on_value)
  return function()
    if get_option(option) == on_value then
      set_option_value(option, off_value)
    else
      set_option_value(option, on_value)
    end
  end
end

local function set_option(option, value)
  return function()
    set_option_value(option, value)
  end
end

function M.setup()
  local keymaps = require "config.keymaps"
  local function map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.group = opts.group or "unimpaired"
    keymaps.set(mode, lhs, rhs, opts)
  end

  map("n", "]q", cmd "cnext", { desc = "Next quickfix item" })
  map("n", "[q", cmd "cprevious", { desc = "Previous quickfix item" })
  map("n", "]Q", cmd "clast", { desc = "Last quickfix item" })
  map("n", "[Q", cmd "cfirst", { desc = "First quickfix item" })

  map("n", "]l", cmd "lnext", { desc = "Next location-list item" })
  map("n", "[l", cmd "lprevious", { desc = "Previous location-list item" })
  map("n", "]L", cmd "llast", { desc = "Last location-list item" })
  map("n", "[L", cmd "lfirst", { desc = "First location-list item" })

  map("n", "]b", cmd "bnext", { desc = "Next buffer" })
  map("n", "[b", cmd "bprevious", { desc = "Previous buffer" })
  map("n", "]B", cmd "blast", { desc = "Last buffer" })
  map("n", "[B", cmd "bfirst", { desc = "First buffer" })

  map("n", "yow", toggle_option "wrap", { desc = "Toggle wrap" })
  map("n", "[ow", set_option("wrap", false), { desc = "Disable wrap" })
  map("n", "]ow", set_option("wrap", true), { desc = "Enable wrap" })

  map("n", "yos", toggle_option "spell", { desc = "Toggle spell" })
  map("n", "[os", set_option("spell", false), { desc = "Disable spell" })
  map("n", "]os", set_option("spell", true), { desc = "Enable spell" })

  map("n", "yon", toggle_option "number", { desc = "Toggle line numbers" })
  map("n", "yor", toggle_option "relativenumber", { desc = "Toggle relative numbers" })
  map("n", "yol", toggle_option "list", { desc = "Toggle list chars" })
  map("n", "yoh", toggle_option "hlsearch", { desc = "Toggle search highlight" })
  map("n", "yoc", toggle_option "cursorline", { desc = "Toggle cursorline" })
  map("n", "yoC", toggle_option_between("conceallevel", 0, 2), { desc = "Toggle conceallevel" })
end

return M
