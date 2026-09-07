local M = {}

local default_project_dirs = {
  "~/Projects",
  "~/.config/nvim",
  "~/.dotfiles",
  "~/vault",
}

local function snacks_picker()
  return require("snacks").picker
end

local function qf_text(item)
  return item.line or item.comment or item.label or item.name or item.detail or item.text
end

local function qf_type(item)
  return ({ "E", "W", "I", "N" })[item.severity]
end

local function qf_entry(picker, item)
  picker:resolve(item)

  local path = snacks_picker().util.path(item)
  local bufnr = item.buf
  if (bufnr == nil or not vim.api.nvim_buf_is_valid(bufnr)) and path ~= nil and path ~= "" then
    bufnr = vim.fn.bufadd(path)
  end

  return {
    bufnr = bufnr,
    filename = bufnr == nil and path or nil,
    lnum = item.pos and item.pos[1] or 1,
    col = item.pos and item.pos[2] + 1 or 1,
    end_lnum = item.end_pos and item.end_pos[1] or nil,
    end_col = item.end_pos and item.end_pos[2] + 1 or nil,
    text = qf_text(item),
    pattern = item.search,
    type = qf_type(item),
    valid = true,
  }
end

local function selected_or_all_items(picker, all)
  if all then
    return picker:items()
  end

  local selected = picker:selected()
  return #selected > 0 and selected or picker:items()
end

local function set_qf_items(picker, items, opts)
  local qf_items = vim.tbl_map(function(item)
    return qf_entry(picker, item)
  end, items)

  picker:close()
  if opts and opts.win then
    vim.fn.setloclist(opts.win, {}, "r", { title = picker.opts.title or "Snacks picker", items = qf_items })
    vim.cmd "botright lopen"
  else
    vim.fn.setqflist({}, "r", { title = picker.opts.title or "Snacks picker", items = qf_items })
    vim.cmd "botright copen"
  end
end

local function project_dirs()
  local dirs = vim.deepcopy(default_project_dirs)
  for _, dir in ipairs(require("config.utils").load_local_options().project_base_dirs) do
    if type(dir) == "string" then
      table.insert(dirs, dir)
    elseif type(dir) == "table" and dir.path then
      table.insert(dirs, dir.path)
    end
  end
  return dirs
end

local function register_items()
  local items = {}
  for i = 0, 9 do
    local register = tostring(i)
    local value = vim.fn.getreg(register)
    if value ~= "" then
      table.insert(items, {
        text = string.format("[%s] %s", register, value:gsub("\n", "\\n")),
        register = register,
      })
    end
  end
  return items
end

function M.non_daily_notes()
  snacks_picker().files {
    cwd = "~/vault",
    exclude = { "daybook", "templates" },
    ft = ".md",
    title = "Notes",
  }
end

--- Run a list picker over precomputed items, owning the close-then-choose boilerplate.
---@param opts {title?: string, items: table, format: function, on_choose?: function}
function M.list(opts)
  local on_choose = opts.on_choose
  snacks_picker() {
    title = opts.title,
    items = opts.items,
    format = opts.format,
    confirm = function(picker, item)
      picker:close()
      if on_choose then
        on_choose(item)
      end
    end,
  }
end

--- Forward an arbitrary picker spec to snacks for advanced cases (custom actions, finders, windows).
---@param opts table
function M.picker(opts)
  return snacks_picker()(opts)
end

function M.lsp_references()
  snacks_picker().lsp_references()
end

function M.lsp_implementations()
  snacks_picker().lsp_implementations()
end

function M.lsp_definitions()
  snacks_picker().lsp_definitions()
end

function M.lsp_symbols()
  snacks_picker().lsp_symbols()
end

function M.lsp_type_definitions()
  snacks_picker().lsp_type_definitions()
end

function M.registers_0_to_9()
  M.list {
    title = "Registers 0-9 (Yank/Delete)",
    items = register_items(),
    format = function(item)
      return { { item.text } }
    end,
    on_choose = function(item)
      vim.fn.setreg('"', vim.fn.getreg(item.register))
      vim.cmd 'normal! ""p'
    end,
  }
end

function M.projects()
  snacks_picker().projects {
    dev = project_dirs(),
    max_depth = 2,
  }
end

--- Send selected picker items, or all items when none are selected, to the quickfix list.
---@param picker snacks.Picker
function M.qflist(picker)
  set_qf_items(picker, selected_or_all_items(picker, false))
end

--- Send all picker items to the quickfix list.
---@param picker snacks.Picker
function M.qflist_all(picker)
  set_qf_items(picker, selected_or_all_items(picker, true))
end

--- Send selected picker items, or all items when none are selected, to the location list.
---@param picker snacks.Picker
function M.loclist(picker)
  set_qf_items(picker, selected_or_all_items(picker, false), { win = picker.main })
end

--- Open a git-aware file picker that includes tracked and untracked non-ignored files.
---@param opts? table
function M.git_files(opts)
  opts = vim.tbl_extend("force", { untracked = true }, opts or {})
  snacks_picker().git_files(opts)
end

--- Run a fixed-search grep picker, owning the non-live default; callers pass the search intent.
---@param opts table
function M.grep(opts)
  snacks_picker().grep(vim.tbl_extend("force", { live = false }, opts))
end

function M.grep_from_input()
  local search = vim.fn.input "Grep > "
  if search == "" then
    return
  end

  M.grep {
    search = search,
    regex = false,
    title = "Grep: " .. search,
    transform = function(item)
      item.text = item.file or item.text
      return item
    end,
  }
end

function M.grep_word_from_input()
  local search = vim.fn.input "Grep word > "
  if search == "" then
    return
  end

  M.grep {
    search = search,
    regex = false,
    args = { "--word-regexp" },
    title = "Grep word: " .. search,
    transform = function(item)
      item.text = item.file or item.text
      return item
    end,
  }
end

local function remove_qf_item(picker, item)
  if item == nil then
    return
  end

  local qf = vim.fn.getqflist { items = 1, title = 1 }
  local valid_index = 0
  for index, qf_item in ipairs(qf.items) do
    if qf_item.valid == 1 then
      valid_index = valid_index + 1
      if valid_index == item.idx then
        table.remove(qf.items, index)
        break
      end
    end
  end

  vim.fn.setqflist({}, "r", { title = qf.title, items = qf.items })
  if vim.tbl_isempty(qf.items) then
    picker:close()
    return
  end
  picker:refresh()
end

function M.open_qflist()
  snacks_picker().qflist {
    title = "Quickfix list (dd: remove)",
    actions = {
      quickfix_remove = remove_qf_item,
    },
    win = {
      input = {
        keys = {
          dd = { "quickfix_remove", mode = "n", desc = "Remove quickfix entry" },
        },
      },
      list = {
        keys = {
          dd = { "quickfix_remove", desc = "Remove quickfix entry" },
        },
      },
    },
  }
end

function M.remove_current_qf_entry()
  local index = vim.api.nvim_win_get_cursor(0)[1]
  local qf = vim.fn.getqflist { items = 1, title = 1, context = 1 }
  if table.remove(qf.items, index) == nil then
    return
  end

  if vim.tbl_isempty(qf.items) then
    vim.fn.setqflist({}, "r", { title = qf.title, context = qf.context, items = {} })
    vim.cmd.cclose()
    return
  end

  local next_index = math.min(index, #qf.items)
  vim.fn.setqflist({}, "r", {
    title = qf.title,
    context = qf.context,
    items = qf.items,
  })
  vim.fn.setqflist({}, "a", { idx = next_index })
  vim.api.nvim_win_set_cursor(0, { next_index, 0 })
end

function M.keys()
  return {
    {
      "sf",
      M.git_files,
      desc = "Search git files",
    },
    {
      "sF",
      function()
        snacks_picker().files { hidden = true }
      end,
      desc = "Find all files (including hidden)",
    },
    {
      "stp",
      function()
        M.git_files { search = "!tests .py", title = "Python files (no tests)" }
      end,
      desc = "Search Python files (excluding tests)",
    },
    {
      "stP",
      function()
        M.git_files { search = "tests .py", title = "Python test files" }
      end,
      desc = "Search Python test files only",
    },
    {
      "stl",
      function()
        M.git_files { search = ".lua", title = "Lua files" }
      end,
      desc = "Search Lua files",
    },
    {
      "sl",
      function()
        snacks_picker().grep()
      end,
      desc = "Search live grep",
    },
    {
      "su",
      function()
        snacks_picker().lines()
      end,
      desc = "Fuzzy find in current buffer",
    },
    {
      "so",
      function()
        snacks_picker().recent()
      end,
      desc = "Search old files",
    },
    {
      "s/",
      M.grep_from_input,
      desc = "Search text from user input",
    },
    {
      "s?",
      M.grep_word_from_input,
      desc = "Search whole word from user input",
    },
    {
      "sd",
      function()
        snacks_picker().diagnostics()
      end,
      desc = "Open all diagnostics",
    },
    {
      "sq",
      M.open_qflist,
      desc = "Search quickfix list",
    },
    {
      "sk",
      function()
        snacks_picker().keymaps()
      end,
      desc = "Search all keymaps",
    },
    {
      "s<space>",
      function()
        snacks_picker().buffers()
      end,
      desc = "Search buffers",
    },
    {
      "sw",
      function()
        snacks_picker().grep_word()
      end,
      desc = "Search word under cursor",
    },
    {
      "sW",
      function()
        snacks_picker().grep { args = { "--word-regexp" } }
      end,
      desc = "Search whole words",
    },
    {
      "sm",
      function()
        snacks_picker().marks()
      end,
      desc = "Search marks",
    },
    {
      "sgc",
      function()
        snacks_picker().git_status()
      end,
      desc = "Search files with git changes",
    },
    {
      "sgb",
      function()
        snacks_picker().git_branches()
      end,
      desc = "Search git branches",
    },
    {
      "sp",
      M.projects,
      desc = "Search projects",
    },
    {
      "sra",
      function()
        snacks_picker().registers()
      end,
      desc = "Search all registers",
    },
    {
      "srd",
      M.registers_0_to_9,
      desc = "Search registers 0-9 (yank/delete only)",
    },
  }
end

return M
