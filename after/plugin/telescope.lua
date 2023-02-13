-- Telescope
local telescope = require "telescope"
telescope.setup {
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
  },
}
require("project_nvim").setup {
  ignore_lsp = { "sumneko_lua" },
  silent_chdir = true,
}
telescope.load_extension "fzf"
telescope.load_extension "projects"

local builtin = require "telescope.builtin"
-- TODO: this doesn't seem to find all files
vim.keymap.set("n", "sF", builtin.find_files)
vim.keymap.set("n", "sf", builtin.git_files)
vim.keymap.set("n", "s/", function()
  ---@diagnostic disable-next-line: param-type-mismatch
  require("telescope.builtin").grep_string { search = vim.fn.input "Grep > " }
end)
vim.keymap.set("n", "sk", builtin.keymaps)
vim.keymap.set("n", "<leader><space>", builtin.buffers)
vim.keymap.set("n", "sp", telescope.extensions.projects.projects)
vim.keymap.set("n", "sc", builtin.git_status)
vim.keymap.set("n", "sw", builtin.grep_string)
vim.keymap.set("n", "ss", builtin.lsp_document_symbols)
vim.keymap.set("n", "sb", builtin.git_branches)
