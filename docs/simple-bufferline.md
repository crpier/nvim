# Simple bufferline

`lua/config/simple_bufferline.lua` uses Neovim's tabline, with no plugin dependency.

- With one tab, it lists all listed buffers as before.
- With multiple tabs, the left side lists buffers visited in the current tab. Hidden buffers stay in that tab's list. Opening the same buffer in another tab adds it there too.
- The right side shows clickable numbered tabs, labeled with each tab's active window's filename. A `+` means one of that tab's buffers has unsaved changes, even if hidden.
- Clicking a buffer focuses a split already displaying it in the current tab. Otherwise it replaces the current window's buffer.
- Duplicate filenames expand to distinct path suffixes. Buffer labels retain the modified and read-only markers.

Use `:tabnew`, `:tab split`, `gt`, `gT`, `:tabmove`, and `:tabclose` as usual. Tab labels follow the current tab order. Closing a tab does not delete its buffers. Returning to one tab shows all listed buffers again.

This only filters the bufferline. Native `:bnext`, `:bprevious`, and buffer pickers still use Neovim's global buffer list. Tab membership lives in memory, not session files. Restored sessions start with the buffers visible in each tab's windows.

Run the checks from the config root:

```sh
nvim --headless -u NONE -l scripts/test-simple-bufferline.lua
```
