-- Run: nvim --headless -u NONE -l scripts/test-usage-audit.lua
local tmp = vim.fn.tempname()
vim.env.XDG_STATE_HOME = tmp
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.g.mapleader = " "
local path = vim.fn.stdpath "state" .. "/usage-audit.json"
vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
vim.fn.writefile({
  vim.json.encode {
    version = 1,
    keys = {
      ["n old"] = { mode = "n", lhs = "old", count = 7, last_used = "2026-01-01" },
      ["n <leader>old"] = { mode = "n", lhs = "<leader>old", count = 2, last_used = "2026-01-02" },
      ["n  old"] = { mode = "n", lhs = " old", count = 3, last_used = "2026-01-03" },
    },
    commands = { OldCommand = { count = 9, last_used = "2026-01-01" } },
  },
}, path)
local audit = require "config.usage_audit"
audit.setup()
local function snapshot()
  assert(audit.flush())
  return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
end
local function commands()
  return snapshot().commands
end
local function key_count(id)
  local entry = snapshot().keys[id]
  return entry and entry.count or 0
end
local function feed(keys, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), mode or "xt", false)
end

vim.api.nvim_create_user_command("AuditExample", function() end, { range = true, bang = true })
audit.record_command "silent keepjumps 1AuditExample!"
audit.record_command "AuditEx"
audit.record_command "%s/foo/bar/g"
audit.record_command "w!"
audit.record_command "! echo hello"
audit.record_command ""
audit.record_command "NotAnInstalledCommand"
local counts = commands()
assert(counts.AuditExample.count == 2)
assert(counts.substitute.count == 1)
assert(counts.write.count == 1)
assert(counts["!"].count == 1)
assert(counts.NotAnInstalledCommand == nil)
assert(counts.OldCommand.count == 9, "historical commands lost")
assert(key_count "n old" == 7, "historical mappings lost")
assert(key_count "n <Space>old" == 5, "historical leader aliases weren't merged")
assert(snapshot().keys["n <Space>old"].last_used == "2026-01-03")
assert(snapshot().version == 2)

feed ":AuditExample<CR>"
assert(commands().AuditExample.count == 3)
feed ":AuditExample<Esc>"
feed ":AuditExample<C-c>"
assert(commands().AuditExample.count == 3, "cancelled command counted")
feed "/notfound<Esc>"
assert(commands().AuditExample.count == 3)

-- Mapping-generated Ex commands and macro replay are not interactive submissions.
vim.keymap.set("n", "zc", ":AuditExample<CR>")
feed "zc"
assert(commands().AuditExample.count == 3, "mapping RHS counted as command")
assert(key_count "n zc" == 1, "mapping LHS not counted")
vim.keymap.set("n", "zd", "<Cmd>AuditExample<CR>")
feed "zd"
assert(commands().AuditExample.count == 3)
assert(key_count "n zd" == 1)
vim.cmd "AuditExample"
feed(":AuditExample<CR>", "mx")
vim.fn.setreg("a", ":AuditExample\r")
feed "@a"
assert(commands().AuditExample.count == 3, "programmatic or macro command counted")
vim.fn.setreg("a", "zc")
feed "@a"
assert(key_count "n zc" == 1, "macro mapping counted")

-- A shortcut that opens a prompt still counts when the user submits it.
vim.keymap.set("n", "zp", ":AuditExample")
feed "zp<CR>"
assert(commands().AuditExample.count == 4)
feed ":echo <C-r>=1+1<CR><CR>"
assert(commands().echo.count == 1, "nested expression prompt lost outer command")
assert(commands()["="] == nil)

-- Discover late-installed callbacks and distinguish an LHS from its RHS.
vim.keymap.set("n", "zx", function() end, { desc = "external callback" })
vim.keymap.set("n", "z", function() end)
feed "zx"
assert(key_count "n zx" == 1)
assert(key_count "n z" == 0, "mapping prefix counted")
vim.keymap.set("n", "za", "zx", { remap = true })
feed "za"
assert(key_count "n za" == 1)
assert(key_count "n zx" == 1, "remapped RHS counted twice")
vim.keymap.del("n", "zx")
feed "zx"
assert(key_count "n zx" == 1, "deleted mapping still counted")

-- Buffer-local mappings shadow globals and don't leak into other buffers.
local first = vim.api.nvim_get_current_buf()
vim.keymap.set("n", "zy", function() end, { desc = "global" })
vim.keymap.set("n", "zy", function() end, { buffer = first, desc = "local" })
feed "zy"
assert(key_count "n zy [buffer]" == 1)
assert(key_count "n zy" == 0)
local second = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(second)
feed "zy"
assert(key_count "n zy" == 1)
assert(key_count "n zy [buffer]" == 1)
vim.keymap.set("n", "zy", function() end, { buffer = second })
feed "zy"
assert(key_count "n zy [buffer]" == 2, "local counts should aggregate across buffers")
vim.keymap.del("n", "zy", { buffer = second })
feed "zy"
assert(key_count "n zy" == 2, "deleted local map still shadows global")

-- Local metadata, leaders, expr callbacks and operator/Visual modes.
local keymaps = require "config.keymaps"
vim.g.mapleader = " "
keymaps.set("n", "<leader>zz", function() end, { group = "test", desc = "local | `callback`" })
feed "<Space>zz"
assert(key_count "n <Space>zz" == 1, "callback or leader counted incorrectly")
assert(snapshot().keys["n <Space>zz"].group == "test")
keymaps.set("i", "jj", function()
  return "<Esc>"
end, { expr = true, group = "test" })
feed "ijj"
assert(key_count "i jj" == 1, "expr callback not tracked")
keymaps.set({ "x", "o" }, "iz", function() end, { group = "test" })
feed "diz<Esc>"
assert(key_count "o iz" == 1, "operator-pending mode recorded as normal")
assert(key_count "n iz" == 0)
feed "viz<Esc>"
assert(key_count "x iz" == 1)
keymaps.set("n", "zt", function() end, { buffer = true, group = "test" })
feed "zt"
assert(snapshot().keys["n zt [buffer]"].group == "test")
vim.keymap.set("n", "zt", function() end, { buffer = second, desc = "replacement" })
feed "zt"
assert(key_count "n zt [buffer]" == 2)
assert(snapshot().keys["n zt [buffer]"].group == "external", "replacement inherited stale metadata")

-- No per-action writes; one bounded timer flushes a burst, and no-op flushes don't write.
local writefile = vim.fn.writefile
local writes = 0
vim.fn.writefile = function(...)
  writes = writes + 1
  return writefile(...)
end
for _ = 1, 20 do
  audit.record_command "AuditExample"
end
assert(writes == 0, "input path wrote to disk")
assert(
  vim.wait(2000, function()
    return writes == 1
  end, 10),
  "timer did not flush"
)
assert(commands().AuditExample.count == 24)
assert(writes == 1, "redundant flush wrote to disk")
assert(vim.fn.glob(path .. ".*.tmp") == "", "temporary state file left behind")
vim.fn.writefile = writefile

-- Failed saves retain pending data for retry rather than disabling the input hook.
local notify = vim.notify
vim.notify = function() end
vim.fn.writefile = function()
  error "simulated disk failure"
end
audit.record_command "AuditExample"
assert(not audit.flush())
vim.fn.writefile = writefile
vim.notify = notify
assert(commands().AuditExample.count == 25)

vim.api.nvim_del_user_command "AuditExample"
vim.api.nvim_buf_create_user_command(second, "BufferAuditCommand", function() end, {})
audit.report()
local report = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
assert(report:find("`:write`", 1, true), "built-in missing from report")
assert(report:find("`:AuditExample`", 1, true), "removed command missing from report")
assert(report:find("`:BufferAuditCommand`", 1, true), "buffer command missing from report")
assert(report:find("`old`", 1, true), "historical mapping missing from report")
assert(report:find("local &#124; &#96;callback&#96;", 1, true), "Markdown table not escaped")
audit.report() -- Reopening must not fail with an existing report buffer.

-- Exit flushes without waiting for the timer, and reset cancels pending writes.
audit.record_command "write"
vim.api.nvim_exec_autocmds("VimLeavePre", {})
assert(vim.json.decode(table.concat(vim.fn.readfile(path), "\n")).commands.write.count == 2)
audit.record_command "write"
audit.reset()
assert(vim.tbl_isempty(snapshot().commands))
assert(vim.tbl_isempty(snapshot().keys))
vim.wait(1100, function()
  return false
end)
assert(vim.tbl_isempty(snapshot().commands), "old timer restored reset data")
vim.fn.delete(tmp, "rf")
print "usage audit: command origin, live mappings, scope, persistence, history and report OK"
vim.cmd "qa!"
