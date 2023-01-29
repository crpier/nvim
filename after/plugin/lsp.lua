------ LSP ------
require("neodev").setup()
local lsp = require("lsp-zero")
-- TODO: recommended doesn't fit me
lsp.preset("recommended")
lsp.ensure_installed({
	"sumneko_lua",
	"pyright",
	"gopls",
})
lsp.set_preferences({
	sign_icons = {},
})
lsp.setup()

-- null-ls
null_ls = require("null-ls")
null_ls.setup({
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.black,
	},
})
