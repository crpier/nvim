local M = {}

local severity = vim.diagnostic.severity

local function tool_cmd(command, ...)
  local cmd = { command }
  vim.list_extend(cmd, { ... })
  return cmd
end

local function set_python_path(command)
  local path = command.args
  local clients = vim.lsp.get_clients {
    bufnr = vim.api.nvim_get_current_buf(),
    name = "pyright",
  }

  for _, client in ipairs(clients) do
    client.config.settings = client.config.settings or {}
    client.config.settings.python =
      vim.tbl_deep_extend("force", client.config.settings.python or {}, { pythonPath = path })
    client:notify("workspace/didChangeConfiguration", { settings = nil })
  end
end

local function selected_python_lsp_name()
  if vim.fn.executable "ty" == 1 then
    return "ty"
  end
  return "pyright"
end

local function ts_root_dir(bufnr, on_dir)
  local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
  local deno_lock_root = vim.fs.root(bufnr, { "deno.lock" })
  local project_root =
    vim.fs.root(bufnr, { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock", ".git" })

  if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
    return
  end
  if deno_root and (not project_root or #deno_root >= #project_root) then
    return
  end

  on_dir(project_root or vim.fn.getcwd())
end

local python_root_markers = {
  "pyrightconfig.json",
  "ty.toml",
  "pyproject.toml",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  "Pipfile",
  ".git",
}

local python_lsp_servers = {
  pyright = {
    cmd = tool_cmd("pyright-langserver", "--stdio"),
    filetypes = { "python" },
    root_markers = python_root_markers,
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "openFilesOnly",
          useLibraryCodeForTypes = true,
        },
      },
    },
    on_attach = function(client, bufnr)
      vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightOrganizeImports", function()
        client.request("workspace/executeCommand", {
          command = "pyright.organizeimports",
          arguments = { vim.uri_from_bufnr(bufnr) },
        }, nil, bufnr)
      end, { desc = "Organize Imports" })

      vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightSetPythonPath", set_python_path, {
        desc = "Reconfigure pyright with the provided python path",
        nargs = 1,
        complete = "file",
      })
    end,
  },
  ty = {
    cmd = tool_cmd("ty", "server"),
    filetypes = { "python" },
    root_markers = python_root_markers,
  },
}

local lsp_servers = {
  lua_ls = {
    cmd = tool_cmd "lua-language-server",
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", ".git" },
    settings = {
      Lua = {
        codeLens = { enable = true },
        hint = { enable = true, semicolon = "Disable" },
      },
    },
  },
  ts_ls = {
    cmd = tool_cmd("typescript-language-server", "--stdio"),
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    root_dir = ts_root_dir,
    init_options = { hostInfo = "neovim" },
  },
  gopls = {
    cmd = tool_cmd "gopls",
    filetypes = { "go" },
    root_markers = { "go.work", "go.mod", ".git" },
  },
  rust_analyzer = {
    cmd = tool_cmd "rust-analyzer",
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
  },
  marksman = {
    cmd = tool_cmd("marksman", "server"),
    filetypes = { "markdown", "markdown.mdx" },
    root_markers = { ".marksman.toml", ".git" },
  },
  nil_ls = {
    cmd = tool_cmd "nil",
    filetypes = { "nix" },
    root_markers = { "flake.nix", ".git" },
  },
}

-- Spec-construction helpers. These describe how to invoke a tool (cwd discovery,
-- argument shapes) and so live with the tool records, not with the runners.

local function buffer_path(bufnr)
  return vim.api.nvim_buf_get_name(bufnr)
end

local function dirname(path)
  return vim.fn.fnamemodify(path, ":h")
end

local function nearest_file(start_dir, names)
  return vim.fs.root(start_dir, function(name)
    return vim.tbl_contains(names, name)
  end)
end

local function rust_edition(start_dir)
  local root = nearest_file(start_dir, { "Cargo.toml" })
  if root == nil then
    return "2021"
  end

  local cargo_toml = root .. "/Cargo.toml"
  if vim.fn.filereadable(cargo_toml) ~= 1 then
    return "2021"
  end

  for _, line in ipairs(vim.fn.readfile(cargo_toml)) do
    local edition = line:match '^%s*edition%s*=%s*"([^"]+)"'
    if edition ~= nil then
      return edition
    end
  end

  return "2021"
end

local function on_local()
  return require("config.utils").ON_LOCAL
end

local function has(command)
  return function()
    return vim.fn.executable(command) == 1
  end
end

-- Output parsers. Reading a tool's output is tool-specific knowledge, so it lives
-- on the linter record alongside how to invoke the tool.

local ruff_error_codes = { E902 = true, E999 = true, F821 = true }

local hadolint_severities = {
  error = severity.ERROR,
  warning = severity.WARN,
  info = severity.INFO,
  style = severity.HINT,
}

local function parse_luacheck(output)
  local diagnostics = {}
  local severities = { W = severity.WARN, E = severity.ERROR }

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

-- The registry. One complete record per external formatter/linter. The filetype
-- association lives on the record; `formatters_for`/`linters_for` derive the
-- by-filetype views and own the fixers-before-formatters ordering rule.
local tools = {
  -- Formatters
  {
    name = "stylua",
    kind = "format",
    phase = "format",
    cmd = "stylua",
    filetypes = { "lua" },
    args = function(bufnr)
      return { "--search-parent-directories", "--respect-ignores", "--stdin-filepath", buffer_path(bufnr), "-" }
    end,
    cwd = function(bufnr)
      return nearest_file(dirname(buffer_path(bufnr)), { ".stylua.toml", "stylua.toml" }) or dirname(buffer_path(bufnr))
    end,
    stdin = true,
  },
  {
    name = "ruff_fix",
    kind = "format",
    phase = "fix",
    cmd = "ruff",
    filetypes = { "python" },
    args = function(bufnr)
      return {
        "check",
        "--fix",
        "--unsafe-fixes",
        "--force-exclude",
        "--exit-zero",
        "--no-cache",
        "--stdin-filename",
        buffer_path(bufnr),
        "-",
      }
    end,
    cwd = function(bufnr)
      return nearest_file(dirname(buffer_path(bufnr)), { "pyproject.toml", "ruff.toml", ".ruff.toml" })
        or dirname(buffer_path(bufnr))
    end,
    stdin = true,
  },
  {
    name = "ruff_organize_imports",
    kind = "format",
    phase = "fix",
    cmd = "ruff",
    filetypes = { "python" },
    args = function(bufnr)
      return {
        "check",
        "--fix",
        "--force-exclude",
        "--select=I001",
        "--exit-zero",
        "--no-cache",
        "--stdin-filename",
        buffer_path(bufnr),
        "-",
      }
    end,
    cwd = function(bufnr)
      return nearest_file(dirname(buffer_path(bufnr)), { "pyproject.toml", "ruff.toml", ".ruff.toml" })
        or dirname(buffer_path(bufnr))
    end,
    stdin = true,
  },
  {
    name = "ruff_format",
    kind = "format",
    phase = "format",
    cmd = "ruff",
    filetypes = { "python" },
    args = function(bufnr)
      return { "format", "--force-exclude", "--stdin-filename", buffer_path(bufnr), "-" }
    end,
    cwd = function(bufnr)
      return nearest_file(dirname(buffer_path(bufnr)), { "pyproject.toml", "ruff.toml", ".ruff.toml" })
        or dirname(buffer_path(bufnr))
    end,
    stdin = true,
  },
  {
    name = "markdownlint",
    kind = "format",
    phase = "format",
    cmd = "markdownlint",
    filetypes = { "markdown" },
    args = { "--fix", "$FILENAME" },
    exit_codes = { 0, 1 },
    stdin = false,
  },
  {
    name = "prettierd",
    kind = "format",
    phase = "format",
    cmd = "prettierd",
    filetypes = { "javascript", "typescript", "typescriptreact" },
    args = function(bufnr)
      return { buffer_path(bufnr) }
    end,
    stdin = true,
  },
  {
    name = "rustfmt",
    kind = "format",
    phase = "format",
    cmd = "rustfmt",
    filetypes = { "rust" },
    args = function(bufnr)
      return { "--emit=stdout", "--edition=" .. rust_edition(dirname(buffer_path(bufnr))) }
    end,
    stdin = true,
  },
  {
    name = "gofmt",
    kind = "format",
    phase = "format",
    cmd = "gofmt",
    filetypes = { "go" },
    stdin = true,
  },

  -- Linters
  {
    name = "luacheck",
    kind = "lint",
    cmd = "luacheck",
    filetypes = { "lua" },
    args = { "--formatter", "plain", "--codes", "--ranges", "-" },
    stdin = true,
    output = "stdout",
    parse = parse_luacheck,
    enabled = on_local,
  },
  {
    name = "ruff",
    kind = "lint",
    cmd = "ruff",
    filetypes = { "python" },
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
    enabled = on_local,
  },
  {
    name = "hadolint",
    kind = "lint",
    cmd = "hadolint",
    filetypes = { "dockerfile" },
    args = { "-f", "json", "-" },
    stdin = true,
    output = "stdout",
    parse = parse_hadolint,
    enabled = has "hadolint",
  },
  {
    name = "jsonlint",
    kind = "lint",
    cmd = "jsonlint",
    filetypes = { "json" },
    args = { "--compact" },
    stdin = true,
    output = "stderr",
    parse = parse_jsonlint,
    enabled = has "jsonlint",
  },
}

local function is_enabled(tool)
  return tool.enabled == nil or tool.enabled()
end

local function applies_to(tool, filetype)
  return vim.tbl_contains(tool.filetypes, filetype)
end

function M.lsp_servers()
  local servers = vim.deepcopy(lsp_servers)
  local python_lsp_name = selected_python_lsp_name()
  local python_lsp = python_lsp_servers[python_lsp_name]

  servers[python_lsp_name] = vim.deepcopy(python_lsp)
  return servers
end

--- Formatter records for a filetype, fixers before formatters, in declaration order.
function M.formatters_for(filetype)
  local fixers, formatters = {}, {}
  for _, tool in ipairs(tools) do
    if tool.kind == "format" and applies_to(tool, filetype) and is_enabled(tool) then
      local bucket = tool.phase == "fix" and fixers or formatters
      bucket[#bucket + 1] = tool
    end
  end
  return vim.list_extend(fixers, formatters)
end

--- Enabled linter records for a filetype.
function M.linters_for(filetype)
  local matched = {}
  for _, tool in ipairs(tools) do
    if tool.kind == "lint" and applies_to(tool, filetype) and is_enabled(tool) then
      matched[#matched + 1] = tool
    end
  end
  return matched
end

--- All registered tool records, optionally filtered to one kind ("format"|"lint").
function M.tools(kind)
  local matched = {}
  for _, tool in ipairs(tools) do
    if kind == nil or tool.kind == kind then
      matched[#matched + 1] = tool
    end
  end
  return matched
end

return M
