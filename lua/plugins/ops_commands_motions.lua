return {
  {
    "kylechui/nvim-surround",
    -- TODO: check if we can add keys
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },

  {
    "numToStr/Comment.nvim",
    -- TODO: check if we can add keys
    lazy = false,
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
      },
      {
        "mcs",
        function()
          require("cellular-automaton").start_animation "scramble"
        end,
      },
      {
        "mcl",
        function()
          require("cellular-automaton").start_animation "game_of_life"
        end,
      },
    },
  },
  { "mbbill/undotree", cmd = "UndotreeToggle" },
  {
    "tummetott/unimpaired.nvim",
    event = "VeryLazy",
    config = function()
      require("unimpaired").setup {
        keymaps = {
          -- used by the tags plugin
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
  -- TODO: check https://github.com/lewis6991/hover.nvim out
}
