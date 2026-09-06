-- Mode-aware cursor line number highlight.
-- Ported from mawkler/modicator.nvim (MIT): colors CursorLineNr's foreground
-- based on the current mode. No lualine integration; works with any theme by
-- re-deriving highlights on Colorscheme.

local M = {}

-- Exact mode strings first ("nt" = normal in terminal), then first char.
local mode_names = {
  n = "Normal",
  i = "Insert",
  v = "Visual",
  V = "Visual",
  ["\22"] = "Visual", -- ^V (visual block)
  s = "Select",
  S = "Select",
  ["\19"] = "Select", -- ^S (select block)
  R = "Replace",
  c = "Command",
  t = "Terminal",
  nt = "TerminalNormal",
}

-- Fallback highlight per mode when the user/theme hasn't set `<Mode>Mode`.
-- Normal/TerminalNormal are handled specially: linked to CursorLineNr via a
-- copy, since CursorLineNr mutates and a link would follow it.
local fallback_hls = {
  Normal = "CursorLineNr",
  Insert = "Question",
  Visual = "String",
  Select = "ErrorMsg",
  Replace = "WarningMsg",
  Command = "Identifier",
  Terminal = "Operator",
  TerminalNormal = "CursorLineNr",
}

local function mode_name(mode)
  return mode_names[mode] or mode_names[mode:sub(1, 1)] or "Normal"
end

local function get_hl(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
end

-- Define <Mode>Mode groups; link missing ones to their fallback.
local function set_mode_highlight_groups()
  for name, fallback in pairs(fallback_hls) do
    local hl_name = name .. "Mode"
    if vim.tbl_isempty(get_hl(hl_name)) then
      if fallback == "CursorLineNr" then
        -- Copy (not link) so the mode group doesn't chase CursorLineNr's
        -- own mutations.
        vim.api.nvim_set_hl(0, hl_name, get_hl("CursorLineNr"))
      else
        vim.api.nvim_set_hl(0, hl_name, { link = fallback })
      end
    end
  end
end

-- Re-color CursorLineNr's foreground for the current mode, keeping its other
-- attributes (bg, bold, ...) from the theme.
function M.update()
  local mode = mode_name(vim.api.nvim_get_mode().mode)
  local hl = vim.tbl_extend("force", get_hl("CursorLineNr"), get_hl(mode .. "Mode"))
  vim.api.nvim_set_hl(0, "CursorLineNr", hl)
end

local function refresh()
  set_mode_highlight_groups()
  M.update()
end

function M.setup()
  local group = vim.api.nvim_create_augroup("config-modicator", { clear = true })

  vim.api.nvim_create_autocmd("ModeChanged", {
    group = group,
    pattern = "*",
    callback = M.update,
  })

  -- Theme is loaded after config; also re-derive if the theme is switched
  -- live. ModeChanged won't fire for the initial Normal state, so refresh
  -- once on first UI enter too.
  vim.api.nvim_create_autocmd({ "Colorscheme", "UIEnter" }, {
    group = group,
    callback = function()
      vim.schedule(refresh)
    end,
  })

  refresh()
end

return M
