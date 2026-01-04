return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
      vim.cmd.colorscheme "catppuccin-macchiato"
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "SmiteshP/nvim-navic",
    },
    config = function()
      local lualine = require "lualine"
      local navic = require "nvim-navic"
      local navic_part = {
        function()
          return navic.get_location()
        end,
        cond = navic.is_available,
      }

      lualine.setup {
        options = {
          icons_enabled = true,
          component_separators = "|",
          section_separators = "",
        },
        sections = {
          lualine_a = {},
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            navic_part,
          },
          lualine_x = { "overseer" },
          lualine_y = {},
          -- TODO: make this configurable from local config
          -- for some reason, this slows neovim down considerably on macos
          -- lualine_y = { "filetype" },
          lualine_z = { "location" },
        },
      }
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    config = function()
      require("ibl").setup {}
    end,
  },

  {
    "akinsho/bufferline.nvim",
    lazy = false,
    config = function()
      require("bufferline").setup {}
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show { global = false }
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
}
