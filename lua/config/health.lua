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
  filetypes = vim.deepcopy(filetypes)
  table.sort(filetypes)
  return table.concat(filetypes, ", ")
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

local function report_kind(title, kind, empty_message)
  vim.health.start(title)
  local tools = require("config.toolchain").tools(kind)
  local any_missing = false
  local reported = false

  for _, tool in ipairs(tools) do
    if tool.enabled == nil or tool.enabled() then
      reported = true
      any_missing = report_tool(tool.name, tool.cmd, tool.filetypes) == false or any_missing
    end
  end

  if not reported then
    vim.health.info(empty_message)
  elseif not any_missing then
    vim.health.ok(string.format("All configured %s executables are available", kind))
  end
end

--- Check configured LSP, formatter, and linter executables.
function M.check()
  report_lsp_servers()
  report_kind("Configured formatters", "format", "No formatters configured")
  report_kind("Configured linters", "lint", "No linters configured")
end

return M
