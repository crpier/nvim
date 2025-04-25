return {
  {
    "chrisgrieser/nvim-various-textobjs",
    event = "VeryLazy",
    opts = {
      keymaps = {
        useDefaults = true,
      },
    },
    keys = {
      {
        "dsi",
        function()
          -- select outer indentation
          require("various-textobjs").indentation("outer", "outer")

          -- plugin only switches to visual mode when a textobj has been found
          local indentationFound = vim.fn.mode():find "V"
          if not indentationFound then
            return
          end

          -- dedent indentation
          vim.cmd.normal { "<", bang = true }

          -- delete surrounding lines
          local endBorderLn = vim.api.nvim_buf_get_mark(0, ">")[1]
          local startBorderLn = vim.api.nvim_buf_get_mark(0, "<")[1]
          vim.cmd(tostring(endBorderLn) .. " delete") -- delete end first so line index is not shifted
          vim.cmd(tostring(startBorderLn) .. " delete")
        end,
        mode = "n",
        desc = "Delete Surrounding Indentation",
      },
      -- TODO: mapping to copy text object and paste it right after
      {
        ">p",
        function()
          require("various-textobjs").lastChange()
          local changeFound = vim.fn.mode():find "v"
          if changeFound then
            vim.cmd.normal { ">", bang = true }
          end
        end,
        desc = "Indent last paste",
      },
      {
        "<p",
        function()
          require("various-textobjs").lastChange()
          local changeFound = vim.fn.mode():find "v"
          if changeFound then
            vim.cmd.normal { "<", bang = true }
          end
        end,
        desc = "Unindent last paste",
      },
    },
  },
  {
    "folke/snacks.nvim",
    lazy = false,
    keys = {
      {
        "<leader>bd",
        function()
          require("snacks").bufdelete()
        end,
        desc = "Close buffer (like `:bd` but smart)",
      },
      {
        "yot",
        function()
          if require("snacks.dim").enabled then
            require("snacks.dim").disable()
          else
            require("snacks.dim").enable()
          end
        end,
        desc = "Toggle dimming",
      },
      {
        "<leader>lg",
        function()
          require("snacks.lazygit").open()
        end,
        desc = "Open lazygit",
      },
      -- TODO: add keymap for `snacks.debug.run()` inside the scratch buffer
      {
        "<leader>.",
        function()
          require("snacks").scratch()
        end,
        desc = "Toggle Scratch Buffer",
      },
      {
        "<leader>S",
        function()
          require("snacks").scratch.select()
        end,
        desc = "Select Scratch Buffer",
      },
      {
        "<C-/>",
        function()
          require("snacks").terminal.toggle()
        end,
        desc = "Toggle bottom terminal",
      },
    },
    ---@type snacks.Config
    opts = {
      -- TODO: I guess this can take a few configs when I find out what
      -- markers are conflicting
      -- statuscolumn = {},
      bigfile = {},
      dim = {},
      terminal = {},
      quickfile = {},
      lazygit = {},
      input = {},
      scope = {},
      -- TODO: allow executing python scratch
      scratch = {},
      picker = {
        sources = {
          explorer = {
            -- your explorer picker configuration comes here
            -- or leave it empty to use the default settings
          },
        },
      },
    },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {
      label = {
        after = false,
        before = true,
      },
      modes = {
        search = {
          enabled = false,
        },
        char = {
          config = function(opts)
            -- autohide flash when in operator-pending mode
            local operator_pending = vim.fn.mode(true):find "no"
            opts.autohide = operator_pending
            opts.highlight.backdrop = not operator_pending
          end,
          char_actions = function()
            return { [";"] = "next", [","] = "prev" }
          end,
        },
      },
    },
    -- TODO: I should use `stylua: ignore` for more keymaps
    -- stylua: ignore
    keys = {
      -- TODO: make this jump to lines instead
      { "dg", mode = "n",
        function()
          require("flash").jump {
            ---@param win integer
            matcher = function(win)
              ---@param diag vim.Diagnostic
              return vim.tbl_map(function(diag)
                return {
                  pos = { diag.lnum + 1, diag.col },
                  end_pos = { diag.end_lnum + 1, diag.end_col - 1 },
                }
              end, vim.diagnostic.get(vim.api.nvim_win_get_buf(win)))
            end,
            action = function(match, state)
              vim.api.nvim_win_call(match.win, function()
                vim.api.nvim_win_set_cursor(match.win, match.pos)
                vim.diagnostic.open_float()
              end)
              state:restore()
            end,
          }
        end,
        desc = "Flash display diagnostic",
      },
      { "S", mode = "n", function() require("flash").jump() end, desc = "Flash jump" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {
    -- TODO: Actually use this lol
    "stevearc/overseer.nvim",
    lazy = false,
    config = function()
      require("overseer").setup()
      require("overseer").register_template {}
    end,
  },
  {
    "echasnovski/mini.files",
    -- TODO: lazy needs to be false for the case where I open a dir from shell
    -- (e.g. `nvim .`). Find a way to lazily open the explorer in this case too.
    lazy = false,
    opts = {},
    keys = {
      {
        "<leader>e",
        mode = "n",
        function()
          MiniFiles.open(vim.fn.expand "%:s")
        end,
        desc = "Toggle Explorer",
      },
    },
  },
}
