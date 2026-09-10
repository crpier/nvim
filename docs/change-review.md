# Change review trial

Local hunk review in working buffers, Diffview, or quickfix. No Pi connection, automatic commits, staging changes, or Diffview internals.

## Workflow

1. Save files before creating a snapshot. `HEAD` is the baseline; pending changes can span multiple agent turns.
2. `<leader>rq` opens a review quickfix list. Alternatively, `<leader>ro` starts review and runs plain `:DiffviewOpen`, preserving Diffview's usual file list and settings. Either uses the same existing snapshot, or creates one if needed.
3. Enter on a quickfix entry jumps to its working-copy location. Edit source directly, or leave comments for later. Deleted files, binary changes, symlinks, and submodules open read-only snapshot previews instead.
4. `<leader>rr` toggles the hunk under the working-buffer cursor, the selected review quickfix entry, or the hunk shown in a snapshot preview. `[ ]` / `[x]` virtual text and quickfix entries update together, without notifications. Outside a hunk, toggling is a no-op. If edits collapse several hunks onto one location, a picker asks which to toggle.
5. `<leader>rp` previews the selected hunk's original snapshot patch, including removed lines. It works from source, review quickfix, and snapshot previews. `q` closes the preview.
6. `<leader>rn` picks files with unchecked hunks; `<leader>rf` shows the full file checklist. A file is reviewed when all its hunks are checked. The checklist's toggle action checks or unchecks every hunk in that file.
7. `<leader>ry` previews all outstanding feedback. Press `y` there to copy everything, `q` to close. `<leader>rY` or `:ChangeReview copy` copies feedback directly to the `+` register.
8. After revisions, keep reviewing the same snapshot or use `<leader>rR` to rebuild it after confirmation. Commit manually when ready. `:ChangeReview clear` discards comments and review progress after confirmation.

Nothing interprets another agent turn as approval. Every export includes this instruction for the agent:

> Address these comments within the current work part. Don't commit or expand scope.

## Comments

- `<leader>rc`: comment on the current line, or selected lines in visual mode. Using the same range again edits its existing comment.
- `<leader>rC`: comment on the whole file. File-level comments appear as virtual blocks below the last line and follow the end of the file as it changes.
- The comment editor is a writable `acwrite` buffer: `:w` updates the comment without closing, `:x` saves and closes, `:q` closes normally, and `:q!` discards unsaved edits. No special save/quit mappings are installed.
- Only saved text updates the comment; repeated saves update the same comment.
- Clear the editor and save with `:w` or `:x` to delete the comment and its annotations. Whitespace-only text counts as empty. `:q!` without saving preserves the comment. Saving text again in the same editor restores a deleted comment.
- `<leader>rl`: list outstanding comments, then jump, edit, or resolve.
- `]n` / `[n`: next/previous outstanding comment in the current working-copy file, wrapping at the ends. Counts are supported. File comments are at EOF; multiple comments on the same line share one stop.
- Export does not resolve or delete comments.

Comments are separate from source files. Signs and multiline virtual blocks below the anchor show their text in working-copy buffers, including Diffview's editable side. Long lines wrap to the available width when annotations are rendered. Existing hunk and window mappings are untouched.

Virtual blocks are not editable source lines: use `<leader>rc` on their range or `<leader>rl` to edit them. Two-way diffs receive matching blank virtual rows in the other pane, using Neovim's filler rows to locate the counterpart. Padding updates after edits, resizing, diff updates, and window changes, and disappears when comments are resolved or cleared.

Inside added-line filler there is no exact buffer line to attach to, so padding uses a nearby real line. Alignment resumes below that area; a comment on a new first line can temporarily offset the first old-side line. Three-way merge layouts are not padded.

Extmarks follow edits in loaded buffers. Each line comment retains its original excerpt. If the text at its anchor no longer matches, the picker/export flags the location for checking. Missing files do not erase feedback. No fuzzy relocation or automatic resolution is attempted.

Historical buffers, including Diffview's old side, are deliberately rejected. For now, use a working-copy file-level comment to discuss deleted code. A completely deleted file can be reviewed through the checklist, but cannot receive a new comment in this version.

## Hunk snapshots and rebuilding

A snapshot contains cumulative on-disk changes against a resolved `HEAD`, including staged and unstaged changes and non-ignored untracked files. Zero-context Git hunks are separate review entries. New files, entirely deleted files, binary changes, symlinks, submodules, and changes without textual hunks each receive one whole-file entry. Renames are represented as deletion plus creation.

Edited files show hunk markers in working buffers instead of a file statusline badge. Whole-file entries also retain the file badge. Pure deletions anchor at the nearby surviving line; BOF/EOF positions are clamped to a real line. Snapshot previews retain the removed text. Historical buffers are not annotated or editable review targets.

Extmarks track positions through edits in loaded buffers. Checkmarks survive edits, saves, switching viewers, opening pickers, and changes to `HEAD`. They mean you reviewed that snapshot entry, not that the current source still matches it. New changes do not appear until a rebuild. There is no fuzzy matching or automatic invalidation; reloading externally changed text can require a rebuild to restore useful locations.

`<leader>rR` or `:ChangeReview refresh` asks before resetting all checkmarks and rescanning disk, while retaining comments. Save changed source buffers first; a failed scan leaves the previous snapshot intact. A successful rebuild also updates the review quickfix list and runs `:DiffviewRefresh` when available, without loading Diffview or opening it. Old snapshot previews are labeled retired and cannot toggle new entries.

Diffview still separates staged and unstaged changes, while snapshot hunks are cumulative against `HEAD`. Their boundaries can differ when changes are staged. Markers and source toggling work on the live working-copy side, not the historical/index side. Use quickfix for the complete snapshot, or leave changes unstaged during Diffview review.

The quickfix list uses normal Enter, `:cnext`, and `:cprev` navigation. Review updates address their own list by ID and leave unrelated quickfix and location lists alone. `<leader>rq` reopens the existing review list. `<leader>rr` is a no-op in unrelated lists. Deleted-file previews never create a replacement source file, and cannot receive comments.

Scans are synchronous, with bounded Git command waits. Very large changesets may be slow. Repositories need an existing `HEAD` commit; unsaved-only changes are not included.

## Commands

`:ChangeReview` accepts:

- `open`
- `quickfix`
- `preview-hunk`
- `files`
- `pending`
- `toggle`
- `comment`, optionally with a line range
- `file-comment`
- `comments`
- `next`, `prev`
- `export`
- `copy`
- `refresh`
- `clear`

## Scope

Saved comments persist per repository under `stdpath("state")/change-review/`, normally `~/.local/state/nvim/change-review/`. They restore automatically when a working-copy buffer opens. Comment creation, saves, deletion, resolution, and review clearing write immediately; source-file saves also update stored line positions. There is no dependency on a clean exit.

Unsaved comment-buffer edits are not persisted. Hunk snapshots and checkmarks remain session-only. Persistence stores the latest comments, not session history, and commits do not clear them.

State files contain comment text and original code excerpts, are private to the user, and are replaced atomically. A lock and content token reject concurrent stale writes rather than overwriting another editor's feedback. If that happens, export your in-memory feedback before reopening Neovim. A process killed during a write may leave a `.lock` file; remove only that lock after confirming no writer remains. Corrupt state is reported and left untouched rather than silently reset.

Implementation:

- `lua/config/change_review.lua`: comments, session orchestration, commands, and mappings.
- `lua/config/change_review_hunks.lua`: Git snapshots, hunk positions, review state, and virtual markers.
- `lua/config/change_review_quickfix.lua`: owned quickfix lists and snapshot previews.
- `lua/config/change_review_store.lua`: comment persistence.
- `lua/config/change_review_padding.lua`: alignment of comment blocks in two-way diffs.

Diffview integration uses only its public commands, not its internal classes or file panel.

Run checks from the configuration root:

```sh
nvim --headless -u NONE -l scripts/test-change-review.lua
nvim --headless -u NONE -l scripts/test-change-review-persistence.lua
nvim --headless -u NONE -l scripts/test-change-review-hunks.lua
nvim --headless -u NONE -l scripts/test-change-review-quickfix.lua
nvim --headless -u NONE '+lua local ok, err = pcall(dofile, "scripts/test-change-review-padding.lua"); if not ok then print(err); vim.cmd("cquit") end'
luacheck lua/config/change_review*.lua scripts/test-change-review*.lua
stylua --check lua/config/change_review*.lua scripts/test-change-review*.lua
```
