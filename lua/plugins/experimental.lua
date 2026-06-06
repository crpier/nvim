return {
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
        require("config.pickers").non_daily_notes,
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
  { "sindrets/diffview.nvim", cmd = { "DiffviewOpen" } },
}
