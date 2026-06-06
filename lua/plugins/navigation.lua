local pickers = require "config.pickers"
local picker_keys = pickers.keys()

return {
  {
    "folke/snacks.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    keys = vim.list_extend({
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
        desc = "Toggle file explorer",
      },
    }, picker_keys),
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
      picker = {
        actions = {
          qflist = pickers.qflist,
          qflist_all = pickers.qflist_all,
          loclist = pickers.loclist,
        },
        sources = {
          explorer = {
            hidden = true,
          },
        },
      },
    },
  },
}
