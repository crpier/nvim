-- harpoon
local ok, mark = pcall(require, "harpoon.mark")
if ok then
  local ui = require "harpoon.ui"
  local term = require "harpoon.term"

  vim.keymap.set("n", "mm", mark.add_file)
  vim.keymap.set("n", "mq", ui.toggle_quick_menu)
  vim.keymap.set("n", "ma", function()
    ui.nav_file(1)
  end)
  vim.keymap.set("n", "ms", function()
    ui.nav_file(2)
  end)
  vim.keymap.set("n", "md", function()
    ui.nav_file(3)
  end)
  vim.keymap.set("n", "mf", function()
    ui.nav_file(4)
  end)
  vim.keymap.set("n", "mg", function()
    term.gotoTerminal(1)
  end)
end
