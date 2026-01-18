return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
      "nvim-treesitter/nvim-treesitter-refactor",
    },
    config = function()
      local config = {
        ensure_installed = { "markdown", "markdown_inline" },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "markdown" },
        },
        indent = {
          enable = false,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<c-space>",
            node_incremental = "<c-space>",
            scope_incremental = "<c-s>",
            node_decremental = "<c-backspace>",
          },
        },
        refactor = {
          smart_rename = {
            enable = false,
          },
          highlight_definitions = {
            enable = false,
            clear_on_cursor_move = true,
          },
          navigation = {
            enable = true,
            -- Assign keymaps to false to disable them, e.g. `goto_definition = false`.
            keymaps = {
              goto_definition = false,
              list_definitions = false,
              list_definitions_toc = false,
              goto_next_usage = "<C-n>",
              goto_previous_usage = "<C-p>",
            },
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>tsp"] = "@parameter.inner",
              ["<leader>tsf"] = "@function.outer",
              ["<leader>tsc"] = "@class.outer",
            },
            swap_previous = {
              ["<leader>tsP"] = "@parameter.inner",
              ["<leader>tsF"] = "@function.outer",
              ["<leader>tsC"] = "@class.outer",
            },
          },
          lsp_interop = {
            enable = true,
            border = "none",
            floating_preview_opts = {},
            peek_definition_code = {
              ["<leader>k"] = "@function.outer",
              ["<leader>K"] = "@class.outer",
            },
          },
        },
      }
      require("nvim-treesitter.configs").setup(config)
    end,
  },
}
