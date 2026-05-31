local M = {}

local state_path = vim.fn.stdpath "state" .. "/usage-audit.json"
local namespace = vim.api.nvim_create_namespace "config.usage_audit"

local state = nil
local registered_keymaps = {}
local candidates_by_mode = {}
local buffers = {}
local last_key_at = 0
local setup_done = false
local current_cmdline = ""
local current_cmdtype = ""

local tracked_modes = {
  n = true,
  i = true,
  v = true,
  x = true,
  s = true,
  o = true,
  t = true,
}

local mode_aliases = {
  no = "n",
  nov = "n",
  noV = "n",
  ["no\22"] = "n",
  niI = "n",
  niR = "n",
  niV = "n",
  nt = "n",
  ntT = "n",
  ic = "i",
  ix = "i",
  R = "i",
  Rc = "i",
  Rv = "i",
  Rx = "i",
  c = "c",
  cv = "c",
  ce = "c",
  r = "n",
  rm = "n",
  ["r?"] = "n",
  v = "x",
  V = "x",
  ["\22"] = "x",
  Vs = "x",
  S = "s",
}

local function empty_state()
  return {
    version = 1,
    keys = {},
    commands = {},
  }
end

local function read_state()
  if state then
    return state
  end

  if vim.fn.filereadable(state_path) == 0 then
    state = empty_state()
    return state
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(state_path), "\n"))
  if not ok or type(decoded) ~= "table" then
    state = empty_state()
    return state
  end

  decoded.keys = decoded.keys or {}
  decoded.commands = decoded.commands or {}
  state = decoded
  return state
end

local function write_state()
  if not state then
    return
  end
  vim.fn.mkdir(vim.fn.fnamemodify(state_path, ":h"), "p")
  vim.fn.writefile({ vim.json.encode(state) }, state_path)
end

local function mode_key(mode)
  return mode_aliases[mode] or mode:sub(1, 1)
end

local function normalize_lhs(lhs)
  local ok, normalized = pcall(vim.api.nvim_replace_termcodes, lhs, true, true, true)
  return ok and normalized or lhs
end

local function key_id(mode, lhs)
  return mode .. " " .. lhs
end

local function command_id(command)
  return command:match "^%s*([^!%s]+)" or command
end

local function increment(bucket, id, metadata)
  local audit_state = read_state()
  audit_state[bucket][id] = audit_state[bucket][id] or vim.tbl_extend("force", { count = 0 }, metadata or {})
  local item = audit_state[bucket][id]
  item.count = (item.count or 0) + 1
  item.last_used = os.date "!%Y-%m-%dT%H:%M:%SZ"
  write_state()
end

local function rebuild_candidates()
  candidates_by_mode = {}
  for _, registration in ipairs(registered_keymaps) do
    for _, mode in ipairs(registration.mode) do
      mode = mode_key(mode)
      if tracked_modes[mode] and registration.track_on_key ~= false then
        local lhs = normalize_lhs(registration.lhs)
        candidates_by_mode[mode] = candidates_by_mode[mode] or {}
        table.insert(candidates_by_mode[mode], {
          lhs = lhs,
          display_lhs = registration.lhs,
          desc = registration.desc,
          group = registration.group,
        })
      end
    end
  end
end

local function registered_contains(mode, lhs)
  for _, registration in ipairs(registered_keymaps) do
    if registration.lhs == lhs then
      for _, registered_mode in ipairs(registration.mode) do
        if mode_key(registered_mode) == mode then
          return true
        end
      end
    end
  end
  return false
end

local function register_from_nvim_maps()
  for mode in pairs(tracked_modes) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      if not registered_contains(mode, map.lhs) then
        M.register_keymap(mode, map.lhs, { desc = map.desc, group = "external" })
      end
    end
  end
end

function M.register_keymap(mode, lhs, opts)
  opts = opts or {}
  local modes = type(mode) == "table" and vim.deepcopy(mode) or { mode }
  table.insert(registered_keymaps, {
    mode = modes,
    lhs = lhs,
    desc = opts.desc,
    group = opts.group,
    track_on_key = opts.track_on_key,
  })
  rebuild_candidates()
end

function M.record_key(mode, lhs, metadata)
  mode = mode_key(mode)
  increment("keys", key_id(mode, lhs), vim.tbl_extend("force", {
    mode = mode,
    lhs = lhs,
  }, metadata or {}))
end

function M.record_command(command)
  local id = command_id(command)
  if id == "" then
    return
  end
  increment("commands", id, { command = id })
end

local function on_key(char)
  local mode = mode_key(vim.api.nvim_get_mode().mode)
  if not tracked_modes[mode] then
    return
  end

  local now = vim.uv.now()
  if now - last_key_at > 1000 then
    buffers = {}
  end
  last_key_at = now

  buffers[mode] = (buffers[mode] or "") .. char
  local buffer = buffers[mode]
  local still_possible = false

  for _, candidate in ipairs(candidates_by_mode[mode] or {}) do
    if buffer == candidate.lhs then
      M.record_key(mode, candidate.display_lhs, {
        desc = candidate.desc,
        group = candidate.group,
      })
      buffers[mode] = ""
      return
    end

    if vim.startswith(candidate.lhs, buffer) then
      still_possible = true
    end
  end

  if not still_possible then
    buffers[mode] = char
    for _, candidate in ipairs(candidates_by_mode[mode] or {}) do
      if buffers[mode] == candidate.lhs then
        M.record_key(mode, candidate.display_lhs, {
          desc = candidate.desc,
          group = candidate.group,
        })
        buffers[mode] = ""
        return
      end
      if vim.startswith(candidate.lhs, buffers[mode]) then
        return
      end
    end
    buffers[mode] = ""
  end
end

local function usage_for_key(mode, lhs)
  local entry = read_state().keys[key_id(mode_key(mode), lhs)]
  return entry and entry.count or 0, entry and entry.last_used or nil
end

local function keymap_rows()
  register_from_nvim_maps()
  local rows = {}
  local seen = {}

  for _, registration in ipairs(registered_keymaps) do
    for _, mode in ipairs(registration.mode) do
      mode = mode_key(mode)
      local id = key_id(mode, registration.lhs)
      if not seen[id] then
        seen[id] = true
        local count, last_used = usage_for_key(mode, registration.lhs)
        table.insert(rows, {
          mode = mode,
          lhs = registration.lhs,
          desc = registration.desc or "",
          group = registration.group or "",
          count = count,
          last_used = last_used or "never",
        })
      end
    end
  end

  table.sort(rows, function(a, b)
    if a.count == b.count then
      return a.mode .. a.lhs < b.mode .. b.lhs
    end
    return a.count < b.count
  end)
  return rows
end

local function command_rows()
  local rows = {}
  local commands = vim.api.nvim_get_commands { builtin = false }
  for name in pairs(commands) do
    local entry = read_state().commands[name]
    table.insert(rows, {
      command = name,
      count = entry and entry.count or 0,
      last_used = entry and entry.last_used or "never",
    })
  end
  table.sort(rows, function(a, b)
    if a.count == b.count then
      return a.command < b.command
    end
    return a.count < b.count
  end)
  return rows
end

function M.report()
  local lines = {
    "# Usage audit",
    "",
    "State: " .. state_path,
    "",
    "## Keymaps, least-used first",
    "",
    "| Count | Last used | Mode | LHS | Group | Description |",
    "| ---: | --- | --- | --- | --- | --- |",
  }

  for _, row in ipairs(keymap_rows()) do
    table.insert(
      lines,
      string.format("| %d | %s | %s | `%s` | %s | %s |", row.count, row.last_used, row.mode, row.lhs, row.group, row.desc)
    )
  end

  vim.list_extend(lines, {
    "",
    "## User commands, least-used first",
    "",
    "| Count | Last used | Command |",
    "| ---: | --- | --- |",
  })

  for _, row in ipairs(command_rows()) do
    table.insert(lines, string.format("| %d | %s | `:%s` |", row.count, row.last_used, row.command))
  end

  vim.cmd.tabnew()
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_buf_set_name(buf, "usage-audit-report")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

function M.reset()
  state = empty_state()
  write_state()
  vim.notify("Usage audit state reset: " .. state_path)
end

function M.setup()
  if setup_done then
    return
  end
  setup_done = true
  read_state()

  vim.on_key(on_key, namespace)
  vim.defer_fn(register_from_nvim_maps, 1000)

  local group = vim.api.nvim_create_augroup("usage-audit", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "LazyLoad",
    callback = register_from_nvim_maps,
  })

  vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineChanged" }, {
    group = group,
    callback = function()
      current_cmdtype = vim.fn.getcmdtype()
      current_cmdline = vim.fn.getcmdline()
    end,
  })

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    callback = function()
      if current_cmdtype == ":" then
        M.record_command(current_cmdline)
      end
      current_cmdtype = ""
      current_cmdline = ""
    end,
  })

  vim.api.nvim_create_user_command("UsageAuditReport", M.report, { desc = "Open keymap and command usage audit" })
  vim.api.nvim_create_user_command("UsageAuditReset", M.reset, { desc = "Reset keymap and command usage audit data" })
end

return M
