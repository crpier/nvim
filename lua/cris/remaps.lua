-- Set leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- Easy open netrw
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)
-- Easy exit
vim.keymap.set("n", "Q", "ZQ")
-- Don't highlight search
vim.keymap.set("n", "<Esc>", function()
  vim.cmd [[ nohlsearch ]]
end)
-- Save like in vsc**e
vim.keymap.set("n", "<C-S>", function()
  vim.cmd [[write]]
end)
-- Replace the word you were on
-- TODO: to lua
vim.keymap.set("n", "g%", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- Easier to move between windows
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
-- Easier to exit terminal
vim.keymap.set("t", [[<C-/>]], [[<C-\><C-n>]])
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]])
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]])
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]])
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]])
-- Don't save { and } in jumplist
vim.keymap.set("n", "{", ":keepjumps normal! {<CR>")
vim.keymap.set("n", "}", ":keepjumps normal! }<CR>")
-- Easy to relod current file
vim.keymap.set("n", "<leader>%", function()
  vim.cmd [[so]]
end)
-- tweak the way new lines are added a bit
vim.keymap.set("n", "]<Space>", "o<esc>")
vim.keymap.set("n", "[<Space>", "O<esc>")
-- Search the selected test
vim.keymap.set("v", "//", [[y/\V<C-R>=escape(@",'/\')<CR><CR>]])
-- Print full path to current root
vim.keymap.set("n", "y!", "<cmd>lua print(vim.loop.cwd())<cr>")
-- Motions for selecting lines
vim.keymap.set("o", "al", ":normal val<CR>")
vim.keymap.set("o", "il", ":normal vil<CR>")
-- Toggle the quickfixlist
vim.keymap.set("n", "<C-Q>", function()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd "cclose"
    return
  end
  vim.cmd "copen"
end)

-- Select in/outside the line
vim.keymap.set("v", "al", ":<C-U>normal 0v$h<CR>")
vim.keymap.set("v", "il", ":<C-U>normal ^vg_<CR>")
-- Move things in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
