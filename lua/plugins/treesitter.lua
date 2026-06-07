return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
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

      require("nvim-treesitter-textobjects").setup {
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      }

      local keymaps = require "config.keymaps"
      local group = "treesitter-textobjects"
      local select = require "nvim-treesitter-textobjects.select"
      local function select_textobject(query)
        return function()
          select.select_textobject(query, "textobjects")
        end
      end

      local function select_node(node)
        local start_row, start_col, end_row, end_col = node:range()
        if end_col == 0 then
          end_row = end_row - 1
          end_col = #vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, true)[1]
        end

        if vim.api.nvim_get_mode().mode ~= "v" then
          vim.cmd.normal { "v", bang = true }
        end
        vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
        vim.cmd "normal! o"
        vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })
      end

      local function decorated_definition_contains(node, child_type)
        for index = 0, node:named_child_count() - 1 do
          if node:named_child(index):type() == child_type then
            return true
          end
        end

        return false
      end

      local function containing_decorated_definition(child_type)
        local cursor = vim.api.nvim_win_get_cursor(0)
        local ok, parser = pcall(vim.treesitter.get_parser, 0)
        if not ok then
          return nil
        end

        local tree = parser:parse()[1]
        if tree == nil then
          return nil
        end

        local row = cursor[1] - 1
        local col = cursor[2]
        local node = tree:root():named_descendant_for_range(row, col, row, col + 1)
        while node ~= nil do
          if node:type() == "decorated_definition" and decorated_definition_contains(node, child_type) then
            return node
          end
          node = node:parent()
        end

        return nil
      end

      --- Select the current function for the `af` text object.
      ---
      --- For Python decorated functions, prefer the enclosing `decorated_definition`
      --- node so decorators are included in the outer-function selection.
      local function select_function_outer()
        local decorated_definition = containing_decorated_definition "function_definition"
        if decorated_definition ~= nil then
          select_node(decorated_definition)
          return
        end

        select.select_textobject("@function.outer", "textobjects")
      end

      keymaps.set(
        { "x", "o" },
        "aa",
        select_textobject "@parameter.outer",
        { desc = "Around parameter", group = group }
      )
      keymaps.set(
        { "x", "o" },
        "ia",
        select_textobject "@parameter.inner",
        { desc = "Inside parameter", group = group }
      )
      --- Select the current class for the `ac` text object.
      ---
      --- For Python decorated classes, prefer the enclosing `decorated_definition`
      --- node so decorators are included in the outer-class selection.
      local function select_class_outer()
        local decorated_definition = containing_decorated_definition "class_definition"
        if decorated_definition ~= nil then
          select_node(decorated_definition)
          return
        end

        select.select_textobject("@class.outer", "textobjects")
      end

      keymaps.set({ "x", "o" }, "af", select_function_outer, { desc = "Around function", group = group })
      keymaps.set({ "x", "o" }, "if", select_textobject "@function.inner", { desc = "Inside function", group = group })
      keymaps.set({ "x", "o" }, "ac", select_class_outer, { desc = "Around class", group = group })
      keymaps.set({ "x", "o" }, "ic", select_textobject "@class.inner", { desc = "Inside class", group = group })

      local usage = require "config.treesitter_usage"
      keymaps.set("n", "<C-n>", usage.goto_next_usage, { desc = "Next usage", group = "treesitter-usage" })
      keymaps.set("n", "<C-p>", usage.goto_previous_usage, { desc = "Previous usage", group = "treesitter-usage" })
    end,
  },
}
