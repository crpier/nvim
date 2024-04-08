local ok, surround = pcall(require, "nvim-surround")
if ok then
  surround.setup()
end
local ok, comment = pcall(require, "Comment")
if ok then
  comment.setup()
end

-- fast-jobs
local ok, fast_jobs = pcall(require, "fast-jobs")

if ok then
  vim.keymap.set("n", "yrq", fast_jobs.create_window)
  vim.keymap.set("n", "yr1", function()
    fast_jobs.run_cmd_async(1)
  end)
  vim.keymap.set("n", "yr2", function()
    fast_jobs.run_cmd_async(2)
  end)
  vim.keymap.set("n", "yr3", function()
    fast_jobs.run_cmd_async(3)
  end)
  vim.keymap.set("n", "yr4", function()
    fast_jobs.run_cmd_async(4)
  end)
  vim.keymap.set("n", "yr5", function()
    fast_jobs.run_cmd_async(5)
  end)
end


-- oscyank
vim.keymap.set("v", "<leader>y", ":OSCYankVisual<CR>")

-- cellular-automaton
vim.keymap.set("n", "mr", "<cmd>CellularAutomaton make_it_rain<cr>")

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

-- Copilot
-- use <S-Tab> to accept copilot suggestions
vim.cmd [[
imap <silent><script><expr> <S-Tab> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true
]]

local ok_mini = pcall(require, "mini.splitjoin")
if ok_mini then
  local _, bufremove = pcall(require, "mini.bufremove")
  vim.keymap.set("n", "<leader>bd", bufremove.delete)

  -- use gS to toggle split/join
  require("mini.splitjoin").setup()
end
