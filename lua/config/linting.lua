local M = {}

local namespaces = {}
local generations = {}
local warned_missing_linters = {}

local function namespace(name)
  namespaces[name] = namespaces[name] or vim.api.nvim_create_namespace("config.linting." .. name)
  return namespaces[name]
end

local function executable(command)
  return vim.fn.executable(command) == 1
end

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.WARN, { title = "linting" })
end

local function buffer_text(bufnr)
  return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n") .. "\n"
end

local function buffer_path(bufnr)
  return vim.api.nvim_buf_get_name(bufnr)
end

local function clear_linter(bufnr, name)
  vim.diagnostic.set(namespace(name), bufnr, {})
end

local function should_lint(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == "" and buffer_path(bufnr) ~= ""
end

local function run_linter(bufnr, linter)
  if not should_lint(bufnr) then
    return
  end

  local name = linter.name
  if not executable(linter.cmd) then
    clear_linter(bufnr, name)
    local filetype = vim.bo[bufnr].filetype
    local warning_key = table.concat({ filetype, name, linter.cmd }, ":")
    if not warned_missing_linters[warning_key] then
      warned_missing_linters[warning_key] = true
      notify(string.format("Missing linter executable for filetype `%s`: %s requires `%s`", filetype, name, linter.cmd))
    end
    return
  end

  generations[bufnr] = generations[bufnr] or {}
  generations[bufnr][name] = (generations[bufnr][name] or 0) + 1
  local generation = generations[bufnr][name]

  local args = type(linter.args) == "function" and linter.args(bufnr) or linter.args
  local command = vim.list_extend({ linter.cmd }, vim.deepcopy(args or {}))
  local stdin = linter.stdin and buffer_text(bufnr) or nil

  vim.system(command, { text = true, stdin = stdin }, function(result)
    vim.schedule(function()
      if not should_lint(bufnr) or generations[bufnr][name] ~= generation then
        return
      end

      local output = linter.output == "stderr" and result.stderr or result.stdout
      local diagnostics = linter.parse(output or "", bufnr)
      vim.diagnostic.set(namespace(name), bufnr, diagnostics)
    end)
  end)
end

--- Lint the current buffer with the configured external linter commands.
function M.try_lint(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not should_lint(bufnr) then
    return
  end

  local filetype = vim.bo[bufnr].filetype
  local configured = {}
  for _, linter in ipairs(require("config.toolchain").linters_for(filetype)) do
    configured[linter.name] = true
    run_linter(bufnr, linter)
  end

  for _, linter in ipairs(require("config.toolchain").tools "lint") do
    if not configured[linter.name] then
      clear_linter(bufnr, linter.name)
    end
  end
end

--- Set up linting autocommands that mirror the old nvim-lint triggers.
function M.setup()
  local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = lint_augroup,
    callback = function(event)
      M.try_lint(event.buf)
    end,
  })
end

return M
