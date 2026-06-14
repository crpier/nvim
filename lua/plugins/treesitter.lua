return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    },
    config = function()
      -- Neovim nightly and nvim-treesitter can briefly disagree about the
      -- shape of query matches during injected-language parsing in preview
      -- buffers (for example Snacks picker previews). The upstream
      -- nvim-treesitter `#downcase!` directive assumes its capture is always a
      -- single TSNode; when it receives nil/a capture-list instead, it crashes
      -- from `vim.treesitter.get_node_text()` with `attempt to call method
      -- 'range' (a nil value)`. Keep the directive behavior, but make it
      -- defensive so a malformed/stale injection match is ignored instead of
      -- breaking highlighting.
      local function install_safe_downcase_directive()
        local opts = vim.fn.has "nvim-0.10" == 1 and { force = true, all = false } or true
        vim.treesitter.query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
          local id = pred[2]
          local nodes = match[id]
          local node = type(nodes) == "table" and nodes[1] or nodes
          if type(node) ~= "userdata" then
            return
          end

          local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr, { metadata = metadata[id] })
          if not ok then
            return
          end

          if not metadata[id] then
            metadata[id] = {}
          end
          metadata[id].text = string.lower(text or "")
        end, opts)
      end

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
      }
      require("nvim-treesitter.configs").setup(config)
      install_safe_downcase_directive()

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
      local swap = require "nvim-treesitter-textobjects.swap"
      local move = require "nvim-treesitter-textobjects.move"
      local shared = require "nvim-treesitter-textobjects.shared"

      local function select_textobject(query)
        return function()
          select.select_textobject(query, "textobjects")
        end
      end

      local function swap_textobject(direction, query)
        return function()
          swap[direction](query, "textobjects")
        end
      end

      local function move_to_textobject(direction, query)
        return function()
          move[direction](query, "textobjects")
        end
      end

      local function textobject_lines(query, label)
        local bufnr = vim.api.nvim_get_current_buf()
        local ok, range = pcall(shared.textobject_at_point, query, "textobjects", bufnr, nil, { lookahead = true })
        if not ok then
          vim.notify(range, vim.log.levels.ERROR)
          return nil, nil
        end
        if range == nil then
          vim.notify("No " .. label .. " textobject found", vim.log.levels.WARN)
          return nil, nil
        end

        return vim.api.nvim_buf_get_text(bufnr, range[1], range[2], range[4], range[5], {}), bufnr
      end

      local function peek_textobject(query, label)
        return function()
          local lines, source_bufnr = textobject_lines(query, label)
          if lines == nil or #lines == 0 then
            return
          end

          local preview_bufnr, winid = vim.lsp.util.open_floating_preview(lines, vim.bo[source_bufnr].filetype, {
            border = "none",
            focusable = true,
            max_height = math.max(1, math.floor(vim.o.lines * 0.5)),
            max_width = math.max(20, math.floor(vim.o.columns * 0.8)),
          })
          local close_preview = function()
            if vim.api.nvim_win_is_valid(winid) then
              vim.api.nvim_win_close(winid, true)
            end
          end
          vim.keymap.set("n", "q", close_preview, { buffer = preview_bufnr, nowait = true, silent = true })
          vim.keymap.set("n", "<Esc>", close_preview, { buffer = preview_bufnr, nowait = true, silent = true })
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

      keymaps.set(
        "n",
        "<leader>tsp",
        swap_textobject("swap_next", "@parameter.inner"),
        { desc = "Swap parameter with next", group = group }
      )
      keymaps.set(
        "n",
        "<leader>tsf",
        swap_textobject("swap_next", "@function.outer"),
        { desc = "Swap function with next", group = group }
      )
      keymaps.set(
        "n",
        "<leader>tsc",
        swap_textobject("swap_next", "@class.outer"),
        { desc = "Swap class with next", group = group }
      )
      keymaps.set(
        "n",
        "<leader>tsP",
        swap_textobject("swap_previous", "@parameter.inner"),
        { desc = "Swap parameter with previous", group = group }
      )
      keymaps.set(
        "n",
        "<leader>tsF",
        swap_textobject("swap_previous", "@function.outer"),
        { desc = "Swap function with previous", group = group }
      )
      keymaps.set(
        "n",
        "<leader>tsC",
        swap_textobject("swap_previous", "@class.outer"),
        { desc = "Swap class with previous", group = group }
      )

      keymaps.set(
        { "n", "x", "o" },
        "]m",
        move_to_textobject("goto_next_start", "@function.outer"),
        { desc = "Next function start", group = group }
      )
      keymaps.set(
        { "n", "x", "o" },
        "]]",
        move_to_textobject("goto_next_start", "@class.outer"),
        { desc = "Next class start", group = group }
      )
      keymaps.set(
        { "n", "x", "o" },
        "]M",
        move_to_textobject("goto_next_end", "@function.outer"),
        { desc = "Next function end", group = group }
      )
      keymaps.set(
        { "n", "x", "o" },
        "][",
        move_to_textobject("goto_next_end", "@class.outer"),
        { desc = "Next class end", group = group }
      )
      keymaps.set(
        { "n", "x", "o" },
        "[m",
        move_to_textobject("goto_previous_start", "@function.outer"),
        { desc = "Previous function start", group = group }
      )
      keymaps.set(
        { "n", "x", "o" },
        "[[",
        move_to_textobject("goto_previous_start", "@class.outer"),
        { desc = "Previous class start", group = group }
      )
      keymaps.set(
        { "n", "x", "o" },
        "[M",
        move_to_textobject("goto_previous_end", "@function.outer"),
        { desc = "Previous function end", group = group }
      )
      keymaps.set(
        { "n", "x", "o" },
        "[]",
        move_to_textobject("goto_previous_end", "@class.outer"),
        { desc = "Previous class end", group = group }
      )

      keymaps.set(
        "n",
        "<leader>k",
        peek_textobject("@function.outer", "function"),
        { desc = "Peek function", group = group }
      )
      keymaps.set("n", "<leader>K", peek_textobject("@class.outer", "class"), { desc = "Peek class", group = group })

      local usage = require "config.treesitter_usage"
      keymaps.set("n", "<C-n>", usage.goto_next_usage, { desc = "Next usage", group = "treesitter-usage" })
      keymaps.set("n", "<C-p>", usage.goto_previous_usage, { desc = "Previous usage", group = "treesitter-usage" })
    end,
  },
}
