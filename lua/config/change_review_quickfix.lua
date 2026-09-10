local M = {}
local hunks = require "config.change_review_hunks"

local function reference(snapshot, unit)
  return { root = snapshot.root, snapshot = snapshot.id, unit = unit and unit.id }
end

local function preview_buffer(snapshot, unit)
  local buf = unit.preview_buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_create_buf(false, true)
    unit.preview_buf = buf
    vim.api.nvim_buf_set_name(buf, "change-review-hunk://" .. snapshot.id .. "/" .. unit.id)
    vim.bo[buf].filetype = "diff"
    vim.bo[buf].swapfile = false
    vim.b[buf].change_review_target = reference(snapshot, unit)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
  end
  local content = {
    hunks.label(unit) .. " · " .. unit.file.path,
    "Snapshot against " .. snapshot.head .. " (not live content)",
    "",
  }
  vim.list_extend(content, unit.preview)
  if not vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 0, -1, false), content) then
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false
  end
  return buf
end

local function items(snapshot)
  local result = {}
  for _, unit in ipairs(snapshot.units) do
    local first, last = hunks.range(unit)
    local item = {
      lnum = first,
      end_lnum = last,
      col = 1,
      text = hunks.label(unit),
      user_data = { review_unit = unit.id },
    }
    if unit.file.preview_only then
      item.bufnr, item.lnum, item.end_lnum = preview_buffer(snapshot, unit), 1, 1
      item.text = item.text .. " · " .. unit.file.path
    else
      item.filename = snapshot.root .. "/" .. unit.file.path
    end
    result[#result + 1] = item
  end
  return result
end

local function owned(snapshot)
  if not snapshot.qf_id then
    return nil
  end
  local info = vim.fn.getqflist { id = snapshot.qf_id, context = 0, idx = 0, nr = 0 }
  local ctx = type(info.context) == "table" and info.context.change_review
  if info.id == snapshot.qf_id and ctx and ctx.root == snapshot.root and ctx.snapshot == snapshot.id then
    return info
  end
end

-- Address our list by ID, never replace an unrelated current quickfix list.
function M.sync(snapshot)
  if not snapshot then
    return
  end
  for _, unit in ipairs(snapshot.units) do
    if unit.preview_buf and vim.api.nvim_buf_is_valid(unit.preview_buf) then
      preview_buffer(snapshot, unit)
    end
  end
  local info = owned(snapshot)
  if not info then
    return
  end
  local entries = items(snapshot)
  if vim.deep_equal(entries, snapshot.qf_items) then
    return
  end
  local current = vim.fn.getqflist { id = 0, winid = 0 }
  local win = current.id == snapshot.qf_id and current.winid or 0
  local cursor = win ~= 0 and vim.api.nvim_win_get_cursor(win) or nil
  vim.fn.setqflist({}, "r", {
    id = snapshot.qf_id,
    items = entries,
    idx = #entries > 0 and math.max(1, math.min(info.idx, #entries)) or 0,
  })
  snapshot.qf_items = entries
  if cursor and #entries > 0 then
    vim.api.nvim_win_set_cursor(win, { math.min(cursor[1], #entries), cursor[2] })
  end
end

function M.open(snapshot)
  local info = owned(snapshot)
  if not info then
    local entries = items(snapshot)
    vim.fn.setqflist({}, " ", {
      title = "Change review · " .. snapshot.root,
      context = { change_review = reference(snapshot) },
      items = entries,
    })
    snapshot.qf_id = vim.fn.getqflist({ id = 0 }).id
    snapshot.qf_items = entries
  else
    M.sync(snapshot)
    vim.cmd("silent " .. info.nr .. "chistory")
  end
  vim.cmd "botright copen"
end

function M.target()
  local buf = vim.api.nvim_get_current_buf()
  local preview = vim.b[buf].change_review_target
  if preview then
    return preview
  end
  if vim.bo[buf].buftype ~= "quickfix" then
    return nil
  end
  local win = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  if not win or win.loclist ~= 0 then
    return nil
  end
  local info = vim.fn.getqflist { context = 0, items = 0 }
  local ref = type(info.context) == "table" and info.context.change_review
  if not ref then
    return nil
  end
  local item = info.items[vim.api.nvim_win_get_cursor(0)[1]]
  ref.unit = item and type(item.user_data) == "table" and item.user_data.review_unit or nil
  return ref
end

function M.preview(snapshot, unit)
  vim.cmd("botright sbuffer " .. preview_buffer(snapshot, unit))
end

-- Retire old lists/previews without disturbing other lists or closing windows.
function M.retire(snapshot)
  if not snapshot then
    return
  end
  if owned(snapshot) then
    vim.fn.setqflist({}, "r", {
      id = snapshot.qf_id,
      items = {},
      title = "Change review · retired snapshot",
      context = {},
    })
  end
  for _, unit in ipairs(snapshot.units) do
    if unit.preview_buf and vim.api.nvim_buf_is_valid(unit.preview_buf) then
      vim.bo[unit.preview_buf].modifiable = true
      vim.api.nvim_buf_set_lines(unit.preview_buf, 0, 1, false, { "Retired review snapshot · " .. unit.file.path })
      vim.bo[unit.preview_buf].modifiable = false
      vim.bo[unit.preview_buf].modified = false
    end
  end
end

function M.replace(old, snapshot)
  local info = old and owned(old)
  M.retire(old)
  if info then
    snapshot.qf_id = info.id
    vim.fn.setqflist({}, "r", {
      id = info.id,
      context = { change_review = reference(snapshot) },
      title = "Change review · " .. snapshot.root,
    })
  end
end

return M
