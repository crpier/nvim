-- TODO: moar textobjects
-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
return {
  {
    "nvim-treesitter/nvim-treesitter",
    run = { ":TSUpdate" },
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects", "nvim-treesitter/nvim-treesitter-refactor" },
    config = function()
      local config = {
        ensure_installed = {},
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "markdown" },
        },
        -- TODO: Maybe this should depend on the language?
        indent = {
          enable = true,
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
            enable = true,
            keymaps = {
              smart_rename = "<leader>trn",
            },
          },
          highlight_definitions = {
            -- TODO: this should be enabled if there is no LSP, or if the lsp does not support `textDocument_documentHighlight`
            -- enable = require("config.utils").load_local_options().treesitter_highlight_definitions,
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
              -- TODO: When using LSP highlight, could we also make the LSP get us to the next reference?
              goto_next_usage = "<C-n>",
              goto_previous_usage = "<C-p>",
            },
          },
          query_linter = {
            enable = true,
            use_virtual_text = true,
            lint_events = { "BufWrite", "CursorHold" },
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
              ["]p"] = "@parameter.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
              ["]P"] = "@parameter.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
              ["[p"] = "@parameter.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
              ["[P"] = "@parameter.outer",
            },
            -- TODO: go to next/prev param
          },
          swap = {
            enable = true,
            swap_next = {
              -- TODO: I'd like more consistency in the mnemonics
              ["<leader>sp"] = "@parameter.inner",
              ["<leader>sf"] = "@function.outer",
              ["<leader>sc"] = "@class.outer",
            },
            swap_previous = {
              ["<leader>sP"] = "@parameter.inner",
              ["<leader>sF"] = "@function.outer",
              ["<leader>sC"] = "@class.outer",
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
  {
    "nvim-treesitter/playground",
    cmd = "TSPlaygroundToggle",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
