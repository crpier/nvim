local M = {}

local namespaces = {}
local generations = {}

local severity = vim.diagnostic.severity

local ruff_error_codes = {
  E902 = true,
  E999 = true,
  F821 = true,
}

local tflint_severities = {
  error = severity.ERROR,
  warning = severity.WARN,
  notice = severity.INFO,
}

local hadolint_severities = {
  error = severity.ERROR,
  warning = severity.WARN,
  info = severity.INFO,
  style = severity.HINT,
}

local function namespace(name)
  namespaces[name] = namespaces[name] or vim.api.nvim_create_namespace("config.linting." .. name)
  return namespaces[name]
end

local function executable(command)
  return vim.fn.executable(command) == 1
end

local function buffer_text(bufnr)
  return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n") .. "\n"
end

local function buffer_path(bufnr)
  return vim.api.nvim_buf_get_name(bufnr)
end

local function parse_luacheck(output)
  local diagnostics = {}
  local severities = {
    W = severity.WARN,
    E = severity.ERROR,
  }

  for line in output:gmatch "[^\n]+" do
    local lnum, col, end_col, diagnostic_severity, code, message =
      line:match "[^:]+:(%d+):(%d+)-(%d+): %((%a)(%d+)%) (.*)"
    if lnum ~= nil then
      table.insert(diagnostics, {
        lnum = tonumber(lnum) - 1,
        col = tonumber(col) - 1,
        end_lnum = tonumber(lnum) - 1,
        end_col = tonumber(end_col),
        severity = severities[diagnostic_severity] or severity.ERROR,
        source = "luacheck",
        code = code,
        message = message,
      })
    end
  end

  return diagnostics
end

local function ruff_severity(code, message)
  if ruff_error_codes[code] or message:find "^SyntaxError:" then
    return severity.ERROR
  end
  return severity.WARN
end

local function parse_ruff(output)
  local ok, results = pcall(vim.json.decode, output)
  if not ok or type(results) ~= "table" then
    return {}
  end

  local diagnostics = {}
  for _, result in ipairs(results) do
    table.insert(diagnostics, {
      lnum = result.location.row - 1,
      col = result.location.column - 1,
      end_lnum = result.end_location.row - 1,
      end_col = result.end_location.column - 1,
      severity = ruff_severity(result.code, result.message),
      source = "ruff",
      code = result.code,
      message = result.message,
    })
  end
  return diagnostics
end

local function parse_tflint(output, bufnr)
  local ok, decoded = pcall(vim.json.decode, output)
  if not ok or type(decoded) ~= "table" then
    return {}
  end

  local diagnostics = {}
  local buf_path = vim.fn.fnamemodify(buffer_path(bufnr), ":.")
  for _, issue in ipairs(decoded.issues or {}) do
    local range = issue.range or {}
    local rule = issue.rule or {}
    if range.filename == buf_path then
      table.insert(diagnostics, {
        lnum = tonumber(range.start.line) - 1,
        col = tonumber(range.start.column) - 1,
        end_lnum = tonumber(range["end"].line) - 1,
        end_col = tonumber(range["end"].column) - 1,
        severity = tflint_severities[rule.severity] or severity.WARN,
        source = "tflint",
        message = string.format("%s (%s)\nReference: %s", issue.message, rule.name, rule.link),
      })
    end
  end
  return diagnostics
end

local function parse_hadolint(output)
  local ok, findings = pcall(vim.json.decode, output)
  if not ok or type(findings) ~= "table" then
    return {}
  end

  local diagnostics = {}
  for _, finding in ipairs(findings) do
    table.insert(diagnostics, {
      lnum = finding.line - 1,
      col = finding.column - 1,
      end_lnum = finding.line - 1,
      end_col = finding.column - 1,
      severity = hadolint_severities[finding.level] or severity.WARN,
      source = "hadolint",
      code = finding.code,
      message = finding.message,
    })
  end
  return diagnostics
end

local function parse_jsonlint(output)
  local diagnostics = {}
  for line in output:gmatch "[^\n]+" do
    local lnum, col, message = line:match "line (%d+), col (%d+), (.*)"
    if lnum ~= nil then
      table.insert(diagnostics, {
        lnum = tonumber(lnum) - 1,
        col = tonumber(col) - 1,
        end_lnum = tonumber(lnum) - 1,
        end_col = tonumber(col) - 1,
        severity = severity.ERROR,
        source = "jsonlint",
        message = message,
      })
    end
  end
  return diagnostics
end

local linters = {
  luacheck = {
    cmd = "luacheck",
    args = { "--formatter", "plain", "--codes", "--ranges", "-" },
    stdin = true,
    output = "stdout",
    parse = parse_luacheck,
  },
  ruff = {
    cmd = "ruff",
    args = function(bufnr)
      return {
        "check",
        "--force-exclude",
        "--quiet",
        "--stdin-filename",
        buffer_path(bufnr),
        "--no-fix",
        "--output-format",
        "json",
        "-",
      }
    end,
    stdin = true,
    output = "stdout",
    parse = parse_ruff,
  },
  tflint = {
    cmd = "tflint",
    args = { "--format=json", "--recursive" },
    output = "stdout",
    parse = parse_tflint,
  },
  hadolint = {
    cmd = "hadolint",
    args = { "-f", "json", "-" },
    stdin = true,
    output = "stdout",
    parse = parse_hadolint,
  },
  jsonlint = {
    cmd = "jsonlint",
    args = { "--compact" },
    stdin = true,
    output = "stderr",
    parse = parse_jsonlint,
  },
}

local function clear_linter(bufnr, name)
  vim.diagnostic.set(namespace(name), bufnr, {})
end

local function should_lint(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == "" and buffer_path(bufnr) ~= ""
end

local function run_linter(bufnr, name)
  local linter = linters[name]
  if linter == nil or not should_lint(bufnr) then
    return
  end

  if not executable(linter.cmd) then
    clear_linter(bufnr, name)
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

--- Return linter executable names keyed by linter id.
function M.linter_commands()
  local commands = {}
  for name, linter in pairs(linters) do
    commands[name] = linter.cmd
  end
  return commands
end

--- Lint the current buffer with the configured external linter commands.
function M.try_lint(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not should_lint(bufnr) then
    return
  end

  local filetype = vim.bo[bufnr].filetype
  local configured_linters = require("config.toolchain").linters_by_ft()[filetype] or {}
  local configured = {}
  for _, name in ipairs(configured_linters) do
    configured[name] = true
    run_linter(bufnr, name)
  end

  for name in pairs(linters) do
    if not configured[name] then
      clear_linter(bufnr, name)
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
