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
require("colorizer").setup()
require("indent_blankline").setup {
  indentLine_enabled = 1,
  filetype_exclude = {
    "help",
    "terminal",
    "alpha",
    "packer",
    "lspinfo",
    "TelescopePrompt",
    "TelescopeResults",
    "mason",
    "",
  },
  buftype_exclude = { "terminal" },
  show_trailing_blankline_indent = false,
  show_first_indent_level = false,
  show_current_context = true,
  show_current_context_start = true,
}
