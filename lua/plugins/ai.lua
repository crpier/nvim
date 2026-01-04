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
      return require("config.utils").load_local_options().avante_enabled
    end,
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      -- add any opts here
      -- for example
      provider = "claude",
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-sonnet-4-5-20250929",
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
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "zbirenbaum/copilot.lua", -- for providers='copilot'
    },
  },
}
