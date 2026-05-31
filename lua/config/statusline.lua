local M = {}

local function branch()
  local head = vim.b.gitsigns_head
  if head and head ~= "" then
    return head
  end
  return ""
end

local function diff()
  local status = vim.b.gitsigns_status_dict
  if not status then
    return ""
  end

  local parts = {}
  if status.added and status.added > 0 then
    table.insert(parts, "+" .. status.added)
  end
  if status.changed and status.changed > 0 then
    table.insert(parts, "~" .. status.changed)
  end
  if status.removed and status.removed > 0 then
    table.insert(parts, "-" .. status.removed)
  end
  return table.concat(parts, " ")
end

local function diagnostics()
  local counts = vim.diagnostic.count(0)
  local severity = vim.diagnostic.severity
  local parts = {}

  if (counts[severity.ERROR] or 0) > 0 then
    table.insert(parts, "E" .. counts[severity.ERROR])
  end
  if (counts[severity.WARN] or 0) > 0 then
    table.insert(parts, "W" .. counts[severity.WARN])
  end
  if (counts[severity.INFO] or 0) > 0 then
    table.insert(parts, "I" .. counts[severity.INFO])
  end
  if (counts[severity.HINT] or 0) > 0 then
    table.insert(parts, "H" .. counts[severity.HINT])
  end

  return table.concat(parts, " ")
end

local function navic_location()
  local ok, navic = pcall(require, "nvim-navic")
  if not ok or not navic.is_available() then
    return ""
  end
  return navic.get_location()
end

function M.render()
  local left = vim.tbl_filter(function(item)
    return item ~= nil and item ~= ""
  end, { branch(), diff(), diagnostics() })

  local location = "%l:%c"
  local navic = navic_location()
  local left_text = table.concat(left, " | ")
  if navic ~= "" then
    left_text = left_text .. (left_text == "" and "" or "  ") .. navic
  end

  return table.concat({ " ", left_text, "%=", location, " " }, "")
end

function M.setup()
  _G.nvim_config_statusline = function()
    return require("config.statusline").render()
  end
  vim.o.statusline = "%!v:lua.nvim_config_statusline()"
end

return M
