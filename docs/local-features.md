# Local features managed by lazy.nvim

`lua/plugins/local_features.lua` registers 17 config modules as virtual plugins. Implementations remain under `lua/config/`; lazy manages setup without downloading repositories or adding directories to the runtimepath.

Find the `local-*` entries in `:Lazy`. Use `:Lazy profile` to inspect setup costs and loading reasons.

## Loading rules

| Modules | Trigger |
| --- | --- |
| Usage audit, theme, bufferline, statusline, OSC52 | Startup |
| LSP | BufReadPre, BufNewFile, or FileType |
| Linting | BufReadPost, BufNewFile, BufWritePost, or InsertLeave |
| Test review | BufReadPost, BufNewFile, or review keys |
| Change review | BufReadPost, BufNewFile, ChangeReview command, or review keys |
| TODOs | Python FileType or TODO keys |
| Formatting, notes, harpoon, variable-part text objects, text helpers, unimpaired | Feature keys |
| Tabout | InsertEnter or loading blink.cmp |

Startup features stay eager to avoid UI flashes, missed usage tracking, and unconfigured clipboard access. Leader and basic mappings still initialize before lazy reads specs.

Reviews load on file events so persisted comments and test checkmarks appear without pressing a review key. Their handlers register before the initial BufEnter and BufWinEnter events. LSP setup registers before filetype processing; a FileType trigger also handles unnamed buffers. lazy replays triggering events for newly registered handlers.

Blink depends on `local-tabout` so its fallback captures the real Tab mapping even when LSP capabilities load completion before InsertEnter.

## Adding or changing a feature

Use the local `feature` helper with the existing module name and explicit loading triggers. `main` and `opts` tell lazy to call the module's `setup()` on load.

Keep feature-module `require` calls out of the spec's top level and do not call setup from `init.lua`. `init` callbacks always run at startup, so they are not a substitute for deferred setup.

Key specs contain triggers and descriptions, not actions. The module's setup installs the real mappings through `config.keymaps`, preserving usage auditing. When changing a mapping, update its trigger and mode in the spec too. The coverage test checks both directions.

Virtual specs do not make `require("config.some_feature")` load that feature's lazy entry. Code needing initialized feature state must use a declared dependency or explicitly load the virtual plugin before calling it. Plain helper modules such as the toolchain and review storage remain ordinary Lua modules.

`virtual` is supported by the installed lazy.nvim implementation and type definitions, but is not listed in its plugin-spec help. Re-run the tests after lazy upgrades.

## Checks

From the config root:

```sh
nvim --headless -u NONE -l scripts/test-local-features.lua
LOCAL_FEATURES_TEST_FILE=1 nvim --headless -u NONE -l scripts/test-local-features.lua
```

The tests use installed lazy.nvim and temporary data/state directories. External LSP and linter definitions are stubbed; formatting is intercepted. They check deferred loading, setup once, first-use keys including operator-pending mappings, command completion, mapping coverage, FileType replay, and first-file review/TODO rendering.

Use `scripts/profile-startup.sh` for startup measurements. A five-run empty-startup sample during migration moved from an 18.056ms median to 14.411ms. This small sample is not a performance guarantee; key-triggered setup moves work to first use, and file-triggered features still load when opening files.
