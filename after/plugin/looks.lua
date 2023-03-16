vim.o.background = "dark"
vim.cmd.colorscheme "kanagawa"
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "LineNr", { bg = "none", fg = "#999999" })
vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none", fg = "#999999" })

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

require("bufferline").setup {}
