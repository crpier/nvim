return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "VeryLazy",
    cond = function()
      return require("config.utils").load_local_options().supermaven_enabled
    end,
    config = function()
      require("supermaven-nvim").setup {
        keymaps = {
          accept_suggestion = "<S-Tab>",
          clear_suggestion = "<S-BS>",
          accept_word = "<S-Esc>",
        },
        log_level = "off",
      }
    end,
  },
}
