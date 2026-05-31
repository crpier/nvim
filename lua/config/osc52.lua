local M = {}

function M.setup()
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

  require("config.keymaps").set("v", "<leader>y", '"+y', {
    desc = "Yank selection to clipboard/OSC52",
    group = "osc52",
  })
end

return M
