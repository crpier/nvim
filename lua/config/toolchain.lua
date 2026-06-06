local M = {}

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
  pyright = {
    cmd = tool_cmd("pyright-langserver", "--stdio"),
    filetypes = { "python" },
    root_markers = {
      "pyrightconfig.json",
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      ".git",
    },
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
}

local formatters_by_ft = {
  lua = { "stylua" },
  python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
  markdown = { "markdownlint" },
  javascript = { "prettierd" },
  rust = { "rustfmt" },
  typescriptreact = { "prettierd" },
  typescript = { "prettierd" },
  go = { "gofmt" },
}

function M.lsp_servers()
  return vim.deepcopy(lsp_servers)
end

function M.formatters_by_ft()
  return vim.deepcopy(formatters_by_ft)
end

function M.linters_by_ft()
  local linters = {}

  if require("config.utils").ON_LOCAL then
    linters.lua = { "luacheck" }
    linters.python = { "ruff" }
  end

  if vim.fn.executable "hadolint" == 1 then
    linters.dockerfile = { "hadolint" }
  end

  if vim.fn.executable "jsonlint" == 1 then
    linters.json = { "jsonlint" }
  end

  return linters
end

return M
