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
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
        markdown = { "markdownlint" },
        javascript = { "prettierd" },
        rust = { "rustfmt" },
        typescriptreact = { "prettierd" },
        go = { "gofmt" },
      },
    },
  },
}
