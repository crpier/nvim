local M = {}

local state_path = vim.fn.stdpath "state" .. "/usage-audit.json"
local namespace = vim.api.nvim_create_namespace "config.usage_audit"
local state
local dirty = false
local flush_timer
local setup_done = false
local registrations = {}
local command_lines = {}
local command_level = 0
local typed_colon = false

local tracked_modes = { "n", "i", "x", "s", "o", "t" }

local function mode_key(mode)
  if mode:sub(1, 2) == "no" then
    return "o"
  end
  local first = mode:sub(1, 1)
  if first == "v" or first == "V" or first == "\22" then
    return "x"
  elseif first == "s" or first == "S" or first == "\19" then
    return "s"
  elseif first == "R" then
    return "i"
  end
  return first
end

local function normalize_lhs(lhs)
  lhs = lhs
    :gsub("<[Ll][Ee][Aa][Dd][Ee][Rr]>", function()
      return vim.g.mapleader or "\\"
    end)
    :gsub("<[Ll][Oo][Cc][Aa][Ll][Ll][Ee][Aa][Dd][Ee][Rr]>", function()
      return vim.g.maplocalleader or "\\"
    end)
  return vim.api.nvim_replace_termcodes(lhs, true, true, true)
end

local function key_id(mode, lhs, scope)
  return mode .. " " .. vim.fn.keytrans(normalize_lhs(lhs)) .. (scope == "buffer" and " [buffer]" or "")
end

local function empty_state()
  return { version = 2, keys = {}, commands = {} }
end

local function read_state()
  if state then
    return state
  end
  local ok, decoded = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(state_path), "\n"))
  end)
  if ok and type(decoded) == "table" and type(decoded.keys) == "table" and type(decoded.commands) == "table" then
    state = decoded
    -- Older records use a mix of <leader>, literal spaces and <Space>. Merge
    -- aliases without dropping their counts; old mode/origin errors cannot be repaired.
    if state.version ~= 2 then
      local keys = {}
      for _, entry in pairs(state.keys) do
        entry.lhs = vim.fn.keytrans(normalize_lhs(entry.lhs))
        local id = key_id(entry.mode, entry.lhs, entry.scope)
        if keys[id] then
          keys[id].count = keys[id].count + entry.count
          if (entry.last_used or "") > (keys[id].last_used or "") then
            keys[id].last_used = entry.last_used
          end
        else
          keys[id] = entry
        end
      end
      state.keys = keys
      state.version = 2
    end
  else
    state = empty_state()
  end
  return state
end

-- Batch writes outside input callbacks. Atomic replacement avoids a partial JSON
-- file if Neovim exits during a write. This is not a multi-process merge protocol.
function M.flush()
  if flush_timer then
    if not flush_timer:is_closing() then
      flush_timer:stop()
      flush_timer:close()
    end
    flush_timer = nil
  end
  if not dirty then
    return true
  end
  local temporary = state_path .. "." .. vim.fn.getpid() .. ".tmp"
  local ok, err = pcall(function()
    vim.fn.mkdir(vim.fn.fnamemodify(state_path, ":h"), "p")
    assert(vim.fn.writefile({ vim.json.encode(state) }, temporary) == 0, "write failed")
    assert(vim.uv.fs_rename(temporary, state_path))
  end)
  if ok then
    dirty = false
  else
    vim.fn.delete(temporary)
    vim.notify("Usage audit save failed: " .. tostring(err), vim.log.levels.WARN)
  end
  return ok
end

local function queue_flush()
  dirty = true
  if flush_timer then
    return
  end
  local timer
  timer = vim.defer_fn(function()
    if flush_timer == timer then
      flush_timer = nil
      M.flush()
    end
  end, 1000)
  flush_timer = timer
end

local function increment(bucket, id, metadata)
  local audit_state = read_state()
  local item = vim.tbl_extend("force", audit_state[bucket][id] or { count = 0 }, metadata or {})
  item.count = item.count + 1
  item.last_used = os.date "!%Y-%m-%dT%H:%M:%SZ"
  audit_state[bucket][id] = item
  queue_flush()
end

local function registration_id(mode, lhs, buffer)
  return tostring(buffer or 0) .. " " .. mode .. " " .. normalize_lhs(lhs)
end

function M.register_keymap(mode, lhs, opts)
  opts = opts or {}
  local buffer = opts.buffer
  if buffer == true or buffer == 0 then
    buffer = vim.api.nvim_get_current_buf()
  end
  for _, entry in ipairs(type(mode) == "table" and mode or { mode }) do
    -- vim.keymap.set("v", ...) applies to both Visual and Select mode.
    for _, actual in ipairs(entry == "v" and { "x", "s" } or { entry }) do
      local maps = buffer and vim.api.nvim_buf_get_keymap(buffer, actual) or vim.api.nvim_get_keymap(actual)
      for _, map in ipairs(maps) do
        if normalize_lhs(map.lhs) == normalize_lhs(lhs) then
          registrations[registration_id(actual, lhs, buffer)] = {
            desc = map.desc,
            group = opts.group,
            buffer = buffer,
            callback = map.callback,
            rhs = map.rhs,
          }
          break
        end
      end
    end
  end
end

local function map_metadata(mode, map)
  local registration = registrations[registration_id(mode, map.lhs, map.buffer ~= 0 and map.buffer or nil)]
  if
    registration
    and (registration.callback ~= map.callback or registration.rhs ~= map.rhs or registration.desc ~= map.desc)
  then
    registration = nil -- A plugin replaced a mapping registered through config.keymaps.
  end
  return {
    lhs = vim.fn.keytrans(normalize_lhs(map.lhs)),
    desc = map.desc or "",
    group = registration and registration.group or "external",
    scope = map.buffer ~= 0 and "buffer" or "global",
  }
end

function M.record_key(mode, lhs, metadata)
  mode = mode_key(mode)
  metadata = vim.tbl_extend("force", { mode = mode, lhs = lhs }, metadata or {})
  increment("keys", key_id(mode, lhs, metadata.scope), metadata)
end

function M.record_command(command)
  local ok, parsed = pcall(vim.api.nvim_parse_cmd, command, {})
  if ok and parsed.cmd ~= "" then
    increment("commands", parsed.cmd, { command = parsed.cmd })
  end
end

local function on_key(key, typed)
  local mode = mode_key(vim.api.nvim_get_mode().mode)
  typed_colon = key == ":" and typed == ":" and mode ~= "c"
  if mode == "c" then
    local line = command_lines[command_level]
    if line and typed ~= "" then
      line.interactive = true
    end
    return
  end
  if typed == "" or not vim.tbl_contains(tracked_modes, mode) then
    return
  end

  -- `typed` contains the resolved mapping's original LHS, not its RHS. Query
  -- live maps so late LSP/Gitsigns attachment, replacements and deletions work
  -- without wrapping plugin callbacks or relying on their event ordering.
  local maps = vim.api.nvim_buf_get_keymap(0, mode)
  vim.list_extend(maps, vim.api.nvim_get_keymap(mode))
  for _, map in ipairs(maps) do
    if normalize_lhs(map.lhs) == typed then
      local metadata = map_metadata(mode, map)
      M.record_key(mode, metadata.lhs, metadata)
      return -- Buffer-local maps shadow global maps with the same LHS.
    end
  end
end

local function keymap_rows()
  local rows = {}
  -- Keep historical mappings visible even when their buffer/plugin is gone.
  for id, entry in pairs(read_state().keys) do
    rows[id] = vim.tbl_extend("force", { scope = "legacy", desc = "", group = "" }, entry)
  end
  local function add(mode, map)
    local metadata = map_metadata(mode, map)
    local id = key_id(mode, metadata.lhs, metadata.scope)
    rows[id] = vim.tbl_extend("force", { count = 0, last_used = "never" }, rows[id] or {}, metadata, { mode = mode })
  end
  for _, mode in ipairs(tracked_modes) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      add(mode, map)
    end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) then
        for _, map in ipairs(vim.api.nvim_buf_get_keymap(buf, mode)) do
          add(mode, map)
        end
      end
    end
  end
  rows = vim.tbl_values(rows)
  table.sort(rows, function(a, b)
    if a.count == b.count then
      return key_id(a.mode, a.lhs, a.scope) < key_id(b.mode, b.lhs, b.scope)
    end
    return a.count < b.count
  end)
  return rows
end

local function command_rows()
  local rows = {}
  local commands = vim.api.nvim_get_commands { builtin = false }
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      commands = vim.tbl_extend("force", commands, vim.api.nvim_buf_get_commands(buf, {}))
    end
  end
  for name in pairs(read_state().commands) do
    commands[name] = commands[name] or {}
  end
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

local function cell(text)
  return tostring(text or ""):gsub("[\r\n]", " "):gsub("|", "&#124;"):gsub("`", "&#96;")
end

function M.report()
  local lines = {
    "# Usage audit",
    "",
    "State: " .. state_path,
    "",
    "Historical counts retain the old tracking behavior; zero counts are not proof of disuse.",
    "Buffer-local key counts aggregate across buffers. Unloaded buffers are not scanned for unused mappings.",
    "",
    "## Keymaps, least-used first",
    "",
    "| Count | Last used | Mode | LHS | Scope | Group | Description |",
    "| ---: | --- | --- | --- | --- | --- | --- |",
  }
  for _, row in ipairs(keymap_rows()) do
    table.insert(
      lines,
      string.format(
        "| %d | %s | %s | `%s` | %s | %s | %s |",
        row.count,
        cell(row.last_used),
        cell(row.mode),
        cell(row.lhs),
        cell(row.scope),
        cell(row.group),
        cell(row.desc)
      )
    )
  end
  vim.list_extend(lines, {
    "",
    "## Commands, least-used first",
    "",
    "Counts are interactive submissions, not successful executions. Only the first command in a pipeline is counted.",
    "Fully mapping-generated command lines, API calls and macro playback are excluded from new counts.",
    "",
    "| Count | Last used | Command |",
    "| ---: | --- | --- |",
  })
  for _, row in ipairs(command_rows()) do
    table.insert(lines, string.format("| %d | %s | `:%s` |", row.count, cell(row.last_used), cell(row.command)))
  end
  local buf = vim.fn.bufnr "usage-audit-report"
  if buf == -1 then
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "usage-audit-report")
  end
  vim.cmd.tabnew()
  vim.api.nvim_win_set_buf(0, buf)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

function M.reset()
  state = empty_state()
  dirty = true
  if M.flush() then
    vim.notify("Usage audit state reset: " .. state_path)
  end
end

function M.setup()
  if setup_done then
    return
  end
  setup_done = true
  read_state()
  vim.on_key(on_key, namespace)
  local group = vim.api.nvim_create_augroup("usage-audit", { clear = true })
  vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = group,
    callback = function()
      command_level = vim.v.event.cmdlevel
      command_lines[command_level] = { interactive = typed_colon }
      typed_colon = false
    end,
  })
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    callback = function()
      local level = vim.v.event.cmdlevel
      local line = command_lines[level]
      if line and line.interactive and vim.fn.getcmdtype() == ":" and not vim.v.event.abort then
        M.record_command(vim.fn.getcmdline())
      end
      command_lines[level] = nil
      command_level = level - 1
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    callback = function(event)
      for id, registration in pairs(registrations) do
        if registration.buffer == event.buf then
          registrations[id] = nil
        end
      end
    end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", { group = group, callback = M.flush })
  vim.api.nvim_create_user_command("UsageAuditReport", M.report, { desc = "Open keymap and command usage audit" })
  vim.api.nvim_create_user_command("UsageAuditReset", M.reset, { desc = "Reset keymap and command usage audit data" })
end

return M
