-- Virtual plugins manage setup for config modules without installing a repository.
-- Keep requires inside setup: modules on the config runtimepath are not automatically
-- associated with these specs by lazy's require loader.
local function feature(module, spec)
  spec = spec or {}
  spec[1] = "local-" .. module:gsub("_", "-")
  spec.virtual = true
  spec.main = "config." .. module
  spec.opts = {}
  return spec
end

-- Trigger-only mappings let each module's setup install the real, audited mapping.
local function keys(mappings, mode)
  local result = {}
  for _, mapping in ipairs(mappings) do
    result[#result + 1] = { mapping[1], desc = mapping[2], mode = mode or "n" }
  end
  return result
end

local review_keys = keys {
  { "]n", "Next review comment" },
  { "[n", "Previous review comment" },
  { "<leader>ro", "Open change review" },
  { "<leader>rf", "Review file checklist" },
  { "<leader>rn", "Unreviewed files" },
  { "<leader>rr", "Toggle hunk reviewed" },
  { "<leader>rq", "Review hunks in quickfix" },
  { "<leader>rp", "Preview snapshot hunk" },
  { "<leader>rR", "Rebuild review snapshot and refresh Diffview" },
  { "<leader>rc", "Add review comment" },
  { "<leader>rC", "Add file review comment" },
  { "<leader>rl", "Review comments" },
  { "<leader>ry", "Export review" },
  { "<leader>rY", "Copy review to +" },
}
review_keys[#review_keys + 1] = { "<leader>rc", mode = "x", desc = "Comment on selected lines" }

local text_keys = keys({
  { "r", "Rest of paragraph text object" },
  { "n", "Near end-of-line text object" },
  { "a_", "Around line text object" },
  { "i_", "Inside line text object" },
  { "ay", "Around Python docstring" },
  { "iy", "Inside Python docstring" },
}, { "o", "x" })
vim.list_extend(
  text_keys,
  keys {
    { "dsi", "Delete surrounding indentation" },
    { ">p", "Indent last change" },
    { "<p", "Unindent last change" },
  }
)

return {
  -- These must be ready before interaction or the first UI render.
  feature("usage_audit", { lazy = false, priority = 2000 }),
  feature("theme", { lazy = false, priority = 1000 }),
  feature("modicator", { lazy = false, dependencies = { "local-theme" } }),
  feature("simple_bufferline", { lazy = false }),
  feature("statusline", { lazy = false }),
  -- Configure the provider before any direct "+ yank/paste, not just <leader>y.
  feature("osc52", { lazy = false }),

  -- Register FileType handlers before the first file is processed. FileType also
  -- covers unnamed buffers whose filetype is set without reading/creating a file.
  feature("lsp", { event = { "BufReadPre", "BufNewFile", "FileType" } }),
  feature("linting", { event = { "BufReadPost", "BufNewFile", "BufWritePost", "InsertLeave" } }),
  feature("test_review", {
    -- Load before BufEnter so saved Python review marks render on first open.
    event = { "BufReadPost", "BufNewFile" },
    keys = keys {
      { "<leader>tr", "Toggle current test reviewed" },
      { "<leader>tR", "Reset reviewed tests in project" },
      { "sta", "Search all tests" },
      { "str", "Search unreviewed tests" },
      { "]u", "Next unreviewed test" },
      { "[u", "Previous unreviewed test" },
      { "]r", "Next reviewed test" },
      { "[r", "Previous reviewed test" },
    },
  }),
  feature("todos", {
    ft = "python",
    keys = keys {
      { "sto", "Open TODOs in Snacks picker" },
      { "]t", "Next TODO" },
      { "[t", "Previous TODO" },
    },
  }),
  feature("formatting", { keys = keys { { "gq", "Format buffer" } } }),
  feature("notes", {
    keys = keys {
      { "<leader>of", "Open notes picker" },
      { "<leader>on", "Create new note" },
      { "<leader>ot", "Open today's daily note" },
    },
  }),
  feature("simple_harpoon", {
    keys = keys {
      { "mm", "Mark file" },
      { "mq", "Show marked files" },
      { "ma", "Go to mark 1" },
      { "ms", "Go to mark 2" },
      { "md", "Go to mark 3" },
      { "mf", "Go to mark 4" },
      { "mg", "Go to terminal 1" },
    },
  }),
  feature("change_review", {
    -- Saved comments attach on BufWinEnter, even before invoking a review action.
    event = { "BufReadPost", "BufNewFile" },
    cmd = "ChangeReview",
    keys = review_keys,
  }),
  feature("variable_part_textobj", {
    keys = keys({
      { "is", "Inner variable name part" },
      { "as", "Around variable name part" },
    }, { "o", "x" }),
  }),
  feature("text_helpers", { keys = text_keys }),
  -- blink also depends on this spec so its fallback captures the real Tab mapping.
  feature("tabout", { event = "InsertEnter" }),
  feature("unimpaired", {
    keys = keys {
      { "]q", "Next quickfix item" },
      { "[q", "Previous quickfix item" },
      { "]Q", "Last quickfix item" },
      { "[Q", "First quickfix item" },
      { "<C-q>", "Toggle quickfix list" },
      { "]l", "Next location-list item" },
      { "[l", "Previous location-list item" },
      { "]L", "Last location-list item" },
      { "[L", "First location-list item" },
      { "]b", "Next buffer" },
      { "[b", "Previous buffer" },
      { "]B", "Last buffer" },
      { "[B", "First buffer" },
      { "yow", "Toggle wrap" },
      { "[ow", "Disable wrap" },
      { "]ow", "Enable wrap" },
      { "yos", "Toggle spell" },
      { "[os", "Disable spell" },
      { "]os", "Enable spell" },
      { "yon", "Toggle line numbers" },
      { "yor", "Toggle relative numbers" },
      { "yol", "Toggle list chars" },
      { "yoh", "Toggle search highlight" },
      { "yoc", "Toggle cursorline" },
      { "yoC", "Toggle conceallevel" },
    },
  }),
}
