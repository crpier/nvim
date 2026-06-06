local M = {}

local function executable(command)
  return command ~= nil and vim.fn.executable(command) == 1
end

local function location(command)
  local path = command and vim.fn.exepath(command) or ""
  return path ~= "" and path or nil
end

local function format_filetypes(filetypes)
  if vim.tbl_isempty(filetypes) then
    return "no configured filetypes"
  end
  table.sort(filetypes)
  return table.concat(filetypes, ", ")
end

local function collect_by_tool(tools_by_ft)
  local by_tool = {}
  for filetype, tools in pairs(tools_by_ft) do
    for _, tool in ipairs(tools) do
      by_tool[tool] = by_tool[tool] or {}
      by_tool[tool][#by_tool[tool] + 1] = filetype
    end
  end
  return by_tool
end

local function report_tool(name, command, filetypes)
  local suffix = string.format(" (%s)", format_filetypes(filetypes))
  if command == nil then
    vim.health.error(string.format("%s has no known command%s", name, suffix))
    return false
  end

  local path = location(command)
  if executable(command) then
    vim.health.ok(string.format("%s: `%s` at %s%s", name, command, path, suffix))
    return true
  end

  vim.health.error(string.format("%s: missing `%s`%s", name, command, suffix))
  return false
end

local function report_lsp_servers()
  vim.health.start "Configured LSP servers"
  local any_missing = false
  local servers = require("config.toolchain").lsp_servers()

  for server_name, server in pairs(servers) do
    local command = server.cmd and server.cmd[1]
    local ok = report_tool(server_name, command, server.filetypes or {})
    any_missing = any_missing or not ok
  end

  if not any_missing then
    vim.health.ok "All configured LSP executables are available"
  end
end

local function report_formatters()
  vim.health.start "Configured formatters"
  local commands = require("config.formatting").formatter_commands()
  local by_formatter = collect_by_tool(require("config.toolchain").formatters_by_ft())
  local any_missing = false

  for formatter, filetypes in pairs(by_formatter) do
    local ok = report_tool(formatter, commands[formatter], filetypes)
    any_missing = any_missing or not ok
  end

  if vim.tbl_isempty(by_formatter) then
    vim.health.info "No formatters configured"
  elseif not any_missing then
    vim.health.ok "All configured formatter executables are available"
  end
end

local function report_linters()
  vim.health.start "Configured linters"
  local commands = require("config.linting").linter_commands()
  local by_linter = collect_by_tool(require("config.toolchain").linters_by_ft())
  local any_missing = false

  for linter, filetypes in pairs(by_linter) do
    local ok = report_tool(linter, commands[linter], filetypes)
    any_missing = any_missing or not ok
  end

  if vim.tbl_isempty(by_linter) then
    vim.health.info "No linters configured"
  elseif not any_missing then
    vim.health.ok "All configured linter executables are available"
  end
end

--- Check configured LSP, formatter, and linter executables.
function M.check()
  report_lsp_servers()
  report_formatters()
  report_linters()
end

return M
