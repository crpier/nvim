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
  { "mbbill/undotree", cmd = "UndotreeToggle" },
}
