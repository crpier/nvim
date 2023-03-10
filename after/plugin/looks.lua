vim.cmd.colorscheme "kanagawa"
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })

local navic = require "nvim-navic"
-- Lualine
require("lualine").setup {
  options = {
    icons_enabled = false,
    component_separators = "|",
    section_separators = "",
  },
  -- TODO If SSH_CLIENT show 'hostname'
  sections = {
    lualine_a = {},
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = {
      { navic.get_location, cond = navic.is_available },
    },
    lualine_x = {},
    -- TODO: put lsp clients here
    lualine_y = { "filetype" },
    lualine_z = { "location" },
  },
}
