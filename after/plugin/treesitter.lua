------ TreeSitter ------
local on_local_machine = (os.getenv "SSH_CLIENT" == nil)
local ok_config, treesitter_configs = pcall(require, "nvim-treesitter.configs")
if ok_config then
  local ok_textobjects = pcall(require, "nvim-treesitter-textobjects")
  local config = {
    ensure_installed = { "python", "bash", "html", "javascript" },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { "markdown" },
    },
    indent = {
      enable = false,
      --disable = { 'python' },
    },
    incremental_selection = {
      enable = on_local_machine,
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
        enable = on_local_machine,
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
      query_linter = {
        enable = on_local_machine,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },
    },
  }
  if ok_textobjects then
    config.textobjects = {
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
          ["<leader>a"] = "@parameter.inner",
        },
        swap_previous = {
          ["<leader>A"] = "@parameter.inner",
        },
      },
    }
  end
  treesitter_configs.setup(config)
end
