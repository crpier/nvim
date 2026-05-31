-- Set leader to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymaps = require "config.keymaps"
local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.group = opts.group or "basic"
  keymaps.set(mode, lhs, rhs, opts)
end

-- Easy exit
map("n", "Q", "ZQ")
-- Stop search Highlighting
map("n", "<Esc>", function()
  vim.cmd "nohlsearch"
  -- Re-emit the <Esc> key so other plugins can use it
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end)
map("n", "<C-S>", function()
  vim.cmd "write"
end, { desc = "Save like in vsc*de" })
map("i", "<C-S>", function()
  vim.cmd "write"
end, { desc = "Save like in vsc*de" })
-- Easier to move between windows
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
-- Easier to move away from terminal windows
map("t", "<C-h>", [[<C-\><C-n><C-w>h]])
map("t", "<C-j>", [[<C-\><C-n><C-w>j]])
map("t", "<C-k>", [[<C-\><C-n><C-w>k]])
map("t", "<C-l>", [[<C-\><C-n><C-w>l]])
-- Easier to exit terminal
map("t", [[<C-/>]], [[<C-\><C-n>]])
-- Don't save { and } in jumplist
map("n", "{", ":keepjumps normal! {<CR>", { silent = true })
map("n", "}", ":keepjumps normal! }<CR>", { silent = true })
-- Easy to reload current file
map("n", "<leader>%", function()
  vim.cmd "so"
end)
-- tweak the way new lines are added a bit
map("n", "]<Space>", "o<esc>")
map("n", "[<Space>", "O<esc>")
-- Search the selected text
map("v", "//", [[y/\V<C-R>=escape(@",'/\')<CR><CR>]])
-- Print full path to current root
map("n", "y!", "<cmd>lua print(vim.loop.cwd())<cr>")
-- -- Motions for selecting lines
-- map("o", "al", ":normal val<CR>")
-- map("o", "il", ":normal vil<CR>")
-- -- Select in/outside the line
-- map("v", "al", ":<C-U>normal 0v$h<CR>")
-- map("v", "il", ":<C-U>normal ^vg_<CR>")
-- Move things in visual mode
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
