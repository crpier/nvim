return {
  {
    "hedyhli/outline.nvim",
    cmd = "Outline",
    config = function()
      require("outline").setup {}
    end,
    keys = { {
      "<leader>so",
      function()
        require("outline").toggle()
      end,
    } },
  },
}
