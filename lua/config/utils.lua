local M = {}

--- False when running on a server via SSH
--- @type boolean
M.ON_LOCAL = os.getenv "SSH_CLIENT" == nil

--- Installs lazy.nvim if not installed
M.setup_lazy = function()
  local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
        { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
        { out, "WarningMsg" },
        { "\nPress any key to exit..." },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end
  vim.opt.rtp:prepend(lazypath)
end

--- Get lsp client for current buffer
--- @return string|nil
local function find_lsp_root()
  local ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
  local lsp_clients = vim.lsp.get_clients { bufnr = 0 }
  if next(lsp_clients) == nil then
    return nil
  end

  for _, client in pairs(lsp_clients) do
    ---@diagnostic disable-next-line: undefined-field
    local filetypes = client.config.filetypes

    if filetypes and vim.tbl_contains(filetypes, ft) then
      return client.config.root_dir, client.name
    end
  end

  return nil
end

--- Get the lowest parent dir that contains a .git dir
--- @return string|nil
local function find_project_root()
  local search_dir = vim.fn.expand("%:p:h", true)
  local markers = { ".git", "Makefile", "package.json", "pyproject.toml", ".svn" }
  while search_dir ~= "/" do
    for _, marker in ipairs(markers) do
      if
        vim.fn.isdirectory(search_dir .. "/" .. marker) == 1 or vim.fn.filereadable(search_dir .. "/" .. marker) == 1
      then
        return search_dir
      end
    end
    search_dir = vim.fn.fnamemodify(search_dir, ":h")
  end
  return nil
end

--- Find the root dir for the current buffer
--- @return string|nil
local function find_root()
  local lsp_root = find_lsp_root()
  if lsp_root ~= nil then
    return lsp_root
  end
  return find_project_root()
end

--- Helper variable to store the last root
--- This helps us avoid unnecessary cd calls
--- @type string|nil
M.root = nil

--- Autocmd to change the cwd to the root of the project
--- whenever we enter a buffer or attach to a new lsp client
--- @param verbose boolean Whether to print a message when changing the cwd. Defaults to true
M.enable_set_root_autocmd = function(verbose)
  if verbose == nil then
    verbose = true
  end
  vim.api.nvim_create_autocmd({ "BufEnter", "LspAttach" }, {
    callback = function()
      local root = find_root()
      if root ~= nil and root ~= M.root then
        vim.api.nvim_set_current_dir(root)
        M.root = root
        if verbose then
          print("Set cwd to " .. root)
        end
      end
    end,
  })
end

M.default_options = {
  --- @type boolean Whether to use avante (requires a api key)
  avante_enabled = false,
  --- @type boolean Whether to use supermaven
  --- supermaven bugs you to to login if you enable it.
  --- That's the main reason I made this table for local configs lol
  supermaven_enabled = false,
  treesitter_highlight_definitions = true,
  local_plugins = {},
}

--- read local config from ~/.config/local_configs/nvim.lua
--- if it exists, merge it with the default config
--- and return the result table
M.load_local_options = (function()
  local cached_options = nil
  return function()
    if cached_options then
      return cached_options
    end
    cached_options = M.default_options
    local local_configs = vim.fn.expand "~/.config/local_configs/nvim.lua"
    if vim.fn.filereadable(local_configs) == 1 then
      local local_config = dofile(local_configs)
      if local_config ~= nil then
        cached_options = vim.tbl_deep_extend("force", M.default_options, local_config)
      end
    end
    return cached_options
  end
end)()

return M
