# Change review trial

Local review alongside Diffview. No Pi connection, automatic commits, staging changes, or Diffview fork.

## Workflow

1. Save files. `HEAD` is the review baseline; pending changes can span multiple agent turns.
2. `<leader>ro` runs plain `:DiffviewOpen`, following its normal repository detection, settings, and file list. Staged changes appear in a separate section; untracked-file visibility follows Diffview's defaults.
3. Edit working-copy files directly, or leave comments for later.
4. `<leader>rr` toggles the current file's approval. Save it first.
5. `<leader>rn` picks from unreviewed files; `<leader>rf` shows the full checklist.
6. `<leader>ry` previews all outstanding feedback. Press `y` in that preview to copy everything, `q` to close. `<leader>rY` or `:ChangeReview copy` copies directly to the `+` register without opening a preview.
7. Commit manually when ready. `:ChangeReview clear` explicitly discards the review after confirmation.

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

## Approval and refresh

The viewer and approval baseline differ when changes are staged: Diffview shows working-tree versus index changes and a separate staged section, while approval covers the cumulative diff against `HEAD`. This is necessary because the installed Diffview excludes untracked files from explicit `HEAD` comparisons. With nothing staged, the tracked-file comparisons coincide.

`<leader>rR` or `:ChangeReview refresh` rescans disk changes and runs `:DiffviewRefresh` when available, without discarding comments. It does not load Diffview or open a new view. Opening either file picker also refreshes review bookkeeping. Approval uses the complete per-file Git diff against the resolved `HEAD`, not hunk matching or staging status. Untracked files use their content hash. No lockfiles are excluded beyond normal Git ignore rules for untracked files.

Unchanged files retain approval. Changed, removed, or no-longer-listed files lose approval; changing `HEAD` invalidates prior approvals. Loaded buffers with unsaved changes cannot be approved. Save changes before using the checklist: unsaved-only changes are not Git working-tree changes and are not listed.

The scan is explicit and synchronous, with bounded Git command waits. Very large changesets may make it slow; background scanning is not part of this trial. Repositories need an existing `HEAD` commit.

## Commands

`:ChangeReview` accepts:

- `open`
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

Unsaved comment-buffer edits are not persisted. Approvals remain session-only. Persistence stores the latest comments, not session history, and commits do not clear them.

State files contain comment text and original code excerpts, are private to the user, and are replaced atomically. A lock and content token reject concurrent stale writes rather than overwriting another editor's feedback. If that happens, export your in-memory feedback before reopening Neovim. A process killed during a write may leave a `.lock` file; remove only that lock after confirming no writer remains. Corrupt state is reported and left untouched rather than silently reset.

Implementation: `lua/config/change_review.lua`. It uses normal buffer events, extmarks, Git, and Diffview's public command. It does not inspect Diffview's internal classes or modify its file panel.

Run checks from the configuration root:

```sh
nvim --headless -u NONE -l scripts/test-change-review.lua
nvim --headless -u NONE -l scripts/test-change-review-persistence.lua
nvim --headless -u NONE '+lua local ok, err = pcall(dofile, "scripts/test-change-review-padding.lua"); if not ok then print(err); vim.cmd("cquit") end'
luacheck lua/config/change_review*.lua scripts/test-change-review*.lua
stylua --check lua/config/change_review*.lua scripts/test-change-review*.lua
```
