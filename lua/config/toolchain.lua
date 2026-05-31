local M = {}

local lsp_servers = {
  -- Lua for Neovim configuration
  lua_ls = {},
  -- TypeScript/JavaScript
  ts_ls = {},
  -- Go
  gopls = {},
  -- Rust
  rust_analyzer = {},
  -- Terraform
  terraformls = {},
  -- Markdown
  marksman = {},
}

local formatters_by_ft = {
  lua = { "stylua" },
  python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
  markdown = { "markdownlint" },
  javascript = { "prettierd" },
  rust = { "rustfmt" },
  typescriptreact = { "prettierd" },
  typescript = { "prettierd" },
  go = { "gofmt" },
}

local mason_tools = {
  "luacheck",
  "markdownlint",
  "prettierd",
  "ruff",
  "stylua",
  "tflint",
}

function M.lsp_servers()
  return vim.deepcopy(lsp_servers)
end

function M.formatters_by_ft()
  return vim.deepcopy(formatters_by_ft)
end

function M.mason_ensure_installed()
  local ensure_installed = vim.tbl_keys(lsp_servers)
  vim.list_extend(ensure_installed, mason_tools)
  table.sort(ensure_installed)
  return ensure_installed
end

function M.linters_by_ft()
  local linters = {}

  if require("config.utils").ON_LOCAL then
    linters.lua = { "luacheck" }
    linters.python = { "ruff" }
    linters.terraform = { "tflint" }
  end

  if vim.fn.executable "hadolint" == 1 then
    linters.dockerfile = { "hadolint" }
  end

  if vim.fn.executable "jsonlint" == 1 then
    linters.json = { "jsonlint" }
  end

  return linters
end

return M
