# Profiling notes

Use `scripts/profile-startup.sh` for repeatable startup profiling. It runs both the current config and `--clean`, summarizes mean/median/min/max from `--startuptime`, and prints the top self-time entries.

```bash
scripts/profile-startup.sh
scripts/profile-startup.sh /tmp/profile.lua
RUNS=30 scripts/profile-startup.sh /path/to/file.py
```

## 2026-06-06 startup profiling

Goal: reduce work done before a file actually needs it.

Changes made from the profiling pass:

- Load `nvim-treesitter` on `BufReadPost` / `BufNewFile` instead of at startup.
- Load `fidget.nvim` on `LspAttach` instead of at startup.
- Enable built-in LSP servers on the first relevant `FileType` instead of `User LazyDone`, so empty startup does not load `blink.cmp` just to compute LSP capabilities.

### Before these changes

Approximate `--startuptime` samples:

| Scenario | Mean |
| --- | ---: |
| `nvim +qa` | ~21.0ms |
| `nvim /tmp/profile.lua +qa` | ~34.3ms |

No-file startup loaded `blink.cmp`, `nvim-treesitter`, `fidget.nvim`, and `nvim-treesitter-textobjects`.

### After these changes

Sample command output from `scripts/profile-startup.sh`:

| Scenario | Clean mean | Current mean | Current median |
| --- | ---: | ---: | ---: |
| `nvim +qa` | 3.454ms | 11.764ms | 11.280ms |
| `nvim /tmp/profile.lua +qa` | 9.821ms | 31.676ms | 31.485ms |

No-file startup loaded only the core lazy stack needed by the config:

- `lazy.nvim`
- `snacks.nvim`
- `nvim-web-devicons`

Top no-file self-time entries after the changes:

```text
3.512ms  sourcing init.lua
0.967ms  colors/catppuccin-macchiato.lua
0.947ms  reading ShaDa
0.597ms  require('vim._core.defaults')
0.503ms  require('config.basic_remaps')
```

Top Lua-file self-time entries after the changes:

```text
6.716ms  opening buffers
3.341ms  sourcing init.lua
1.460ms  runtime/ftplugin/lua.lua
1.214ms  BufEnter autocommands
1.168ms  require('blink.cmp')
0.558ms  require('nvim-treesitter.parsers')
```

## Future profiling ideas

- Investigate `opening buffers` for real file startup; this includes filetype, syntax, Treesitter, LSP-triggering autocmds, and buffer-local plugin work.
- Compare cold vs warm ShaDa behavior if startup variance matters.
- Use Lazy's built-in profiler for plugin-specific load timing when a plugin appears in `--startuptime` output.
