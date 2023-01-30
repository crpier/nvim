require("nvim-surround").setup()
require("Comment").setup()

-- fast-jobs
local fast_jobs = require "fast-jobs"
vim.keymap.set("n", "yr<CR>", fast_jobs.create_window)
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

-- oscyank
-- TODO: only do this when on SSH_CLIENT
vim.keymap.set("v", "<leader>y", ":OSCYank<CR>")

require("autoclose").setup({})
