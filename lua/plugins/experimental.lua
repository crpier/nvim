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
      statuscolumn = {
        enabled = true,
        left = { "mark", "sign" }, -- priority of signs on the left (high to low)
        right = { "fold", "git" }, -- priority of signs on the right (high to low)
        folds = {
          open = true, -- show open fold icons
          git_hl = false, -- use Git Signs hl for fold icons
        },
        git = {
          patterns = { "GitSign" }, -- patterns to match for git signs
        },
        refresh = 50, -- refresh at most every 50ms
      },
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
          },
        },
      },
    },
  },
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    cmd = { "Obsidian" },
    keys = {
      { "<leader>on", "<cmd>Obsidian new<cr>", desc = "Create new note" },
      { "<leader>odd", "<cmd>Obsidian dailies<cr>", desc = "Open daily notes picker" },
      { "<leader>ody", "<cmd>Obsidian yesterday<cr>", desc = "Open yesterday's daily note" },
      { "<leader>odo", "<cmd>Obsidian tomorrow<cr>", desc = "Open tomorrow's daily note" },
      { "<leader>oo", "<cmd>Obsidian quick_switch Todo<cr>", desc = "Open Todo note" },
      { "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Open today's daily note" },
      { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Live grep through notes" },
      { "<leader>oa", "<cmd>Obsidian tags<cr>", desc = "Open note tags picker" },
      { "<leader>orn", "<cmd>Obsidian rename<cr>", desc = "Rename note" },
      -- TODO: I'd like this to add a space at the end of the prompt
      { "<leader>of", "<cmd>Obsidian quick_switch !daily<cr>", desc = "Open (non-daily) notes picker" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      workspaces = {
        {
          name = "vault",
          path = "~/vault",
        },
      },
      templates = {
        folder = "templates",
      },
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m/%Y-%m-%d",
        template = "daily.md",
      },
      ui = {
        enable = false,
      },
      legacy_commands = false,

      notes_subdir = "limbo",
      new_notes_location = "notes_subdir",

      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
    },
  },
}
