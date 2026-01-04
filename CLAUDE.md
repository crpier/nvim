# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## System Requirements

### Required Packages

**Core dependencies:**
- `git` - Required for lazy.nvim plugin manager
- `fd` - Must be available as `fd` (not `fdfind` as on some Ubuntu systems) for Telescope file finding
- `cmake` - Required to build telescope-fzf-native.nvim
- `make` - Required for building some plugins (e.g., avante.nvim)
- `curl` or `wget` - For downloading plugins and tools

**Language runtimes for LSP servers:**

LSP servers configured in `lua/plugins/lsp.lua` require their respective language runtimes:
- `lua_ls`: Installed via Mason (no external dependency)
- `pyright`: Requires Python 3 (`python3` and `pip3`)
- `ts_ls`: Requires Node.js and npm (`node` and `npm`)
- `gopls`: **Requires Go to be installed** (`go` binary must be in PATH)
- `rust_analyzer`: Requires Rust (`rustc` and `cargo`)
- `terraformls`: Requires Terraform (`terraform`)
- `marksman`: Installed via Mason (no external dependency)

**Optional but recommended:**
- `lazygit` - For the snacks.nvim lazygit integration (`<leader>lg`)
- `ripgrep` (`rg`) - Faster grep for Telescope live_grep (though fd can work as fallback)

### Tools Managed by Mason

The following formatters and linters are automatically installed by Mason but may require runtime dependencies:
- `stylua` - Lua formatter (standalone binary)
- `luacheck` - Lua linter (requires Lua)
- `ruff` - Python linter/formatter (standalone binary)
- `tflint` - Terraform linter (standalone binary)
- `prettierd` - JavaScript/TypeScript formatter (requires Node.js)
- `markdownlint` - Markdown formatter (requires Node.js)

**Note**: Mason will attempt to install these automatically when you first run Neovim. You can manually manage tools with `:Mason`.

## Configuration Architecture

### Plugin Management
Uses `lazy.nvim` for plugin management with lazy-loading enabled by default. All plugins are modular and defined in separate files under `lua/plugins/`:
- `lsp.lua` - LSP configuration (nvim-lspconfig, Mason)
- `formatting.lua` - Code formatting (conform.nvim)
- `linting.lua` - Code linting (nvim-lint)
- `completion.lua` - blink.cmp completion setup
- `telescope.lua` - Fuzzy finding and pickers
- `treesitter.lua` - Syntax highlighting and parsing
- `git.lua` - Git integration
- `dap.lua` - Debugging adapter protocol
- `navigation.lua` - File and buffer navigation
- `operators.lua` - Text operators and motions (surround, comment, unimpaired)
- `looks.lua` - UI and appearance
- `ai.lua` - AI integrations
- `experimental.lua` - Experimental plugins (snacks.nvim, overseer, mini.files)
- `custom.lua` - Loads local plugins from user configuration

### Core Configuration Files
- `init.lua` - Entry point that loads lazy.nvim, options, and remaps
- `lua/config/utils.lua` - Core utilities including root finding, local config loading, and lazy setup
- `lua/config/options.lua` - Global Neovim options and autocommands
- `lua/config/basic_remaps.lua` - Basic key mappings (leader is space)

### Local Configuration System
The config supports machine-specific settings via `~/.config/local_configs/nvim.lua`:
- Can override default options (avante_enabled, supermaven_enabled, treesitter_highlight_definitions)
- Can add project base directories for telescope-project
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
The config detects SSH sessions via `utils.ON_LOCAL = os.getenv("SSH_CLIENT") == nil` and may disable certain features (like linters) when running over SSH for performance reasons. See `lua/plugins/linting.lua:9-17`.

## LSP, Formatting, and Linting

### LSP Setup
- Uses `nvim-lspconfig` with Mason for managing language servers (configured in `lua/plugins/lsp.lua`)
- LSP servers are defined in the `servers` table and auto-installed via Mason
- LSP keymaps are set in LspAttach autocmd (`lua/plugins/lsp.lua:57-184`)
- Key LSP maps: `gd` (definition), `grr` (references), `grn` (rename), `gra` (code action), `K` (hover)
- Diagnostic navigation: `]d` (next), `[d` (prev), `]D` (last), `[D` (first), `d;` (float)
- Uses `nvim-navic` for breadcrumb context in statusline

### Formatting
- Configured in `lua/plugins/formatting.lua` using `conform.nvim`
- Triggered with `gq` keymap or on save
- Formatters configured per-filetype (Lua→stylua, Python→ruff, JS/TS→prettierd, etc.)

### Linting
- Configured in `lua/plugins/linting.lua` using `nvim-lint`
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

Telescope mappings (from `lua/plugins/telescope.lua`):
- `sf` - Git files
- `sF` - All files (including hidden)
- `stp` - Python files (no tests) - pre-filtered with `!test .py`
- `stP` - Python test files only - pre-filtered with `test .py`
- `stl` - Lua files - pre-filtered with `.lua`
- `sl` - Live grep
- `skk` - All keymaps
- `skn` - Normal mode keymaps only
- `ski` - Insert mode keymaps only
- `skv` - Visual mode keymaps only
- `sd` - Diagnostics
- `sp` - Projects

**Note**: Pre-filtered searches (`stp`, `stP`, `stl`) show the filter in the search box and you can edit it before searching.

LSP mappings (when LSP attached):
- `gd`, `gri`, `grr`, `grt`, `grD`, `grs` - Various goto/reference commands
- `grn` - Rename
- `gra` - Code action
- `K` - Hover documentation
- `<leader>th` - Toggle inlay hints

## Plugin Categories

When modifying plugins, categorize them appropriately:
- **LSP servers** → `lua/plugins/lsp.lua`
- **Formatting** → `lua/plugins/formatting.lua`
- **Linting** → `lua/plugins/linting.lua`
- **Completion** → `lua/plugins/completion.lua`
- **Navigation/Finding** → `lua/plugins/telescope.lua` or `lua/plugins/navigation.lua`
- **Git** → `lua/plugins/git.lua`
- **UI/Appearance** → `lua/plugins/looks.lua`
- **Debugging** → `lua/plugins/dap.lua`
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
