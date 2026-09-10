-- Run: nvim --headless -u NONE -l scripts/test-markdown-formatting.lua
-- Requires prettier on PATH. Uses temporary files/state; does not start LSPs.
local root = vim.fn.getcwd()
local tmp = vim.fn.tempname()
vim.env.XDG_STATE_HOME = tmp .. "/state"
vim.fn.mkdir(tmp, "p")
vim.opt.rtp:prepend(root)
vim.cmd.cd(tmp)
assert(vim.fn.executable "prettier" == 1, "Install prettier before running this test")
vim.fn.writefile({ '{"printWidth": 20, "proseWrap": "always"}' }, tmp .. "/.prettierrc.json")
local audit = require "config.usage_audit"
audit.setup()
local formatting = require "config.formatting"
formatting.setup()
local tools = require("config.toolchain").formatters_for "markdown"
assert(#tools == 1 and tools[1].cmd == "prettier" and tools[1].stdin)

local function lines()
  return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end
local function format()
  local tick = vim.api.nvim_buf_get_changedtick(0)
  vim.api.nvim_feedkeys("gq", "xt", false)
  assert(
    vim.wait(10000, function()
      return vim.api.nvim_buf_get_changedtick(0) > tick
    end, 10),
    "gq did not apply Markdown formatting"
  )
  return lines()
end
local function aligned(output)
  local expected
  local count = 0
  for _, line in ipairs(output) do
    if line:sub(1, 1) == "|" then
      local columns = {}
      for position in line:gmatch "()|" do
        if line:sub(position - 1, position - 1) ~= "\\" then
          columns[#columns + 1] = vim.fn.strdisplaywidth(line:sub(1, position - 1))
        end
      end
      expected = expected or columns
      assert(vim.deep_equal(expected, columns), "Misaligned table row: " .. line)
      count = count + 1
    end
  end
  assert(count >= 3, "No table rows found")
end

local paragraph = "This paragraph deliberately exceeds the project print width and should stay on one line."
local source = {
  "# Tables",
  "",
  paragraph,
  "",
  "| Key | Count |",
  "| --- | ---: |",
  "| `gq` | 42 |",
  "| really-long-key | 1 |",
  "| a\\|b | 2 |",
}
local path = tmp .. "/table sample.md"
vim.fn.writefile(source, path)
vim.cmd.edit(path)
vim.bo.filetype = "markdown"
local output = format()
aligned(output)
assert(vim.tbl_contains(output, paragraph), "Paragraph wrapping changed")
assert(vim.deep_equal(vim.fn.readfile(path), source), "gq unexpectedly wrote the file")
assert(vim.bo.modified, "Formatted changes should remain unsaved")

-- No filename/extension is required; the record supplies Markdown parser context.
vim.cmd "enew!"
vim.bo.filetype = "markdown"
vim.api.nvim_buf_set_lines(0, 0, -1, false, source)
aligned(format())

-- The real audit report is a nofile buffer with an extensionless name.
audit.report()
assert(vim.bo.buftype == "nofile" and vim.bo.filetype == "markdown")
output = format()
-- The report has two independent tables, with different column counts.
local table_lines = {}
for _, line in ipairs(output) do
  if line:sub(1, 1) == "|" then
    table_lines[#table_lines + 1] = line
  elseif #table_lines > 0 then
    aligned(table_lines)
    table_lines = {}
  end
end
if #table_lines > 0 then
  aligned(table_lines)
end
assert(vim.fn.glob(tmp .. "/.nvim-format-*") == "", "Formatter left a temporary source file")
assert(audit.flush())
vim.cmd.cd(root)
vim.fn.delete(tmp, "rf")
print "Markdown gq: aligned tables, preserved prose, unsaved edits, unnamed and audit buffers OK"
vim.cmd "qa!"
