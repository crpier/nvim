------ LSP ------
-- Neodev for working on nvim config
require("neodev").setup()

-- Actual LSP setup
require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = {
    "pyright",
  },
}
require("nvim-navic").setup()
local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
local lsp_attach = function(client, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "gq", vim.lsp.buf.format, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "d;", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    if client.server_capabilities.documentSymbolProvider then
        require("nvim-navic").attach(client, bufnr)
    end
end
local lspconfig = require "lspconfig"
require("mason-lspconfig").setup_handlers {
  function(server_name)
    lspconfig[server_name].setup {
      on_attach = lsp_attach,
      capabilities = lsp_capabilities,
    }
  end,
}
-- some lsp maps
vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<CR>")
vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<CR>")

-- null-ls
local null_ls = require "null-ls"
null_ls.setup {
  sources = {
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.black,
  },
}

-- fidget
require("fidget").setup()
