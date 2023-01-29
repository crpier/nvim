-- Set leader
vim.g.mapleader = " "
vim.g.maplocalleader = ' '
-- Easy open netrw
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)
-- Easy exit
vim.keymap.set("n", "Q", "ZQ")
-- Don't highlight search
vim.keymap.set("n", "<Esc>", function() vim.cmd [[ nohlsearch ]] end)
-- Save like in vsc**e
vim.keymap.set("n", "<C-S>", function() vim.cmd [[write]] end)
-- Replace the work you were on
-- TODO: to lua
vim.keymap.set("n", "g%", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- Easier to move between windows
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
-- Easier to exit terminal
vim.keymap.set("t", [[<C-\\>]], [[<C-\><C-n>]])
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]])
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]])
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]])
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]])
-- Don't save { and } in jumplist
vim.keymap.set("n", "{", ":keepjumps normal! {<CR>")
vim.keymap.set("n", "}", ":keepjumps normal! }<CR>")
-- Easy to relod current file
vim.keymap.set("n", "<leader>%", function() vim.cmd [[so]] end)
-- tweak the way new lines are added a bit
vim.keymap.set("n", "]<Space>", "o<esc>")
vim.keymap.set("n", "[<Space>", "O<esc>")

-- Select in/outside the line
vim.keymap.set("v", "al", ":<C-U>normal 0v$h<CR>")
vim.keymap.set("v", "il", ":<C-U>normal ^vg_<CR>")
-- Move things in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
