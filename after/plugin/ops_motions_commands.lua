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
-- TODO: only do this when on SSH_CLIENT, otherwise use unnamed register
vim.keymap.set("v", "<leader>y", ":OSCYankVisual<CR>")
