-- Run from the config root: nvim --headless -u NONE -l scripts/test-local-features.lua
-- Uses installed lazy.nvim, no downloads or external language tools.
local root = vim.fn.getcwd()
local lazy_path = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp, "p")
local stdpath = vim.fn.stdpath
vim.fn.stdpath = function(what)
  if what == "state" or what == "data" or what == "cache" then
    return tmp .. "/" .. what
  end
  return stdpath(what)
end
vim.opt.rtp:prepend(root)
vim.opt.rtp:prepend(lazy_path)
vim.o.loadplugins = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "

package.loaded["config.toolchain"] = {
  lsp_servers = function()
    return {}
  end,
  linters_for = function()
    return {}
  end,
  tools = function()
    return {}
  end,
}
local specs = require "plugins.local_features"
local setup_counts, captured_maps = {}, {}
local loader = require "lazy.core.loader"
local original_config = loader.config
local lint_calls, review_attachments = 0, 0
loader.config = function(plugin)
  if not plugin.virtual then
    return original_config(plugin)
  end
  setup_counts[plugin.name] = (setup_counts[plugin.name] or 0) + 1
  captured_maps[plugin.name] = {}
  local set = vim.keymap.set
  vim.keymap.set = function(mode, lhs, rhs, opts)
    local modes = type(mode) == "table" and mode or { mode }
    for _, m in ipairs(modes) do
      captured_maps[plugin.name][m .. ":" .. lhs] = true
    end
    return set(mode, lhs, rhs, opts)
  end
  original_config(plugin)
  vim.keymap.set = set
  if plugin.name == "local-formatting" then
    -- The installed mapping calls M.format dynamically. Never launch a formatter.
    require("config.formatting").format = function()
      vim.g.format_calls = (vim.g.format_calls or 0) + 1
    end
  elseif plugin.name == "local-change-review" then
    local review = require "config.change_review"
    local attach = review.attach
    review.attach = function(...)
      review_attachments = review_attachments + 1
      return attach(...)
    end
  elseif plugin.name == "local-linting" then
    require("config.linting").try_lint = function()
      lint_calls = lint_calls + 1
    end
  end
end

require("lazy").setup(specs, {
  root = tmp .. "/plugins",
  lockfile = tmp .. "/lazy-lock.json",
  install = { missing = false },
  checker = { enabled = false },
  change_detection = { enabled = false },
  performance = { rtp = { reset = false } },
})
local plugins = require("lazy.core.config").plugins
local function loaded(module)
  return plugins["local-" .. module:gsub("_", "-")]._.loaded ~= nil
end
local function feed(input)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(input, true, false, true), "xt", false)
end
for _, spec in ipairs(specs) do
  local plugin = plugins[spec[1]]
  assert(plugin.virtual and plugin._.is_local and plugin._.installed, spec[1])
  assert((plugin._.loaded ~= nil) == (spec.lazy == false), "Unexpected startup load: " .. spec[1])
  if spec.lazy ~= false then
    assert(not package.loaded[spec.main], "Eager require: " .. spec.main)
  end
end
assert(vim.g.colors_name == "catppuccin-macchiato")
assert(vim.o.statusline:find("nvim_config_statusline", 1, true))
assert(vim.g.clipboard.name == "OSC 52")

if vim.env.LOCAL_FEATURES_TEST_FILE == "1" then
  vim.cmd "filetype on"
  local file = tmp .. "/test_example.py"
  vim.fn.writefile({ "# TODO: first file", "@test", "def test_example():", "    pass" }, file)
  vim.fn.mkdir(tmp .. "/data/test-review", "p")
  vim.fn.writefile({
    vim.json.encode {
      projects = {
        [root] = { reviewed = { [file .. "::test_example"] = { lnum = 3, line = "def test_example():" } } },
      },
    },
  }, tmp .. "/data/test-review/state.json")
  vim.cmd.edit(file)
  for _, module in ipairs { "lsp", "linting", "test_review", "change_review", "todos" } do
    assert(loaded(module), "First file missed feature: " .. module)
  end
  assert(lint_calls > 0, "First file missed linting")
  assert(review_attachments > 0, "First file missed review attachment")
  local todo_ns = vim.api.nvim_create_namespace "python-todo-comment-blocks"
  assert(#vim.api.nvim_buf_get_extmarks(0, todo_ns, 0, -1, {}) == 1)
  local test_ns = vim.api.nvim_create_namespace "test-review"
  assert(#vim.api.nvim_buf_get_extmarks(0, test_ns, 0, -1, {}) > 0, "First file missed test marks")
  assert(not loaded "formatting" and not loaded "notes" and not loaded "simple_harpoon")
  vim.fn.delete(tmp, "rf")
  print "local features: first Python file loads handlers and renders TODO/test marks, review attachment OK"
  vim.cmd "qa!"
  return
end

feed "gq"
assert(loaded "formatting" and vim.g.format_calls == 1, "First formatting key was lost")
feed "gq"
assert(vim.g.format_calls == 2)
local wrap = vim.wo.wrap
feed "yow"
assert(loaded "unimpaired" and vim.wo.wrap ~= wrap, "First toggle key was lost")

vim.api.nvim_buf_set_lines(0, 0, -1, false, { "snake_case" })
vim.api.nvim_win_set_cursor(0, { 1, 0 })
feed "dis"
assert(loaded "variable_part_textobj")
assert(vim.api.nvim_get_current_line() == "_case", "First operator-pending key was lost")
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "  hello" })
vim.api.nvim_win_set_cursor(0, { 1, 2 })
feed "di_"
assert(loaded "text_helpers" and vim.api.nvim_get_current_line() == "  ")

local prompted = false
vim.ui.input = function(_, callback)
  prompted = true
  callback(nil)
end
feed "<leader>on"
assert(loaded "notes" and prompted, "First note key was lost")
-- Resolve the lazy command through completion without opening a review or writing state.
assert(vim.tbl_contains(vim.fn.getcompletion("ChangeReview prev", "cmdline"), "prev"))
assert(loaded "change_review")

-- FileType-only buffers must also enable LSP setup and Python TODO highlighting.
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# TODO: first file", "# continued" })
vim.bo.filetype = "python"
assert(loaded "lsp" and loaded "todos")
local ns = vim.api.nvim_create_namespace "python-todo-comment-blocks"
assert(#vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {}) == 2, "First FileType wasn't replayed")

vim.api.nvim_exec_autocmds("BufReadPost", { buffer = 0 })
assert(loaded "linting" and loaded "test_review")
vim.api.nvim_exec_autocmds("BufEnter", { buffer = 0 })
assert(lint_calls > 0, "Lint handler missed first buffer entry")
vim.api.nvim_exec_autocmds("InsertEnter", { buffer = 0 })
assert(loaded "tabout" and vim.fn.maparg("<Tab>", "i") ~= "")

-- Load remaining key-only features, then verify every setup mapping has a trigger.
-- This catches forgotten keys when existing modules gain or rename mappings.
for _, spec in ipairs(specs) do
  loader.load({ spec[1] }, { test = "mapping coverage" })
  assert(setup_counts[spec[1]] == 1, "Setup must run once: " .. spec[1])
  if spec.keys then
    local declared = {}
    for _, key in ipairs(spec.keys) do
      local modes = type(key.mode) == "table" and key.mode or { key.mode or "n" }
      for _, mode in ipairs(modes) do
        local id = mode .. ":" .. key[1]
        declared[id] = true
        assert(captured_maps[spec[1]][id], "Trigger has no real mapping: " .. id)
      end
    end
    for id in pairs(captured_maps[spec[1]]) do
      assert(declared[id], "Mapping has no lazy trigger: " .. spec[1] .. " " .. id)
    end
  end
end
local completion = dofile(root .. "/lua/plugins/completion.lua")[1]
assert(vim.tbl_contains(completion.dependencies, "local-tabout"))
-- lazy replays the first LHS after setup; the audit must count the user's input
-- once, not once for the trigger and again for its programmatic replay.
assert(require("config.usage_audit").flush())
local usage = vim.json.decode(table.concat(vim.fn.readfile(tmp .. "/state/usage-audit.json"), "\n")).keys
assert(usage["n gq"].count == 2, "Lazy trigger/replay counted twice")
assert(usage["o is"].count == 1, "First lazy text object missed or doubled")
assert(usage["o i_"].count == 1, "First lazy line text object missed or doubled")
vim.fn.delete(tmp, "rf")
print "local features: loading, first-use keys, usage counts, command completion, events and mapping coverage OK"
vim.cmd "qa!"
