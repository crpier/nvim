# Usage audit

`:UsageAuditReport` shows keymap and command counts, least-used first. It reads the current in-memory counters, including changes not yet saved. Reopening the report refreshes it. Press `gq` to align its Markdown tables with Prettier; no renderer is needed.

`:UsageAuditReset` clears saved and in-memory history. There is no undo. Copy `stdpath("state") .. "/usage-audit.json"` first if you want a backup.

## What counts

- Keymaps count typed input before mapping expansion, using `vim.on_key`'s `typed` argument. Mapping RHS keys, macro playback and lazy.nvim's programmatic replay do not add counts.
- Live buffer-local mappings take precedence over global mappings. Late-installed LSP/Gitsigns maps, expression callbacks, replacements and deletions need no special registration.
- Buffer-local counts aggregate by mode and LHS across buffers, separately from global counts. They do not identify individual files or distinguish different actions assigned to the same local LHS.
- Operator-pending text objects count under `o`, Visual mappings under `x`. Keys use canonical notation, so `<leader>` with a space leader and `<Space>` do not create separate counters.
- `config.keymaps` registers group metadata without wrapping callbacks. External mappings get the `external` group. A lazy trigger's first invocation may have that group until a later invocation uses the installed mapping's metadata.
- Commands count non-cancelled interactive `:` submissions. A fully mapping-generated command line does not count. A shortcut that opens a prompt does count if the user edits or submits it.
- Parsing normalizes ranges, modifiers, bangs and abbreviations to a command name. Arguments are not stored in new command records. Nested expression prompts do not replace the outer command line.

The report includes historical entries, current global mappings/commands, and buffer-local mappings/commands from loaded buffers. An unused mapping in an unopened filetype may not appear. Zero counts are not proof that a feature is useless.

## Persistence and history

Counters update in memory. A one-second timer batches saves; `VimLeavePre` flushes pending changes. Each save writes a temporary file beside the state file and atomically renames it. A failed save warns and retains pending data for the next action or exit to retry. Writes still use synchronous file APIs, but not on every input event.

Version 1 history migrates to version 2 on the next save. Canonical key aliases merge with their counts and latest timestamp preserved. Command history remains unchanged. Old false positives and misclassified operator modes cannot be corrected retrospectively. Restart existing Neovim sessions when updating the tracker so they no longer run the old collector.

## Remaining limits

- Counts measure input/submission, not successful execution. Invalid command arguments can still count. Unknown command names that cannot be parsed do not count.
- Only the first command in a `|` pipeline counts. Commands run through `vim.cmd`, `:normal`, mappings or macro playback are deliberately excluded from interactive counts. Command-line-window execution through `q:` is not tracked.
- Dot-repeat and programmatic callback invocation do not count as fresh typed mapping use. The collector depends on Neovim's `vim.on_key` typed-input reporting.
- A crash can lose the pending batch. Atomic replacement prevents partially written JSON; it does not merge counters across concurrently running Neovim processes. The last process to save wins.
- Historical data mixes old and new tracking rules unless you explicitly reset it.

## Checks

```sh
nvim --headless -u NONE -l scripts/test-usage-audit.lua
nvim --headless -u NONE -l scripts/test-local-features.lua
LOCAL_FEATURES_TEST_FILE=1 nvim --headless -u NONE -l scripts/test-local-features.lua
```

The audit test uses temporary state and actual fed input. It covers command origin, cancellation, nested prompts, live mapping changes, scope, leaders, expression/Visual/operator mappings, batched saves, write failures, exit/reset flushing, legacy migration and report rendering. The local-feature test checks lazy trigger/replay counts.
