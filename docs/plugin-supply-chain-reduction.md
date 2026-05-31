# Plugin supply-chain reduction notes

## Try later

- Migrate remaining Telescope usage to `snacks.nvim` and then remove the Telescope stack if Snacks now covers the needed workflows.
- Experiment with removing `bufferline.nvim`; keep it only if the UI loss is annoying.
- Consider vendoring/static-rewriting the Catppuccin colorscheme because it is unlikely to need frequent updates.
- Rewrite `conform.nvim` and `nvim-lint` as separate units of work.
- Replace Mason-managed LSP/tool installation with explicit external installation and plain `lspconfig` setup.
- Decide which `unimpaired.nvim` mappings are actually used before expanding the local replacement.
- Prototype a local usage-audit module/plugin that tracks used keymaps and commands, then reports configured mappings/commands that are rarely or never used.
