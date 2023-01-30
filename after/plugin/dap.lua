-- debugger
-- TODO: find a way to add configs dynamically
require('dap-python').setup '/home/crpier/.cache/pypoetry/virtualenvs/mptreasury-totEAk67-py3.11/bin/python'
table.insert(require('dap').configurations.python, {
  type = 'python',
  request = 'launch',
  name = 'Launch current file with CWD as PYTHONPATH',
  program = '${file}',
  env = { PYTHONPATH = '/home/crpier/Projects/mptreasury' },
  justMyCode = false,
})

require('dapui').setup()
local dap, dapui = require 'dap', require 'dapui'
dap.listeners.after.event_initialized['dapui_config'] = function()
  ---@diagnostic disable-next-line: missing-parameter
  dapui.open()
end
dap.listeners.before.event_terminated['dapui_config'] = function()
  ---@diagnostic disable-next-line: missing-parameter
  dapui.close()
end
dap.listeners.before.event_exited['dapui_config'] = function()
  ---@diagnostic disable-next-line: missing-parameter
  dapui.close()
end

vim.keymap.set('n', '<leader>dc', require('dap').continue)
vim.keymap.set('n', '<leader>db', require('dap').toggle_breakpoint)
vim.keymap.set('n', '<leader>dl', require('dap').run_last)
vim.keymap.set('n', '<F7>', require('dap').step_into)
vim.keymap.set('n', '<F8>', require('dap').step_over)
vim.keymap.set('n', '<F9>', require('dap').step_out)
vim.keymap.set('n', '<leader>du', require('dapui').toggle)
vim.keymap.set('n', '<leader>dx', require('dap').terminate)
vim.keymap.set({ 'n', 'v' }, '<C-k>', require('dapui').eval)
