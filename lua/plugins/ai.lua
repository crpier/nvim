-- TODO: change key to start avante (or change the treesitter swap key)
return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "VeryLazy",
    cond = function()
      return require("config.utils").load_local_options().supermaven_enabled
    end,
    config = function()
      require("supermaven-nvim").setup {
        keymaps = {
          accept_suggestion = "<S-Tab>",
          clear_suggestion = "<S-BS>",
          accept_word = "<S-Esc>",
        },
        log_level = "off",
      }
    end,
  },
  {
    "yetone/avante.nvim",
    cond = function()
      return require("config.utils").load_local_options().supermaven_enabled
    end,
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      -- add any opts here
      -- for example
      provider = "claude",
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-7-sonnet-latest",
        temperature = 0,
        max_tokens = 4096,
      },
      hints = {
        enabled = false,
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "Avante" },
        },
        ft = { "Avante" },
      },
    },
  },
  -- {
  --   "olimorris/codecompanion.nvim",
  --   lazy = false,
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   config = function()
  --     require("codecompanion").setup {
  --       strategies = {
  --         chat = {
  --           adapter = "anthropic",
  --         },
  --         inline = {
  --           adapter = "anthropic",
  --         }
  --       }
  --     }
  --   end
  -- },
}
