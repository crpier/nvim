-- Set leader to spaceq
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- Easy exit
vim.keymap.set("n", "Q", "ZQ")
-- Stop search Highlighting
vim.keymap.set("n", "<Esc>", function()
  vim.cmd "nohlsearch"
  -- Re-emit the <Esc> key so other plugins can use it
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end)
vim.keymap.set("n", "<C-S>", function()
  vim.cmd "write"
end, { desc = "Save like in vsc*de" })
vim.keymap.set("i", "<C-S>", function()
  vim.cmd "write"
end, { desc = "Save like in vsc*de" })
-- Easier to move between windows
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
-- Easier to move away from terminal windows
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]])
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]])
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]])
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]])
-- Easier to exit terminal
vim.keymap.set("t", [[<C-/>]], [[<C-\><C-n>]])
-- Don't save { and } in jumplist
vim.keymap.set("n", "{", ":keepjumps normal! {<CR>", { silent = true })
vim.keymap.set("n", "}", ":keepjumps normal! }<CR>", { silent = true })
-- Easy to reload current file
vim.keymap.set("n", "<leader>%", function()
  vim.cmd "so"
end)
-- tweak the way new lines are added a bit
vim.keymap.set("n", "]<Space>", "o<esc>")
vim.keymap.set("n", "[<Space>", "O<esc>")
-- Search the selected text
vim.keymap.set("v", "//", [[y/\V<C-R>=escape(@",'/\')<CR><CR>]])
-- Print full path to current root
vim.keymap.set("n", "y!", "<cmd>lua print(vim.loop.cwd())<cr>")
-- -- Motions for selecting lines
-- vim.keymap.set("o", "al", ":normal val<CR>")
-- vim.keymap.set("o", "il", ":normal vil<CR>")
-- -- Select in/outside the line
-- vim.keymap.set("v", "al", ":<C-U>normal 0v$h<CR>")
-- vim.keymap.set("v", "il", ":<C-U>normal ^vg_<CR>")
-- Move things in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- TODO: key to toggle absolute and relative line numbers
