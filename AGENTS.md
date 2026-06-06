# AGENTS.md

## System Requirements

### Required Packages

**Core dependencies:**
- `git` - Required for lazy.nvim plugin manager and snacks.picker git integration
- `fd` - Must be available as `fd` (not `fdfind` as on some Ubuntu systems) for snacks.picker file finding
- `make` - Required for building some plugins (e.g., avante.nvim)
- `curl` or `wget` - For downloading plugins and tools

**Language runtimes and LSP servers:**

LSP servers configured in `lua/config/toolchain.lua` are expected to be installed externally and available on `PATH`. Run `:checkhealth config` to audit configured LSP, formatter, and linter executables. Opening a filetype with a configured LSP server raises an error if the required executable is missing:
- `lua_ls`: `lua-language-server`
- Python LSP defaults to `pyright`: `pyright-langserver` (requires Python 3 / npm-managed install depending on installation method)
  - Override before startup with `NVIM_PYTHON_LSP=ty` for `ty server`
  - Override before startup with `NVIM_PYTHON_LSP=pyrefly` for `pyrefly lsp`
- `ts_ls`: `typescript-language-server` (requires Node.js and npm)
- `gopls`: Requires Go to be installed (`go` binary must be in PATH)
- `rust_analyzer`: Requires Rust (`rustc` and `cargo`)
- `marksman`: `marksman`

**Optional but recommended:**
- `lazygit` - For the snacks.nvim lazygit integration (`<leader>lg`)
- `ripgrep` (`rg`) - Faster grep for snacks.picker live grep (though fd can work as fallback)

### External Formatters and Linters

The following formatters and linters are expected to be installed externally and available on `PATH`:
- `stylua` - Lua formatter
- `luacheck` - Lua linter
- `ruff` - Python linter/formatter
- `tflint` - Terraform linter
- `prettierd` - JavaScript/TypeScript formatter
- `markdownlint` - Markdown formatter
- Optional: `hadolint` for Dockerfiles, `jsonlint` for JSON

## Configuration Architecture

### Plugin Management
Uses `lazy.nvim` for plugin management with lazy-loading enabled by default. All plugins are modular and defined in separate files under `lua/plugins/`:
- `lsp.lua` - Companion LSP plugins only; built-in LSP setup lives in `lua/config/lsp.lua`
- `formatting.lua` - Tombstone for the removed conform.nvim plugin; local formatting lives in `lua/config/formatting.lua`
- `linting.lua` - Tombstone for the removed nvim-lint plugin; local linting lives in `lua/config/linting.lua`
- `completion.lua` - blink.cmp completion setup
- `navigation.lua` - Snacks-based file, buffer, grep, explorer, terminal, and picker integrations
- `treesitter.lua` - Syntax highlighting and parsing
- `git.lua` - Git integration
- `dap.lua` - Tombstone for removed Debug Adapter Protocol plugins
- `navigation.lua` - Snacks-based file and buffer navigation
- `operators.lua` - Text operators and motions (surround, comment, unimpaired)
- `looks.lua` - UI and appearance
- `ai.lua` - AI integrations
- `experimental.lua` - Experimental plugins
- `custom.lua` - Loads local plugins from user configuration

### Core Configuration Files
- `init.lua` - Entry point that loads lazy.nvim, options, and remaps
- `lua/config/utils.lua` - Core utilities including root finding, local config loading, and lazy setup
- `lua/config/options.lua` - Global Neovim options and autocommands
- `lua/config/basic_remaps.lua` - Basic key mappings (leader is space)

### Local Configuration System
The config supports machine-specific settings via `~/.config/local_configs/nvim.lua`:
- Can override default options (avante_enabled, supermaven_enabled, treesitter_highlight_definitions)
- Can load additional local plugins
- Spell file is also stored in local_configs: `~/.config/local_configs/en.utf-8.add`

Default options are defined in `lua/config/utils.lua:103-118`.

### Root Directory Detection
The config includes automatic root directory detection that changes `cwd` when entering buffers:
- First tries LSP root directory
- Falls back to project markers: `.git`, `Makefile`, `package.json`, `pyproject.toml`, `.svn`
- Implemented in `lua/config/utils.lua:66-101`
- Enabled in `init.lua:38` with `utils.enable_set_root_autocmd(false)` (verbose=false)

### SSH Detection
The config detects SSH sessions via `utils.ON_LOCAL = os.getenv("SSH_CLIENT") == nil` and may disable certain features (like linters) when running over SSH for performance reasons. See `lua/config/toolchain.lua`.

## LSP, Formatting, and Linting

### LSP Setup
- Uses Neovim's built-in LSP configuration API with externally installed language servers (configured in `lua/config/lsp.lua`)
- LSP servers are defined in `lua/config/toolchain.lua` and enabled directly with `vim.lsp.config` / `vim.lsp.enable`
- Python LSP selection is startup-only via `NVIM_PYTHON_LSP`; unset uses `pyright`, supported overrides are `ty` and `pyrefly`
- LSP keymaps are set in an LspAttach autocmd (`lua/config/lsp.lua`)
- Key LSP maps: `gd` (definition), `grr` (references), `grn` (rename), `gra` (code action), `K` (hover)
- Diagnostic navigation: `]d` (next), `[d` (prev), `]D` (last), `[D` (first), `d;` (float)
- Uses `nvim-navic` for breadcrumb context in statusline

### Formatting
- Configured in `lua/config/formatting.lua` using local wrappers around external formatter commands
- Triggered with `gq` keymap
- Formatters configured per-filetype (Lua→stylua, Python→ruff, JS/TS→prettierd, etc.)

### Linting
- Configured in `lua/config/linting.lua` using local wrappers around external linter commands
- Runs on BufEnter, BufWritePost, InsertLeave
- Linters configured per-filetype (Lua→luacheck, Python→ruff, Terraform→tflint)
- Many linters disabled on SSH for performance

## Key Mappings

Leader key is `<Space>` (both leader and localleader).

Important core mappings from `lua/config/basic_remaps.lua`:
- `Q` - Quit without saving (ZQ)
- `<Esc>` - Clear search highlighting
- `<C-S>` - Save (works in normal and insert mode)
- `<C-hjkl>` - Navigate windows
- Terminal mode: `<C-hjkl>` to navigate, `<C-/>` to exit
- `]<Space>` / `[<Space>` - Add blank lines below/above
- `J` / `K` in visual mode - Move lines up/down
- `y!` - Print current working directory

Simple harpoon mappings (from `lua/config/simple_harpoon.lua`):
- `mm` - Mark current file
- `mq` - Show marked files; inside picker normal mode uses `dd` to remove and `J` / `K` to move marks down/up
- `ma` / `ms` / `md` / `mf` - Jump to marks 1-4
- `mg` - Open project terminal 1

Snacks.picker mappings (from `lua/plugins/navigation.lua`):
- `sf` - Git files, including untracked non-ignored files
- `sF` - All files (including hidden)
- `stp` - Python files (no tests) - pre-filtered with `!test .py`
- `stP` - Python test files only - pre-filtered with `test .py`
- `stl` - Lua files - pre-filtered with `.lua`
- `sl` - Live grep
- `su` - Fuzzy find in current buffer
- `so` - Old/recent files
- `s/` - Grep with user input
- `sd` - Diagnostics
- `sk` - All keymaps
- `s<space>` - Buffers
- `sw` - Search word under cursor
- `sm` - Marks
- `sgc` - Git status (changed files)
- `sgb` - Git branches
- `sp` - Projects (scans base dirs for git repos)
- `sra` - All registers
- `srd` - Registers 0-9 (yank/delete only)
- `sto` - TODO comments (from todo-comments.nvim)

LSP mappings (when LSP attached):
- `gd`, `gri`, `grr`, `grt`, `grD`, `grs` - Various goto/reference commands
- `grn` - Rename
- `gra` - Code action
- `K` - Hover documentation
- `<leader>th` - Toggle inlay hints

## Plugin Categories

When modifying plugins, categorize them appropriately:
- **LSP servers** → `lua/config/toolchain.lua` and `lua/config/lsp.lua`
- **Formatting** → `lua/config/formatting.lua`
- **Linting** → `lua/config/linting.lua`
- **Completion** → `lua/plugins/completion.lua`
- **Navigation/Finding** → `lua/plugins/navigation.lua` (snacks.picker)
- **Git** → `lua/plugins/git.lua`
- **UI/Appearance** → `lua/plugins/looks.lua`
- **Debugging** → removed for now; reintroduce under `lua/plugins/dap.lua` if needed
- **Text operators/motions** → `lua/plugins/operators.lua`
- **AI tools** → `lua/plugins/ai.lua`
- **Experimental** → `lua/plugins/experimental.lua`

## Important Behaviors

### Lazy Loading
Most plugins are lazy-loaded. When adding plugins, consider appropriate lazy-load triggers:
- `ft` for filetype-specific plugins
- `event` for event-based loading
- `keys` for keymap-based loading
- `cmd` for command-based loading

### Disabled Plugins
Several built-in plugins are disabled in `init.lua:25-32` for performance: gzip, netrwPlugin, rplugin, tarPlugin, tohtml, tutor, zipPlugin.

### Autocommands
Key autocommands in `lua/config/options.lua`:
- Highlight on yank
- Return to last cursor position on buffer read
- `q` to close help/man/qf/lspinfo buffers
- Jenkinsfiles detected as groovy
- Wrap and spell enabled for git commits and markdown
- Format options adjusted to prevent comment continuation on newlines
