-- Telescope
local ok, telescope = pcall(require, "telescope")
if ok then
  telescope.setup {
    extensions = {
      fzf = {
        fuzzy = true,                   -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true,    -- override the file sorter
        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      },
      ["ui-select"] = {
        require("telescope.themes").get_dropdown {
        }
      },
    },
  }
  require("project_nvim").setup {
    ignore_lsp = { "lua_ls" },
    silent_chdir = true,
  }
  telescope.load_extension "fzf"
  telescope.load_extension "projects"
  telescope.load_extension "ui-select"

  local builtin = require "telescope.builtin"
  vim.keymap.set("n", "sF", function() builtin.find_files({ hidden = true }) end)
  vim.keymap.set("n", "sf", builtin.git_files)
  vim.keymap.set("n", "sg", builtin.live_grep)
  vim.keymap.set("n", "su", builtin.current_buffer_fuzzy_find)
  vim.keymap.set("n", "so", builtin.oldfiles)
  vim.keymap.set("n", "s/", function()
    require("telescope.builtin").grep_string {
      search = vim.fn.input "Grep > ",
      -- vimgrep_arguments = g
      --   "rg",
      --   "--color=never",
      --   "--no-heading",
      --   "--with-filename",
      --   "--line-number",
      --   "--column",
      --   "--smart-case",
      --   "--hidden",
      -- },
    }
  end)
  vim.keymap.set("n", "sk", builtin.keymaps)
  vim.keymap.set("n", "<leader><space>", builtin.buffers)
  vim.keymap.set("n", "sp", telescope.extensions.projects.projects)
  vim.keymap.set("n", "sc", builtin.git_status)
  vim.keymap.set("n", "sw", function()
    builtin.grep_string {
      -- vimgrep_arguments = {
      --   "rg",
      --   "--color=never",
      --   "--no-heading",
      --   "--with-filename",
      --   "--line-number",
      --   "--column",
      --   "--smart-case",
      --   "--hidden",
      -- },
    }
  end)
  vim.keymap.set("n", "ss", builtin.lsp_document_symbols)
  vim.keymap.set("n", "sb", builtin.git_branches)
end
