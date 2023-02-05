require("ts-node-action").setup {}
vim.keymap.set("n", "<leader>n", require("ts-node-action").node_action)
local todo = require "todo-comments"
-- TODO: lol
todo.setup {}
vim.keymap.set("n", "]t", todo.jump_next)
vim.keymap.set("n", "[t", todo.jump_prev)
vim.keymap.set("n", "st", "<cmd>TodoTelescope<CR>")

require("twilight").setup {
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
}

vim.keymap.set("n", "mr", "<cmd>CellularAutomaton make_it_rain<cr>")
require("wpm").setup {}
