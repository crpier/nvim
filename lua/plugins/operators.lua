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
  { "mbbill/undotree", cmd = "UndotreeToggle" },
}
