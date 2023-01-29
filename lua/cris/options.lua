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
vim.o.completeopt = "menuone,noselect"
-- No wrapping of text
vim.o.wrap = false
-- Set indent to 4 spaces by default
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
-- Only one statuline
vim.opt.laststatus = 3
-- Show filename at the top
-- TODO: if SSH_CLIENT use `%F` instead
vim.opt.winbar = "   %f %m %r"
vim.o.termguicolors = true

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
-- misc autocommands
local misc_group = vim.api.nvim_create_augroup("Misc", { clear = true })
-- Return to last cursor location
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  group = misc_group,
})
-- Easy quit with q on certain buffers
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "qf", "help", "man", "lspinfo" },
  callback = function()
    vim.cmd [[ nnoremap <silent> <buffer> q :close<CR> ]]
  end,
  group = misc_group,
})
-- Make vim know Jenkinsfiles are groovy code
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "Jenkinsfile" },
  callback = function()
    vim.opt_local.ft = "groovy"
  end,
  group = misc_group,
})
-- Enable wrapping and spelling on some files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
-- Don't insert comment leader when pressing o/O on comment line
vim.api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions-=o]], group = misc_group })
