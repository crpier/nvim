local M = {}

local function setup_osc52()
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    local paste_plus = osc52.paste and osc52.paste "+" or function()
      return {}, "v"
    end
    local paste_star = osc52.paste and osc52.paste "*" or function()
      return {}, "v"
    end

    vim.g.clipboard = {
      name = "OSC 52",
      copy = {
        ["+"] = osc52.copy "+",
        ["*"] = osc52.copy "*",
      },
      paste = {
        ["+"] = paste_plus,
        ["*"] = paste_star,
      },
    }
  end

  vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank selection to clipboard/OSC52" })
end

local function setup_harpoon()
  local harpoon = require "config.simple_harpoon"
  vim.keymap.set("n", "mm", harpoon.add_file, { desc = "Mark file" })
  vim.keymap.set("n", "mq", harpoon.toggle_quick_menu, { desc = "Show marked files" })
  vim.keymap.set("n", "ma", function()
    harpoon.nav_file(1)
  end, { desc = "Go to mark 1" })
  vim.keymap.set("n", "ms", function()
    harpoon.nav_file(2)
  end, { desc = "Go to mark 2" })
  vim.keymap.set("n", "md", function()
    harpoon.nav_file(3)
  end, { desc = "Go to mark 3" })
  vim.keymap.set("n", "mf", function()
    harpoon.nav_file(4)
  end, { desc = "Go to mark 4" })
  vim.keymap.set("n", "mg", function()
    harpoon.goto_terminal(1)
  end, { desc = "Go to terminal 1" })
end

local function setup_todos()
  local todos = require "config.todos"
  vim.keymap.set("n", "sto", todos.open_picker, { desc = "Open TODOs in Snacks picker" })
  vim.keymap.set("n", "]t", todos.jump_next, { desc = "Next TODO" })
  vim.keymap.set("n", "[t", todos.jump_prev, { desc = "Previous TODO" })
end

local function setup_text_helpers()
  local text_helpers = require "config.text_helpers"
  vim.keymap.set("n", "dsi", text_helpers.delete_surrounding_indentation, { desc = "Delete surrounding indentation" })
  vim.keymap.set("n", ">p", function()
    text_helpers.indent_last_change ">"
  end, { desc = "Indent last change" })
  vim.keymap.set("n", "<p", function()
    text_helpers.indent_last_change "<"
  end, { desc = "Unindent last change" })
end

function M.setup()
  setup_osc52()
  setup_harpoon()
  setup_todos()
  setup_text_helpers()
  require("config.unimpaired").setup()
  require("config.statusline").setup()
end

return M
