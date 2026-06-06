local M = {}

--- Load the vendored static colorscheme.
function M.setup()
  vim.cmd.colorscheme "catppuccin-macchiato"
end

return M
