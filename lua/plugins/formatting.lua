return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "gq",
        function()
          require("conform").format { async = true, lsp_format = "fallback" }
        end,
        desc = "Format buffer",
      },
    },
    opts = {
      notify_on_error = true,
      formatters_by_ft = require("config.toolchain").formatters_by_ft(),
    },
  },
}
