# Toolchain

How this config knows which external tools (LSP servers, formatters, linters) apply
to a filetype and how to run them. The vocabulary below names the seam between
*what each tool is* and *the generic machinery that runs it*.

## Language

**Registry**:
The single place that holds one complete record per external tool. Owns the
filetype association and the fixers-before-formatters ordering rule; everything
else derives from it. Lives in `lua/config/toolchain.lua`.
_Avoid_: config, manifest, table.

**Tool record**:
One tool's complete description — `cmd`, args builder, `cwd`, stdin/file mode,
exit codes, output channel, `parse`, and the `filetypes` it applies to. The
filetype association lives on the record, not in a separate by-filetype map.
_Avoid_: spec, entry, definition.

**Runner**:
The workflow that applies Tool records of one kind to a buffer — sequential for
formatters, parallel for linters. Holds no per-tool data. Lives in
`formatting.lua` and `linting.lua`, exposing `format(bufnr)` / `lint(bufnr)`.
_Avoid_: engine, executor, driver.

**Tool invocation**:
The generic mechanism that runs one Tool record and returns its observable
result. Owns command assembly, stdin/file input mode, working directory, exit
codes, and process result shape.
_Avoid_: execution helper, process wrapper, job runner.

**Phase**:
A formatter's bucket in the pipeline: `fix` runs before `format`. The Registry
sorts fixers first; order within a phase follows declaration order.
_Avoid_: stage, pass, priority.
