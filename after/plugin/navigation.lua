-- harpoon
local harpoon_ok, mark = pcall(require, "harpoon.mark")
if harpoon_ok then
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

local todo_ok, todo = pcall(require, "todo-comments")
if todo_ok then
  todo.setup {}
  vim.keymap.set("n", "st", "<cmd>TodoTelescope<CR>")
  vim.keymap.set("n", "]t", todo.jump_next)
  vim.keymap.set("n", "[t", todo.jump_prev)
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

