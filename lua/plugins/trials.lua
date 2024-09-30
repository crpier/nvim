return {
  {
    "yetone/avante.nvim",
    build = "make",
    cmd = "AvanteToggle",
    dependencies = { "MeanderingProgrammer/render-markdown.nvim", "MunifTanjim/nui.nvim" },
    config = function()
      require("avante_lib").load()
      require("avante").setup {
        ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
        provider = "claude",
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-3-5-sonnet-20240620",
          temperature = 0,
          max_tokens = 4096,
        },
        behaviour = {
          auto_suggestions = false, -- Experimental stage
          auto_set_highlight_group = true,
          auto_set_keymaps = true,
          auto_apply_diff_after_generation = false,
          support_paste_from_clipboard = false,
        },
        mappings = {
          --- @class AvanteConflictMappings
          diff = {
            ours = "co",
            theirs = "ct",
            all_theirs = "ca",
            both = "cb",
            cursor = "cc",
            next = "]x",
            prev = "[x",
          },
          suggestion = {
            accept = "<M-l>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
          jump = {
            next = "]]",
            prev = "[[",
          },
          submit = {
            normal = "<CR>",
            insert = "<C-s>",
          },
        },
        hints = { enabled = false },
        windows = {
          ---@type "right" | "left" | "top" | "bottom"
          position = "right", -- the position of the sidebar
          wrap = true, -- similar to vim.o.wrap
          width = 50, -- default % based on available width
          sidebar_header = {
            align = "center", -- left, center, right for title
            rounded = true,
          },
        },
        highlights = {
          ---@type AvanteConflictHighlights
          diff = {
            current = "DiffText",
            incoming = "DiffAdd",
          },
        },
        --- @class AvanteConflictUserConfig
        diff = {
          autojump = true,
          ---@type string | fun(): any
          list_opener = "copen",
        },
      }
    end,
  },
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    keys = {
      { "<leader>on", "<cmd>ObsidianNew<cr>" },
      { "<leader>od", "<cmd>ObsidianDailies<cr>" },
      { "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>" },
      { "<leader>ot", "<cmd>ObsidianToday<cr>" },
      { "<leader>os", "<cmd>ObsidianSearch<cr>" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "vault",
          path = "~/vault",
        },
      },
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m/%Y-%m-%d",
      },
    },
  },
}