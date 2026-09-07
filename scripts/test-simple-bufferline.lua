-- Run: nvim --headless -u NONE -l scripts/test-simple-bufferline.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.o.hidden = true
local line = require "config.simple_bufferline"
line.setup()
local root = vim.fn.tempname()

local function open(name)
  vim.cmd.edit(vim.fn.fnameescape(root .. "/" .. name))
  return vim.api.nvim_get_current_buf()
end

local function contains(text, value, expected)
  assert((text:find(value, 1, true) ~= nil) == expected, value .. " in " .. text)
end

local first = open "first.lua"
local hidden = open "hidden.lua"
local other = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_name(other, root .. "/unvisited.lua")
contains(line.render(), "unvisited.lua", true) -- Single tab still lists every buffer.
local tab1 = vim.api.nvim_get_current_tabpage()
vim.cmd.tabnew()
local second = open "second.lua"
local tab2 = vim.api.nvim_get_current_tabpage()
contains(line.render(), "hidden.lua", true) -- Tab label, not a buffer in tab 2.
contains(line.render(), "%" .. hidden .. "@", false)
contains(line.render(), "%" .. second .. "@", true)
contains(line.render(), "%1T 1: hidden.lua", true)
contains(line.render(), "%2T 2: second.lua", true)

vim.api.nvim_set_current_tabpage(tab1)
contains(line.render(), "%" .. first .. "@", true)
contains(line.render(), "%" .. hidden .. "@", true)
contains(line.render(), "%" .. second .. "@", false)
contains(line.render(), "%" .. other .. "@", false)
line.select(first)
local first_win = vim.api.nvim_get_current_win()
vim.cmd.vsplit()
vim.api.nvim_set_current_buf(hidden)
local hidden_win = vim.api.nvim_get_current_win()
line.select(first)
assert(vim.api.nvim_get_current_win() == first_win)
assert(vim.api.nvim_win_get_buf(hidden_win) == hidden)

-- Sharing a buffer doesn't remove it from its original tab.
vim.api.nvim_set_current_tabpage(tab2)
line.select(first)
line.select(second)
contains(line.render(), "%" .. first .. "@", true)
vim.api.nvim_buf_set_lines(first, 0, -1, false, { "changed" })
contains(line.render(), "%1T 1: first.lua +", true)
contains(line.render(), "%2T 2: second.lua +", true)

-- Duplicate names and percent escaping still work inside a tab.
open "a/same.lua"
open "b/same.lua"
contains(line.render(), "a/same.lua", true)
contains(line.render(), "b/same.lua", true)
open "100%.lua"
contains(line.render(), "100%%.lua", true)
vim.cmd "tabmove 0"
contains(line.render(), "%1T 1: 100%%.lua", true)
contains(line.render(), "%2T 2: first.lua +", true)

vim.api.nvim_buf_delete(first, { force = true })
contains(line.render(), "%" .. first .. "@", false)
vim.api.nvim_set_current_tabpage(tab1)
contains(line.render(), "%" .. first .. "@", false)
line.setup() -- Repeated setup keeps history, without duplicate autocmds.
contains(line.render(), "%" .. hidden .. "@", true)
vim.cmd "tabonly!"
contains(line.render(), "second.lua", true)
contains(line.render(), "%1T", false)

-- :tab split has no BufEnter; deferred TabEnter tracking must handle it.
local shared = vim.api.nvim_get_current_buf()
vim.cmd "tab split"
vim.wait(20, function()
  return line.render():find("%" .. shared .. "@", 1, true) ~= nil
end)
contains(line.render(), "%" .. shared .. "@", true)
vim.cmd.tabnew()
local fresh = open "fresh.lua"
vim.wait(20)
contains(line.render(), "%" .. shared .. "@", false)
contains(line.render(), "%" .. fresh .. "@", true)

-- Check that Neovim can parse the generated format.
vim.api.nvim_eval_statusline(line.render(), { use_tabline = true })
print "simple-bufferline: all tests passed"
vim.cmd "qa!"
