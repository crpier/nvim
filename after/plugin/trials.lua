local ok, todo = pcall(require, "todo-comments")
if ok then
  -- TODO: lol
  todo.setup {}
  vim.keymap.set("n", "st", "<cmd>TodoTelescope<CR>")

  require("twilight").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }

  vim.keymap.set("n", "mr", "<cmd>CellularAutomaton make_it_rain<cr>")
  require("colorizer").setup()

  vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = "#61616a" })
  vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = "#9f9fe8" })

  require("indent_blankline").setup {
    indentLine_enabled = 1,
    filetype_exclude = {
      "help",
      "terminal",
      "alpha",
      "packer",
      "lspinfo",
      "TelescopePrompt",
      "TelescopeResults",
      "mason",
      "",
    },
    buftype_exclude = { "terminal" },
    show_trailing_blankline_indent = false,
    show_first_indent_level = false,
    show_current_context = true,
    show_current_context_start = false,
  }

  local ok_telekasten, telekasten = pcall(require, "telekasten")
  if ok_telekasten then
    local home = vim.fn.expand "~/Projects/daybook"

    telekasten.setup {
      home = home,
      template_new_note = home .. "/" .. "templates/new_note.md",
      template_new_daily = home .. "/" .. "templates/daily.md",
      -- show_tags_theme = "get_cursor",
    }

    vim.keymap.set("n", "<leader>z", telekasten.panel)
    vim.keymap.set("n", "<leader>zb", telekasten.show_backlinks)
    vim.keymap.set("n", "<leader>zd", telekasten.goto_today)
    vim.keymap.set("n", "<leader>zf", telekasten.find_notes)
    vim.keymap.set("n", "<leader>zn", telekasten.new_note)
    vim.keymap.set("n", "<leader>zs", telekasten.search_notes)
    vim.keymap.set("n", "<leader>zt", telekasten.show_tags)
    vim.keymap.set("n", "<leader>zy", telekasten.yank_notelink)
    vim.keymap.set("n", "<leader>zz", telekasten.follow_link)

    local telekasten_group = vim.api.nvim_create_augroup("telekasten", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "telekasten" },
      callback = function()
        vim.keymap.set("i", "[[", telekasten.insert_link, { buffer = true })
        vim.keymap.set("n", "<F2>", telekasten.rename_note, { buffer = true })
        vim.keymap.set("n", "gr", telekasten.find_friends)
      end,
      group = telekasten_group,
    })
  end
end

local ok_nvimtree, nvimtree = pcall(require, "nvim-tree")
if ok_nvimtree then
  nvimtree.setup {
    update_focused_file = {
      enable = true,
      update_root = true,
      ignore_list = {},
    },
  }
  vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>")
end

-- This module contains a number of default definitions
local rainbow_delimiters = require "rainbow-delimiters"

vim.g.rainbow_delimiters = {
  strategy = {
    [""] = rainbow_delimiters.strategy["global"],
    vim = rainbow_delimiters.strategy["local"],
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

local ok_flash, flash = pcall(require, "flash")
if ok_flash then
  flash.setup()
end

-- Copilot
vim.cmd [[
imap <silent><script><expr> <S-Tab> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true
]]
