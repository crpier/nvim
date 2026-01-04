return {
  {
    "kylechui/nvim-surround",
    keys = {
      { "ys", mode = "n" },
      { "ds", mode = "n" },
      { "cs", mode = "n" },
      { "S", mode = "x" },
    },
    config = function()
      require("nvim-surround").setup()
    end,
  },

  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup()
    end,
  },
  {
    "crpier/fast-jobs.nvim",
    keys = {
      {
        "yrq",
        function()
          require("fast-jobs").create_window()
        end,
      },
      {
        "yr1",
        function()
          require("fast-jobs").run_cmd_async(1)
        end,
      },
      {
        "yr2",
        function()
          require("fast-jobs").run_cmd_async(2)
        end,
      },
      {
        "yr3",
        function()
          require("fast-jobs").run_cmd_async(3)
        end,
      },
    },
  },
  { "ojroques/vim-oscyank", keys = { { "<leader>y", ":OSCYankVisual<CR>", mode = "v" } } },
  {
    "eandrju/cellular-automaton.nvim",
    keys = {
      {
        "mcr",
        function()
          require("cellular-automaton").start_animation "make_it_rain"
        end,
        desc = "Cellular Automaton: Make it Rain",
      },
      {
        "mcs",
        function()
          require("cellular-automaton").start_animation "scramble"
        end,
        desc = "Cellular Automaton: Scramble",
      },
      {
        "mcl",
        function()
          require("cellular-automaton").start_animation "game_of_life"
        end,
        desc = "Cellular Automaton: Game of Life",
      },
    },
  },
  { "mbbill/undotree", cmd = "UndotreeToggle" },
  {
    "tummetott/unimpaired.nvim",
    event = "VeryLazy",
    config = function()
      -- Keymaps defined in https://github.com/tummetott/unimpaired.nvim/blob/8e504ba95dd10a687f4e4dacd5e19db221b88534/lua/unimpaired/config.lua
      require("unimpaired").setup {
        keymaps = {
          -- used by the `todo-comments`
          tfirst = false,
          tlast = false,
          tnext = false,
          tprev = false,

          -- Doesn't really work, because I can't re-enable the color column.
          -- I should open an issue? 🤔
          disable_colorcolumn = false,
          enable_colorcolumn = false,
          toggle_colorcolumn = false,
        },
      }
    end,
  },
}
