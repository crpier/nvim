-- debugger
local ok_dap, dap = pcall(require, "dap")
local ok_dap_python, dap_python = pcall(require, "dap-python")
local ok_dap_ui, dap_ui = pcall(require, "dap-ui")
local ok_dap_repl_hl, dap_repl_hl = pcall(require, "dap-repl-highlights")
if ok_dap and ok_dap_ui and ok_dap_python and ok_dap_repl_hl then
  dap_python.setup "/usr/bin/python3"
  dap.configurations = { python = {} }
  table.insert(dap.configurations.python, {
    type = "python",
    request = "launch",
    name = "Launch current file with CWD as PYTHONPATH",
    program = "/home/crpier/.local/bin/pytest",
    args = { "/home/crpier/Projects/typetest/main.py" },
    env = { PYTHONPATH = "/home/crpier/Projects/typetest" },
    justMyCode = false,
  })

  dap_ui.setup()
  dap_repl_hl.setup()
  dap.listeners.after.event_initialized["dapui_config"] = function()
    ---@diagnostic disable-next-line: missing-parameter
    dap_ui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    ---@diagnostic disable-next-line: missing-parameter
    dap_ui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    ---@diagnostic disable-next-line: missing-parameter
    dap_ui.close()
  end

  vim.keymap.set("n", "<leader>dc", dap.continue)
  vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
  vim.keymap.set("n", "<leader>dl", dap.run_last)
  vim.keymap.set("n", "<F7>", dap.step_into)
  vim.keymap.set("n", "<F8>", dap.step_over)
  vim.keymap.set("n", "<F9>", dap.step_out)
  vim.keymap.set("n", "<leader>du", dap_ui.toggle)
  vim.keymap.set("n", "<leader>dx", dap.terminate)
  vim.keymap.set({ "n", "v" }, "<C-;>", dap_ui.eval)
  require("nvim-dap-virtual-text").setup {}
end
