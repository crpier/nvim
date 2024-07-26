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
vim.o.scrolloff = 4
-- Decrease update time
vim.o.updatetime = 150
-- Always show the sign column
vim.wo.signcolumn = "yes:1"
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
vim.o.termguicolors = true
-- Allow closing folds using treesitter contexts
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99
-- Highlight current line
vim.opt.cursorline = true
vim.o.textwidth = 0

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
vim.api.nvim_create_autocmd({ "BufEnter" }, {
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
-- Don't insert comment leader when pressing o/O on comment line by removing `o` option
vim.api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions=jcrql]], group = misc_group })
