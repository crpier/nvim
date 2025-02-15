return {
  {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    config = function()
      require("quicker").setup {
        constrain_cursor = true,
        follow = {
          -- When quickfix window is open, scroll to closest item to the cursor
          enabled = true,
        },
        keys = {
          {
            ">",
            function()
              require("quicker").expand { before = 2, after = 2, add_to_existing = true }
            end,
            desc = "Expand quickfix context",
          },
          {
            "<",
            function()
              require("quicker").collapse()
            end,
            desc = "Collapse quickfix context",
          },
        },
      }
      vim.keymap.set("n", "<C-Q>", function()
        require("quicker").toggle()
      end, {
        desc = "Toggle quickfix",
      })
    end,
  },
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
  -- lazy.nvim
  -- TODO: toggle a terminal at the bottom with `C-/`
  {
    "folke/snacks.nvim",
    lazy = false,
    keys = {
      {
        -- TODO: isn't there a nicer keymap for this?
        "<leader>bd",
        function()
          require("snacks").bufdelete()
        end,
        desc = "Close buffer",
      },
      {
        "[ot",
        function()
          require("snacks.dim").enable()
        end,
        desc = "Enable dimming",
      },
      {
        "]ot",
        function()
          require("snacks.dim").disable()
        end,
        desc = "Disable dimming",
      },
      {
        "<leader>lg",
        function()
          require("snacks.lazygit").open()
        end,
        desc = "Open lazygit",
      },
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
    },
    ---@type snacks.Config
    opts = {
      -- TODO: I guess this can take a few configs when I find out what
      -- markers are conflicting
      -- statuscolumn = {},
      bigfile = {},
      dim = {},
      explorer = {
        -- your explorer configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
      quickfile = {},
      lazygit = {},
      input = {},
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
}
