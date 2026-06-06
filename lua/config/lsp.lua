local M = {}

local servers_enabled = false

local function completion_capabilities()
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    return blink.get_lsp_capabilities()
  end
  return vim.lsp.protocol.make_client_capabilities()
end

local function client_supports_method(client, method, bufnr)
  if vim.fn.has "nvim-0.11" == 1 then
    return client:supports_method(method, bufnr)
  end
  return client.supports_method(method, { bufnr = bufnr })
end

local function on_lsp_attach(event)
  vim.keymap.set("n", "grn", vim.lsp.buf.rename, { buffer = event.buf, desc = "LSP: [R]e[n]ame" })
  vim.keymap.set(
    { "n", "x" },
    "gra",
    vim.lsp.buf.code_action,
    { buffer = event.buf, desc = "LSP: [G]oto Code [A]ction" }
  )
  vim.keymap.set("n", "grr", function()
    require("snacks").picker.lsp_references()
  end, { buffer = event.buf, desc = "LSP: [G]oto [R]eferences" })
  vim.keymap.set("n", "gri", function()
    require("snacks").picker.lsp_implementations()
  end, { buffer = event.buf, desc = "LSP: [G]oto [I]mplementation" })
  vim.keymap.set("n", "gd", function()
    require("snacks").picker.lsp_definitions()
  end, { buffer = event.buf, desc = "LSP: [G]oto [D]efinition" })
  vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { buffer = event.buf, desc = "LSP: [G]oto [D]eclaration" })
  vim.keymap.set("n", "grs", function()
    require("snacks").picker.lsp_symbols()
  end, { buffer = event.buf, desc = "LSP: Open Document Symbols" })
  vim.keymap.set("n", "grt", function()
    require("snacks").picker.lsp_type_definitions()
  end, { buffer = event.buf, desc = "LSP: [G]oto [T]ype Definition" })
  vim.keymap.set("n", "K", function()
    vim.lsp.buf.hover { border = "rounded" }
  end, { buffer = event.buf, desc = "LSP: Hover" })

  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
    local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.clear_references,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
      callback = function(event2)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
      end,
    })
  end

  if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
    vim.keymap.set("n", "<leader>th", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
    end, { buffer = event.buf, desc = "LSP: [T]oggle Inlay [H]ints" })
  end

  if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentSymbol, event.buf) then
    local ok, navic = pcall(require, "nvim-navic")
    if ok then
      navic.setup {}
      navic.attach(client, event.buf)
    end
  end
end

local function setup_diagnostics()
  vim.diagnostic.config {
    severity_sort = true,
    float = { border = "rounded", source = "if_many" },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "󰅚 ",
        [vim.diagnostic.severity.WARN] = "󰀪 ",
        [vim.diagnostic.severity.INFO] = "󰋽 ",
        [vim.diagnostic.severity.HINT] = "󰌶 ",
      },
    },
    virtual_text = {
      source = "if_many",
      spacing = 2,
      format = function(diagnostic)
        return diagnostic.message
      end,
    },
  }

  vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump { count = 1, float = true }
  end, { desc = "Jump to next diagnostic" })

  vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump { count = -1, float = true }
  end, { desc = "Jump to previous diagnostic" })

  vim.keymap.set("n", "]D", function()
    vim.diagnostic.jump { count = math.huge, wrap = false, float = true }
  end, { desc = "Jump to the last diagnostic in the current buffer" })

  vim.keymap.set("n", "[D", function()
    vim.diagnostic.jump { count = -math.huge, wrap = false, float = true }
  end, { desc = "Jump to the first diagnostic in the current buffer" })

  vim.keymap.set("n", "d;", vim.diagnostic.open_float)
end

local function server_supports_filetype(server, filetype)
  return vim.tbl_contains(server.filetypes or {}, filetype)
end

local function missing_server_commands(filetype)
  local missing = {}
  local servers = require("config.toolchain").lsp_servers()

  for server_name, server in pairs(servers) do
    if server_supports_filetype(server, filetype) then
      local command = server.cmd and server.cmd[1]
      if command == nil or vim.fn.executable(command) == 0 then
        missing[#missing + 1] = string.format("%s requires `%s`", server_name, command or "<missing cmd>")
      end
    end
  end

  return missing
end

local function require_lsp_commands_for_filetype(event)
  local filetype = vim.bo[event.buf].filetype
  if filetype == "" then
    return
  end

  local missing = missing_server_commands(filetype)
  if vim.tbl_isempty(missing) then
    return
  end

  error(
    string.format(
      "Missing LSP executable(s) for filetype `%s`: %s. Install them on PATH before opening this filetype.",
      filetype,
      table.concat(missing, ", ")
    ),
    0
  )
end

--- Configure and enable built-in Neovim LSP clients from config.toolchain.
function M.enable_servers()
  if servers_enabled then
    return
  end
  servers_enabled = true

  local capabilities = completion_capabilities()
  local servers = require("config.toolchain").lsp_servers()

  for server_name, server in pairs(servers) do
    server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
    vim.lsp.config(server_name, server)
    vim.lsp.enable(server_name)
  end
end

--- Install LSP keymaps, diagnostics, and deferred server startup without nvim-lspconfig.
function M.setup()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
    callback = on_lsp_attach,
  })

  setup_diagnostics()

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("local-lsp-command-check", { clear = true }),
    callback = require_lsp_commands_for_filetype,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    once = true,
    callback = M.enable_servers,
  })
end

return M
