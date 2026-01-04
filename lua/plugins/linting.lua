return {
  {
    "mfussenegger/nvim-lint",
    lazy = false,
    config = function()
      local lint = require "lint"

      -- Helper function to conditionally enable linter if available
      local function use_linter_if_available(filetype, linter)
        if vim.fn.executable(linter) == 1 then
          lint.linters_by_ft[filetype] = lint.linters_by_ft[filetype] or {}
          table.insert(lint.linters_by_ft[filetype], linter)
        end
      end

      -- Enable linters
      lint.linters_by_ft = lint.linters_by_ft or {}
      if require("config.utils").ON_LOCAL then
        lint.linters_by_ft["lua"] = { "luacheck" }
        lint.linters_by_ft["python"] = { "ruff" }
        lint.linters_by_ft["terraform"] = { "tflint" }
      else
        lint.linters_by_ft["lua"] = nil
        lint.linters_by_ft["python"] = nil
        lint.linters_by_ft["terraform"] = nil
      end

      -- Disable default linters (clear before conditionally adding)
      lint.linters_by_ft["dockerfile"] = nil
      lint.linters_by_ft["json"] = nil
      lint.linters_by_ft["markdown"] = nil
      lint.linters_by_ft["text"] = nil
      lint.linters_by_ft["clojure"] = nil
      lint.linters_by_ft["inko"] = nil
      lint.linters_by_ft["janet"] = nil
      lint.linters_by_ft["rst"] = nil
      lint.linters_by_ft["ruby"] = nil
      lint.linters_by_ft["Avante"] = nil

      -- Conditionally enable linters if they're installed
      use_linter_if_available("dockerfile", "hadolint")
      use_linter_if_available("json", "jsonlint")

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      -- TODO: this looks like something that should be configured outside of this repo,
      -- potentiall to add "TextChanged" on some machines
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
