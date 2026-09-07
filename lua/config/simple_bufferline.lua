local M = {}
local tab_buffers = {}

-- Membership means "visited in this tab", not exclusive ownership of a buffer.
local function track_windows()
  local live_tabs = {}
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    live_tabs[tab] = true
    tab_buffers[tab] = tab_buffers[tab] or {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buflisted then
        tab_buffers[tab][buf] = true
      end
    end
  end
  for tab in pairs(tab_buffers) do
    if not live_tabs[tab] then
      tab_buffers[tab] = nil
    end
  end
end

local function listed_buffers(tab)
  local buffers = vim.tbl_filter(function(bufnr)
    return vim.bo[bufnr].buflisted and (not tab or (tab_buffers[tab] or {})[bufnr])
  end, vim.api.nvim_list_bufs())

  table.sort(buffers)
  return buffers
end

local function buffer_path(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return nil
  end
  return vim.fn.fnamemodify(name, ":~:.")
end

local function buffer_name(bufnr)
  local path = buffer_path(bufnr)
  if path == nil then
    return "[No Name]"
  end
  return vim.fn.fnamemodify(path, ":t")
end

local function path_parts(path)
  return vim.split(path, "/", { plain = true, trimempty = true })
end

local function path_suffix(parts, depth)
  local first = math.max(#parts - depth + 1, 1)
  return table.concat(vim.list_slice(parts, first), "/")
end

local function duplicate_name_groups(buffers)
  local groups = {}
  for _, bufnr in ipairs(buffers) do
    local name = buffer_name(bufnr)
    groups[name] = groups[name] or {}
    table.insert(groups[name], bufnr)
  end
  return groups
end

local function unique_duplicate_name(bufnr, group)
  local path = buffer_path(bufnr)
  if path == nil then
    return buffer_name(bufnr) .. " #" .. bufnr
  end

  local parts = path_parts(path)
  for depth = 2, #parts do
    local candidate = path_suffix(parts, depth)
    local unique = true
    for _, other in ipairs(group) do
      if other ~= bufnr and path_suffix(path_parts(buffer_path(other) or buffer_name(other)), depth) == candidate then
        unique = false
        break
      end
    end
    if unique then
      return candidate
    end
  end

  return path .. " #" .. bufnr
end

local function display_names(buffers)
  local names = {}
  for name, group in pairs(duplicate_name_groups(buffers)) do
    for _, bufnr in ipairs(group) do
      names[bufnr] = #group == 1 and name or unique_duplicate_name(bufnr, group)
    end
  end
  return names
end

local function escape_statusline(text)
  return text:gsub("%%", "%%%%")
end

local function label(bufnr, display_name)
  local name = display_name
  if vim.bo[bufnr].modified then
    name = name .. " +"
  end
  if vim.bo[bufnr].readonly or not vim.bo[bufnr].modifiable then
    name = name .. " -"
  end
  return escape_statusline(name)
end

--- Switch to a listed buffer clicked in the tabline.
---@param bufnr number
function M.select(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].buflisted then
    return
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  vim.api.nvim_set_current_buf(bufnr)
end

--- Render the tabline with duplicate basenames expanded to unique path suffixes.
---@return string
function M.render()
  local current = vim.api.nvim_get_current_buf()
  local parts = {}
  local tabs = vim.api.nvim_list_tabpages()
  local current_tab = vim.api.nvim_get_current_tabpage()
  local buffers = listed_buffers(#tabs > 1 and current_tab or nil)
  local names = display_names(buffers)

  for _, bufnr in ipairs(buffers) do
    local highlight = bufnr == current and "%#TabLineSel#" or "%#TabLine#"
    local click_target = "%" .. bufnr .. "@v:lua.nvim_config_bufferline_select@"
    table.insert(parts, highlight .. click_target .. " " .. label(bufnr, names[bufnr]) .. " %X")
  end

  table.insert(parts, "%#TabLineFill#%=%T")
  if #tabs > 1 then
    -- Native tab targets follow tab numbering, including after :tabmove.
    for index, tab in ipairs(tabs) do
      local buf = vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(tab))
      local modified = false
      for _, member in ipairs(listed_buffers(tab)) do
        modified = modified or vim.bo[member].modified
      end
      local name = buffer_name(buf) .. (modified and " +" or "")
      local highlight = tab == current_tab and "%#TabLineSel#" or "%#TabLine#"
      table.insert(parts, highlight .. "%" .. index .. "T " .. index .. ": " .. escape_statusline(name) .. " %T")
    end
  end
  return table.concat(parts, "")
end

--- Install the local bufferline as Neovim's tabline.
function M.setup()
  track_windows()
  local group = vim.api.nvim_create_augroup("SimpleBufferline", { clear = true })
  -- TabEnter fires before :tabnew replaces the inherited window's buffer.
  vim.api.nvim_create_autocmd("TabEnter", {
    group = group,
    callback = function()
      vim.schedule(function()
        track_windows()
        vim.cmd.redrawtabline()
      end)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufEnter", "TabClosed", "SessionLoadPost" }, {
    group = group,
    callback = function()
      track_windows()
      vim.cmd.redrawtabline()
    end,
  })
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = group,
    callback = function(event)
      for _, buffers in pairs(tab_buffers) do
        buffers[event.buf] = nil
      end
      vim.cmd.redrawtabline()
    end,
  })
  local function redraw()
    vim.cmd.redrawtabline()
  end
  vim.api.nvim_create_autocmd("BufFilePost", { group = group, callback = redraw })
  if vim.fn.exists "##BufModifiedSet" == 1 then
    vim.api.nvim_create_autocmd("BufModifiedSet", { group = group, callback = redraw })
  else
    vim.api.nvim_create_autocmd("OptionSet", { group = group, pattern = "modified", callback = redraw })
  end

  _G.nvim_config_bufferline = function()
    return require("config.simple_bufferline").render()
  end
  _G.nvim_config_bufferline_select = function(bufnr)
    require("config.simple_bufferline").select(bufnr)
  end

  vim.o.showtabline = 2
  vim.o.tabline = "%!v:lua.nvim_config_bufferline()"
end

return M
