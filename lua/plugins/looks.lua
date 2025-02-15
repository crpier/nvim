-- from https://github.com/nvimdev/dashboard-nvim/wiki/Ascii-Header-Text
local header_2 = {
  "",
  "     ⠀⠀⠀⠀⠀⠀⠀⡴⠞⠉⢉⣭⣿⣿⠿⣳⣤⠴⠖⠛⣛⣿⣿⡷⠖⣶⣤⡀⠀⠀⠀  ",
  "   ⠀⠀⠀⠀⠀⠀⠀⣼⠁⢀⣶⢻⡟⠿⠋⣴⠿⢻⣧⡴⠟⠋⠿⠛⠠⠾⢛⣵⣿⠀⠀⠀⠀  ",
  "   ⣼⣿⡿⢶⣄⠀⢀⡇⢀⡿⠁⠈⠀⠀⣀⣉⣀⠘⣿⠀⠀⣀⣀⠀⠀⠀⠛⡹⠋⠀⠀⠀⠀  ",
  "   ⣭⣤⡈⢑⣼⣻⣿⣧⡌⠁⠀⢀⣴⠟⠋⠉⠉⠛⣿⣴⠟⠋⠙⠻⣦⡰⣞⠁⢀⣤⣦⣤⠀  ",
  "   ⠀⠀⣰⢫⣾⠋⣽⠟⠑⠛⢠⡟⠁⠀⠀⠀⠀⠀⠈⢻⡄⠀⠀⠀⠘⣷⡈⠻⣍⠤⢤⣌⣀  ",
  "   ⢀⡞⣡⡌⠁⠀⠀⠀⠀⢀⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⢿⡀⠀⠀⠀⠸⣇⠀⢾⣷⢤⣬⣉  ",
  "   ⡞⣼⣿⣤⣄⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⣿⠀⠸⣿⣇⠈⠻  ",
  "   ⢰⣿⡿⢹⠃⠀⣠⠤⠶⣼⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⣿⠀⠀⣿⠛⡄⠀  ",
  "   ⠈⠉⠁⠀⠀⠀⡟⡀⠀⠈⡗⠲⠶⠦⢤⣤⣤⣄⣀⣀⣸⣧⣤⣤⠤⠤⣿⣀⡀⠉⣼⡇⠀  ",
  "   ⣿⣴⣴⡆⠀⠀⠻⣄⠀⠀⠡⠀⠀⠀⠈⠛⠋⠀⠀⠀⡈⠀⠻⠟⠀⢀⠋⠉⠙⢷⡿⡇⠀  ",
  "   ⣻⡿⠏⠁⠀⠀⢠⡟⠀⠀⠀⠣⡀⠀⠀⠀⠀⠀⢀⣄⠀⠀⠀⠀⢀⠈⠀⢀⣀⡾⣴⠃⠀  ",
  "   ⢿⠛⠀⠀⠀⠀⢸⠁⠀⠀⠀⠀⠈⠢⠄⣀⠠⠼⣁⠀⡱⠤⠤⠐⠁⠀⠀⣸⠋⢻⡟⠀⠀  ",
  "   ⠈⢧⣀⣤⣶⡄⠘⣆⠀⠀⠀⠀⠀⠀⠀⢀⣤⠖⠛⠻⣄⠀⠀⠀⢀⣠⡾⠋⢀⡞⠀⠀⠀  ",
  "   ⠀⠀⠻⣿⣿⡇⠀⠈⠓⢦⣤⣤⣤⡤⠞⠉⠀⠀⠀⠀⠈⠛⠒⠚⢩⡅⣠⡴⠋⠀⠀⠀⠀  ",
  "   ⠀⠀⠀⠈⠻⢧⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⣻⠿⠋⠀⠀⠀⠀⠀⠀  ",
  "   ⠀⠀⠀⠀⠀⠀⠉⠓⠶⣤⣄⣀⡀⠀⠀⠀⠀⠀⢀⣀⣠⡴⠖⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀  ",
  "",
  "",
}

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
    lazy = false,
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
          lualine_x = { "" },
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
      require("ibl").setup {
        exclude = { filetypes = { "dashboard" } },
      }
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
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    config = function()
      require("dashboard").setup {
        theme = "doom",
        disable_move = true,
        config = {
          header = header_2,
          center = {
            {
              icon = "🚀",
              icon_hl = "group",
              desc = " Open Projects",
              desc_hl = "group",
              key = "sp",
              key_hl = "group",
              key_format = " [%s]", -- `%s` will be substituted with value of `key`
              action = function()
                require("telescope").extensions.project.project {}
              end,
            },
            {
              icon = "👷",
              icon_hl = "group",
              desc = " Open file in cwd",
              desc_hl = "group",
              key = "sf",
              key_hl = "group",
              key_format = " [%s]", -- `%s` will be substituted with value of `key`
              action = function()
                -- TODO: use find_files if not in a git repo
                require("telescope.builtin").git_files { hidden = true }
              end,
            },
            {
              icon = "🔍",
              icon_hl = "group",
              desc = " Open recent files",
              desc_hl = "group",
              key = "so",
              key_hl = "group",
              key_format = " [%s]", -- `%s` will be substituted with value of `key`
              action = function()
                require("telescope.builtin").oldfiles()
              end,
            },
            {
              icon = "🤦",
              icon_hl = "group",
              desc = " Reopen last file",
              desc_hl = "group",
              key = "o",
              key_hl = "group",
              key_format = " [%s]", -- `%s` will be substituted with value of `key`
              action = function()
                vim.cmd [[ e#<1 ]]
              end,
            },
            {
              icon = "🔥",
              icon_hl = "group",
              desc = " Open nvim config",
              desc_hl = "group",
              key = "n",
              key_hl = "group",
              key_format = " [%s]", -- `%s` will be substituted with value of `key`
              action = function()
                require("telescope.builtin").find_files { cwd = vim.fn.stdpath "config" }
              end,
            },
            {
              icon = "🐐",
              icon_hl = "group",
              desc = " Open dotfiles",
              desc_hl = "group",
              key = ".",
              key_hl = "group",
              key_format = " [%s]", -- `%s` will be substituted with value of `key`
              action = function()
                require("telescope.builtin").find_files {
                  cwd = vim.fn.expand "~/.dotfiles",
                  hidden = true,
                }
              end,
            },
          },
          footer = {
            "Startuptime: " .. require("lazy.stats").track "UIEnter" .. " ms",
            "Plugins: "
              .. require("lazy").stats().loaded
              .. " loaded / "
              .. require("lazy").stats().count
              .. " installed",
          },
        },
      }
    end,
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
  },
}
