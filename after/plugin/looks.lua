local ok_gruvbox, gruvbox = pcall(require, "gruvbox")
if ok_gruvbox then
  gruvbox.setup {
    transparent_mode = true,
  }
  vim.cmd.colorscheme "gruvbox"
  vim.o.background = "dark"
end
-- set colorscheme
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#303030" })
    vim.api.nvim_set_hl(0, "TSDefinitionUsage", { bg = "#303030" })
  end,
})

local ok_navic, navic = pcall(require, "nvim-navic")
local ok_lualine, lualine = pcall(require, "lualine")
local navic_part = nil
if ok_navic then
  navic_part = {
    function()
      return navic.get_location()
    end,
    cond = navic.is_available,
  }
end
if ok_lualine then
  -- Lualine
  lualine.setup {
    options = {
      icons_enabled = false,
      component_separators = "|",
      section_separators = "",
    },
    sections = {
      lualine_a = {},
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = {
        navic_part,
      },
      lualine_x = { "" },
      lualine_y = { "filetype" },
      lualine_z = { "location" },
    },
  }
end

local ok_bufferline, bufferline = pcall(require, "bufferline")
if ok_bufferline then
  bufferline.setup {}
end

require("colorizer").setup()

require("ibl").setup {}

local ok_rbow_delim, rbow_delim = pcall(require, "rainbow-delimiters")
if ok_rbow_delim then
  vim.g.rbow_delim = {
    strategy = {
      [""] = rbow_delim.strategy["global"],
      vim = rbow_delim.strategy["local"],
    },
    query = {
      [""] = "rainbow-delimiters",
      lua = "rainbow-blocks",
    },
    highlight = {
      "RainbowDelimiterOrange",
      "RainbowDelimiterGreen",
      "RainbowDelimiterCyan",
      "RainbowDelimiterYellow",
      "RainbowDelimiterViolet",
      "RainbowDelimiterRed",
      "RainbowDelimiterBlue",
    },
  }
end
