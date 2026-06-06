local M = {}

local NS = vim.api.nvim_create_namespace "test-review"
local MAX_DECORATOR_BLOCK_LINES = 40

local cached_state = nil

local function trim(value)
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function indent_width(line)
  return #(line:match "^%s*" or "")
end

local function test_decorator(line)
  return line:match "^%s*@test%s*[%(%s]" ~= nil or line:match "^%s*@test%s*$" ~= nil
end

local function function_name(line)
  return line:match "^%s*async%s+def%s+([%w_]+)%s*%(" or line:match "^%s*def%s+([%w_]+)%s*%("
end

local function class_name(line)
  return line:match "^%s*class%s+([%w_]+)"
end

local function boundary_line(line, indent)
  if trim(line) == "" then
    return false
  end

  if indent_width(line) > indent then
    return false
  end

  return function_name(line) ~= nil or class_name(line) ~= nil or line:match "^%s*@" ~= nil
end

local function project_key()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":p"):gsub("/$", "")
end

local function relative_file(file)
  local root = project_key()
  local absolute = vim.fn.fnamemodify(file, ":p")
  local prefix = root .. "/"

  if absolute:sub(1, #prefix) == prefix then
    return absolute:sub(#prefix + 1)
  end

  return absolute
end

local function state_path()
  return vim.fn.stdpath "data" .. "/test-review/state.json"
end

local function load_state()
  if cached_state ~= nil then
    return cached_state
  end

  local path = state_path()
  if vim.fn.filereadable(path) ~= 1 then
    cached_state = { projects = {} }
    return cached_state
  end

  local ok, decoded = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(path), "\n"))
  if not ok or type(decoded) ~= "table" then
    cached_state = { projects = {} }
    return cached_state
  end

  decoded.projects = decoded.projects or {}
  cached_state = decoded
  return cached_state
end

local function save_state(state)
  state = state or load_state()
  local path = state_path()
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  vim.fn.writefile({ vim.fn.json_encode(state) }, path)
  cached_state = state
end

local function project_state(state)
  state = state or load_state()
  local key = project_key()
  state.projects[key] = state.projects[key] or { reviewed = {} }
  state.projects[key].reviewed = state.projects[key].reviewed or {}
  return state.projects[key]
end

local function class_path(class_stack, function_indent)
  local names = {}
  for _, class in ipairs(class_stack) do
    if class.indent < function_indent then
      table.insert(names, class.name)
    end
  end
  return table.concat(names, ".")
end

local function add_end_lines(tests, lines)
  for _, test in ipairs(tests) do
    test.end_lnum = #lines
    for lnum = test.lnum + 1, #lines do
      if boundary_line(lines[lnum], test.indent) then
        test.end_lnum = lnum - 1
        break
      end
    end
  end
end

--- Find Python tests in lines. Tests are functions decorated with @test(...).
--- @param lines string[]
--- @param file string
--- @return table[]
local function parse_tests(lines, file)
  local tests = {}
  local pending_decorators = nil
  local class_stack = {}

  for lnum, line in ipairs(lines) do
    local class = class_name(line)
    if class ~= nil then
      local indent = indent_width(line)
      while #class_stack > 0 and class_stack[#class_stack].indent >= indent do
        table.remove(class_stack)
      end
      table.insert(class_stack, { name = class, indent = indent })
      pending_decorators = nil
    elseif line:match "^%s*@" then
      if pending_decorators == nil then
        pending_decorators = {
          start_lnum = lnum,
          has_test = false,
          indent = indent_width(line),
        }
      end
      pending_decorators.has_test = pending_decorators.has_test or test_decorator(line)
    elseif pending_decorators ~= nil and function_name(line) ~= nil then
      if pending_decorators.has_test then
        local indent = indent_width(line)
        local name = function_name(line)
        local parent = class_path(class_stack, indent)
        local qualified_name = parent ~= "" and (parent .. "." .. name) or name
        local id = file .. "::" .. qualified_name

        table.insert(tests, {
          id = id,
          file = file,
          decorator_lnum = pending_decorators.start_lnum,
          lnum = lnum,
          end_lnum = lnum,
          col = 1,
          name = name,
          qualified_name = qualified_name,
          line = line,
          text = string.format("%s:%d %s", file, lnum, qualified_name),
          indent = indent,
          reviewed = false,
        })
      end
      pending_decorators = nil
    elseif pending_decorators ~= nil then
      local line_is_blank = trim(line) == ""
      local line_can_continue_decorator = indent_width(line) > pending_decorators.indent or line:match "^%s*[%]})]" ~= nil
      local decorator_block_too_long = (lnum - pending_decorators.start_lnum) > MAX_DECORATOR_BLOCK_LINES

      if line_is_blank or decorator_block_too_long or not line_can_continue_decorator then
        pending_decorators = nil
      end
    end
  end

  add_end_lines(tests, lines)
  return tests
end

local function apply_review_state(tests, update_locations)
  local state = load_state()
  local reviewed = project_state(state).reviewed
  local changed = false

  for _, test in ipairs(tests) do
    local entry = reviewed[test.id]
    test.reviewed = entry ~= nil

    if entry ~= nil and update_locations then
      if entry.lnum ~= test.lnum or entry.line ~= test.line then
        entry.lnum = test.lnum
        entry.line = test.line
        changed = true
      end
    end
  end

  if changed then
    save_state(state)
  end

  return tests
end

local function buffer_lines(bufnr)
  return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

local function buffer_file(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return nil
  end
  return relative_file(name)
end

local function current_buffer_tests(update_locations)
  local bufnr = vim.api.nvim_get_current_buf()
  local file = buffer_file(bufnr)
  if file == nil then
    return {}
  end
  return apply_review_state(parse_tests(buffer_lines(bufnr), file), update_locations)
end

local function current_test()
  local cursor_lnum = vim.api.nvim_win_get_cursor(0)[1]
  local best = nil

  for _, test in ipairs(current_buffer_tests(false)) do
    if cursor_lnum >= test.decorator_lnum and cursor_lnum <= test.end_lnum then
      best = test
    end
  end

  return best
end

local function set_reviewed(test, reviewed)
  local state = load_state()
  local marks = project_state(state).reviewed

  if reviewed then
    marks[test.id] = {
      id = test.id,
      file = test.file,
      name = test.name,
      qualified_name = test.qualified_name,
      lnum = test.lnum,
      line = test.line,
      reviewed_at = os.date "!%Y-%m-%dT%H:%M:%SZ",
    }
  else
    marks[test.id] = nil
  end

  save_state(state)
end

local function render_buffer(bufnr, update_locations)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end

  local file = buffer_file(bufnr)
  if file == nil or not file:match "%.py$" then
    return
  end

  local tests = apply_review_state(parse_tests(buffer_lines(bufnr), file), update_locations)
  vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)

  for _, test in ipairs(tests) do
    if test.reviewed then
      vim.api.nvim_buf_set_extmark(bufnr, NS, test.lnum - 1, 0, {
        virt_text = { { " ✓ reviewed", "DiagnosticOk" } },
        virt_text_pos = "eol",
        hl_mode = "combine",
      })
    end
  end
end

local function render_all_loaded_buffers()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      render_buffer(bufnr, false)
    end
  end
end

function M.mark_current()
  local test = current_test()
  if test == nil then
    vim.notify("No @test-decorated test under cursor", vim.log.levels.WARN)
    return
  end

  set_reviewed(test, true)
  render_buffer(vim.api.nvim_get_current_buf(), false)
  vim.notify("Reviewed: " .. test.qualified_name, vim.log.levels.INFO)
end

function M.unmark_current()
  local test = current_test()
  if test == nil then
    vim.notify("No @test-decorated test under cursor", vim.log.levels.WARN)
    return
  end

  set_reviewed(test, false)
  render_buffer(vim.api.nvim_get_current_buf(), false)
  vim.notify("Unreviewed: " .. test.qualified_name, vim.log.levels.INFO)
end

function M.toggle_current()
  local test = current_test()
  if test == nil then
    vim.notify("No @test-decorated test under cursor", vim.log.levels.WARN)
    return
  end

  set_reviewed(test, not test.reviewed)
  render_buffer(vim.api.nvim_get_current_buf(), false)

  if test.reviewed then
    vim.notify("Unreviewed: " .. test.qualified_name, vim.log.levels.INFO)
  else
    vim.notify("Reviewed: " .. test.qualified_name, vim.log.levels.INFO)
  end
end

local function jump_in_current_buffer(reviewed, direction)
  local cursor_lnum = vim.api.nvim_win_get_cursor(0)[1]
  local tests = current_buffer_tests(false)
  local label = reviewed and "reviewed" or "unreviewed"
  local target = nil

  if direction > 0 then
    for _, test in ipairs(tests) do
      if test.reviewed == reviewed and test.lnum > cursor_lnum then
        target = test
        break
      end
    end
  else
    for index = #tests, 1, -1 do
      local test = tests[index]
      if test.reviewed == reviewed and test.lnum < cursor_lnum then
        target = test
        break
      end
    end
  end

  if target == nil then
    local side = direction > 0 and "next" or "previous"
    vim.notify("No " .. side .. " " .. label .. " test", vim.log.levels.INFO)
    return
  end

  vim.api.nvim_win_set_cursor(0, { target.lnum, 0 })
  vim.cmd "normal! zz"
end

function M.next_unreviewed()
  jump_in_current_buffer(false, 1)
end

function M.prev_unreviewed()
  jump_in_current_buffer(false, -1)
end

function M.next_reviewed()
  jump_in_current_buffer(true, 1)
end

function M.prev_reviewed()
  jump_in_current_buffer(true, -1)
end

local function python_files()
  if vim.fn.executable "fd" == 1 then
    local files = vim.fn.systemlist { "fd", "--type", "f", "--extension", "py", "--hidden", "--exclude", ".git", "--color", "never" }
    if vim.v.shell_error == 0 then
      return files
    end
  end

  if vim.fn.executable "git" == 1 and vim.fn.isdirectory ".git" == 1 then
    local files = vim.fn.systemlist { "git", "ls-files", "*.py" }
    if vim.v.shell_error == 0 then
      return files
    end
  end

  return vim.fn.globpath(vim.fn.getcwd(), "**/*.py", false, true)
end

local function tests_in_file(file, update_locations)
  if vim.fn.filereadable(file) ~= 1 then
    return {}
  end

  local ok, lines = pcall(vim.fn.readfile, file)
  if not ok then
    return {}
  end

  return apply_review_state(parse_tests(lines, relative_file(file)), update_locations)
end

function M.all_tests()
  local tests = {}
  for _, file in ipairs(python_files()) do
    for _, test in ipairs(tests_in_file(file, true)) do
      table.insert(tests, test)
    end
  end
  return tests
end

function M.unreviewed_tests()
  return vim.tbl_filter(function(test)
    return not test.reviewed
  end, M.all_tests())
end

local function jump_to_test(test)
  vim.cmd.edit(vim.fn.fnameescape(test.file))
  vim.api.nvim_win_set_cursor(0, { test.lnum, 0 })
  vim.cmd "normal! zz"
  render_buffer(vim.api.nvim_get_current_buf(), false)
end

local function quickfix(items, title)
  local qf_items = vim.tbl_map(function(test)
    local status = test.reviewed and "✓" or "○"
    return {
      filename = test.file,
      lnum = test.lnum,
      col = test.col,
      text = string.format("%s %s %s", status, test.qualified_name, trim(test.line)),
    }
  end, items)

  vim.fn.setqflist({}, " ", { title = title, items = qf_items })
  vim.cmd.copen()
end

local function open_test_picker(items, title)
  local ok, snacks = pcall(require, "snacks")
  if not ok or snacks.picker == nil then
    quickfix(items, title)
    return
  end

  snacks.picker {
    title = string.format("%s (%d)", title, #items),
    items = items,
    format = function(item)
      local status = item.reviewed and "✓ " or "○ "
      return {
        { status, item.reviewed and "DiagnosticOk" or "DiagnosticWarn" },
        { item.file .. ":" .. item.lnum .. " ", "Comment" },
        { item.qualified_name, "Function" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      jump_to_test(item)
    end,
  }
end

function M.open_all()
  local items = M.all_tests()
  if #items == 0 then
    vim.notify("No @test-decorated tests found", vim.log.levels.INFO)
    return
  end

  open_test_picker(items, "All tests")
end

function M.open_unreviewed()
  local items = M.unreviewed_tests()
  if #items == 0 then
    vim.notify("All @test-decorated tests are reviewed", vim.log.levels.INFO)
    return
  end

  open_test_picker(items, "Unreviewed tests")
end

function M.summary()
  local tests = M.all_tests()
  local unreviewed = vim.tbl_filter(function(test)
    return not test.reviewed
  end, tests)

  vim.notify(string.format("Reviewed %d/%d @test-decorated tests", #tests - #unreviewed, #tests), vim.log.levels.INFO)
end

function M.reset_project()
  local answer = vim.fn.confirm("Clear all test review marks for this project?", "&Yes\n&No", 2)
  if answer ~= 1 then
    return
  end

  local state = load_state()
  project_state(state).reviewed = {}
  save_state(state)
  render_all_loaded_buffers()
  vim.notify("Cleared test review marks for project", vim.log.levels.INFO)
end

function M.state_path()
  return state_path()
end

function M.setup()
  local group = vim.api.nvim_create_augroup("TestReview", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    group = group,
    callback = function(args)
      render_buffer(args.buf, args.event == "BufWritePost")
    end,
  })

  local keymaps = require "config.keymaps"
  keymaps.set("n", "<leader>tr", M.toggle_current, { desc = "Toggle current test reviewed", group = "test-review" })
  keymaps.set("n", "<leader>tR", M.reset_project, { desc = "Reset reviewed tests in project", group = "test-review" })
  keymaps.set("n", "sta", M.open_all, { desc = "Search all tests", group = "test-review" })
  keymaps.set("n", "str", M.open_unreviewed, { desc = "Search unreviewed tests", group = "test-review" })
  keymaps.set("n", "]u", M.next_unreviewed, { desc = "Next unreviewed test", group = "test-review" })
  keymaps.set("n", "[u", M.prev_unreviewed, { desc = "Previous unreviewed test", group = "test-review" })
  keymaps.set("n", "]r", M.next_reviewed, { desc = "Next reviewed test", group = "test-review" })
  keymaps.set("n", "[r", M.prev_reviewed, { desc = "Previous reviewed test", group = "test-review" })
end

return M
