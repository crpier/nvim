------ LSP ------
local ON_LOCAL = os.getenv "SSH_CLIENT" == nil

local border = {
  { "╭", "Normal" },
  { "─", "Normal" },
  { "╮", "Normal" },
  { "│", "Normal" },
  { "╯", "Normal" },
  { "─", "Normal" },
  { "╰", "Normal" },
  { "│", "Normal" },
}

local handlers = {
  ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single", style = "minimal" }),
  ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
}

-- Actual LSP setup
local ok_mason, mason = pcall(require, "mason")
if ok_mason then
  mason.setup()
  require("mason-lspconfig").setup {
    -- TODO: only when not on ssh
    ensure_installed = {
      "pyright",
    },
  }
  local ok_navic, navic = pcall(require, "nvim-navic")
  if ok_navic then
    navic.setup {}
  end
  local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
  local lsp_attach = function(client, bufnr)
    if client.server_capabilities.documentSymbolProvider and ok_navic then
      navic.attach(client, bufnr)
    end
  end
  local lspconfig = require "lspconfig"
  require("mason-lspconfig").setup_handlers {
    function(server_name)
      lspconfig[server_name].setup {
        on_attach = lsp_attach,
        capabilities = lsp_capabilities,
        handlers = handlers,
      }
    end,
  }
  -- some lsp maps
  vim.keymap.set("n", "gd", vim.lsp.buf.definition)
  vim.keymap.set("n", "K", vim.lsp.buf.hover)
  vim.keymap.set("n", "gr", vim.lsp.buf.references)
  -- vim.keymap.set("n", "gq", vim.lsp.buf.format)
  vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump { count = 1, float = true }
  end)
  vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump { count = -1, float = true }
  end)
  vim.keymap.set("n", "d;", vim.diagnostic.open_float)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
  vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<CR>")
  vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<CR>")

  vim.diagnostic.config {
    float = {
      source = true,
      border = "rounded",
    },
  }

  -- fidget
  require("fidget").setup()
end

-- nvim-lint
local lint_ok, lint = pcall(require, "lint")
if lint_ok and ON_LOCAL then
  -- TODO: ensure these are installed by Mason, but not on SSH
  lint.linters_by_ft = lint.linters_by_ft or {}
  -- TODO: use hadolint if available
  lint.linters_by_ft["dockerfile"] = nil
  -- TODO: use jsonlint if available
  lint.linters_by_ft["json"] = nil
  lint.linters_by_ft["terraform"] = { "tflint" }
  lint.linters_by_ft["lua"] = { "luacheck" }
  lint.linters_by_ft["python"] = { "mypy", "ruff" }

  -- disable default linters
  lint.linters_by_ft["markdown"] = nil
  lint.linters_by_ft["text"] = nil
  lint.linters_by_ft["clojure"] = nil
  lint.linters_by_ft["inko"] = nil
  lint.linters_by_ft["janet"] = nil
  lint.linters_by_ft["rst"] = nil
  lint.linters_by_ft["ruby"] = nil
  lint.linters_by_ft["Avante"] = nil

  -- Create autocommand which carries out the actual linting
  -- on the specified events.
  local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = lint_augroup,
    callback = function()
      require("lint").try_lint()
    end,
  })
end

-- conform
local ok_conform, conform = pcall(require, "conform")
if ok_conform and ON_LOCAL then
  conform.setup {
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
  }
  vim.keymap.set("n", "gq", conform.format)
end
