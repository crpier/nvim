vim.wo.relativenumber = true
vim.wo.number = true
-- Enable mouse mode
vim.o.mouse = "a"
-- Enable break indent
vim.o.breakindent = true
-- Save undo history
vim.o.undofile = true
vim.o.swapfile = false
-- Smarter search behavior
-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true
-- Jump to result while typing search query
vim.o.incsearch = true
-- Always pad the edges
vim.o.scrolloff = 8
-- Decrease update time
vim.o.updatetime = 250
-- Always show the sign column
vim.wo.signcolumn = "yes"
-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"
-- No wrapping of text
vim.o.wrap = false
-- Set indent to 4 spaces by default
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
-- Only one statuline
vim.opt.laststatus = 3
-- Show filename at the top
-- TODO: if SSH_CLIENT use `%F` instead
vim.opt.winbar = "   %f %m %r"

---- Autocommands ----
-- highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})
-- don't turn newlines into comments
-- local formatoptions_group = vim.api.nvim_create_augroup('FileType', { clear = true })
-- vim.api.nvim_create_autocmd('FileType', {
-- 	callback = function()
-- 		vim.o.formatoptions = "jql"
-- 	end,
-- 	group = formatoptions_group,
-- 	pattern = '*',
-- })
local misc_group = vim.api.nvim_create_augroup("Misc", { clear = true })
vim.api.nvim_create_autocmd(
	"BufReadPost",
	{
		command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]],
		group = misc_group,
	}
)

vim.api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions-=o]], group = misc_group })
