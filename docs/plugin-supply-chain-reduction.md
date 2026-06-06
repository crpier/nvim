# Plugin supply-chain reduction notes

## Try later

## Done

- Migrated Telescope picker usage to `snacks.nvim` and removed the Telescope plugin stack.
- Replaced `bufferline.nvim` with local `config.simple_bufferline` for listed buffer names in the tabline.
- Vendored Catppuccin Macchiato as a static local colorscheme with upstream MIT attribution in `colors/catppuccin-macchiato.lua`.
- Replaced Mason-managed LSP/tool installation with direct `vim.lsp.config` setup and explicit external commands that must be available on `PATH`.
- Replaced `nvim-lspconfig` with local explicit server configs passed to Neovim's built-in LSP API.
- Replaced `nvim-lint` with local `config.linting` using the same lint triggers and external linter commands.
- Replaced `conform.nvim` with local `config.formatting` using the same `gq` mapping and external formatter commands.
- Removed unused DAP plugin stack (`nvim-dap`, `nvim-dap-ui`, `nvim-dap-python`, `nvim-dap-virtual-text`).
- Added local `config.usage_audit` to track keymap and command usage in `stdpath('state')/usage-audit.json` and expose `:UsageAuditReport` / `:UsageAuditReset`.
- Removed `unimpaired.nvim`
- Removed `nvim-treesitter-refactor`; local `<C-n>` / `<C-p>` Treesitter usage navigation replaces the old usage-jump mappings.
- Removed `obsidian.nvim`; local `config.notes` keeps the used note workflows (`<leader>of`, `<leader>on`, `<leader>ot`).
