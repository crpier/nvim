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
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
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
      {
        "<leader>e",
        function()
          require("snacks").explorer()
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
      explorer = {},
      scratch = {},
    },
  },
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    event = "VeryLazy",
    keys = {
      { "<leader>oF", "<cmd>ObsidianQuickSwitch<cr>", desc = "Open all notes" },
      { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "Create new note" },
      { "<leader>odd", "<cmd>ObsidianDailies<cr>", desc = "Open daily notes picker" },
      { "<leader>ody", "<cmd>ObsidianYesterday<cr>", desc = "Open yesterday's daily note" },
      { "<leader>odo", "<cmd>ObsidianTomorrow<cr>", desc = "Open tomorrow's daily note" },
      { "<leader>oo", "<cmd>ObsidianQuickSwitch Todo<cr>", desc = "Open Todo note" },
      { "<leader>ot", "<cmd>ObsidianToday<cr>", desc = "Open today's daily note" },
      { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Live grep through notes" },
      { "<leader>oa", "<cmd>ObsidianTags<cr>", desc = "Open note tags picker" },
      { "<leader>orn", "<cmd>ObsidianRename<cr>", desc = "Rename note" },
      {
        "<leader>of",
        function()
          require("telescope.builtin").find_files {
            cwd = "~/vault",
            find_command = { "fd", "--type", "f", "--color", "never", "--exclude", "daily" },
          }
        end,
        desc = "Open (non-daily) notes picker",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      note_frontmatter_func = function(note)
        if note.title then
          note:add_alias(note.title)
        end

        local out = { tags = note.tags }

        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        return out
      end,

      note_path_func = function(spec)
        local path = spec.dir / tostring(spec.title)
        return path:with_suffix ".md"
      end,

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
        folder = "daybook",
        date_format = "%Y/%Y-%m-%d",
        default_tags = { "daybook" },
        template = "daybook",
      },
      ui = {
        enable = false,
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
}
