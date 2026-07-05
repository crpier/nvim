local M = {}

local active_chat = nil

local function joinpath(...)
  return vim.fs.joinpath(...)
end

local function pi_config_dir()
  return vim.env.PI_CODING_AGENT_DIR or joinpath(vim.fn.expand "~", ".pi", "agent")
end

local function bridge_dir()
  return vim.env.PI_BRIDGE_DIR or joinpath(pi_config_dir(), "agent-bridge")
end

local function bridge_cli()
  if vim.g.pi_bridge_cli ~= nil and vim.g.pi_bridge_cli ~= "" then
    return vim.g.pi_bridge_cli
  end

  local local_cli = joinpath(vim.fn.stdpath "config", "pi-bridge", "bin", "pi-bridge.js")
  if vim.fn.executable(local_cli) == 1 then
    return local_cli
  end

  return "pi-bridge"
end

local function read_json(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end

  local ok_decode, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok_decode then
    return nil
  end

  return decoded
end

local function socket_exists(agent)
  return type(agent.socketPath) == "string" and vim.uv.fs_stat(agent.socketPath) ~= nil
end

local function list_agents()
  local dir = joinpath(bridge_dir(), "agents")
  local entries = vim.fn.globpath(dir, "*.json", false, true)
  local agents = {}

  for _, path in ipairs(entries) do
    local agent = read_json(path)
    if type(agent) == "table" and socket_exists(agent) then
      table.insert(agents, agent)
    end
  end

  table.sort(agents, function(a, b)
    return tostring(a.startedAt) < tostring(b.startedAt)
  end)

  return agents
end

local function describe_agent(agent)
  local name = type(agent.sessionName) == "string" and (" name=" .. agent.sessionName) or ""
  local cwd = type(agent.cwd) == "string" and agent.cwd or "?"
  local pid = agent.pid ~= vim.NIL and agent.pid or "?"
  return string.format("pid=%s%s cwd=%s", pid, name, cwd)
end

local function choose_agent(callback)
  local agents = list_agents()

  if #agents == 0 then
    vim.notify("No running pi-bridge agents found. Start pi with --bridge or run /bridge start.", vim.log.levels.WARN)
    return
  end

  if #agents == 1 then
    callback(agents[1])
    return
  end

  vim.ui.select(agents, {
    prompt = "Select pi agent:",
    format_item = describe_agent,
  }, function(agent)
    if agent ~= nil then
      callback(agent)
    end
  end)
end

local function run_cli(args, callback)
  local cmd = { bridge_cli() }
  vim.list_extend(cmd, args)

  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local stderr = vim.trim(result.stderr or "")
        local stdout = vim.trim(result.stdout or "")
        vim.notify(stderr ~= "" and stderr or stdout, vim.log.levels.ERROR)
        return
      end

      if callback ~= nil then
        callback(result)
      end
    end)
  end)
end

local function range_text(opts)
  if opts.range == 0 then
    return nil
  end

  local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
  if #lines == 0 then
    return nil
  end

  return table.concat(lines, "\n")
end

local function prompt_for_message(initial, callback)
  if initial ~= nil and vim.trim(initial) ~= "" then
    callback(initial)
    return
  end

  vim.ui.input({ prompt = "Pi prompt: " }, function(input)
    if input ~= nil and vim.trim(input) ~= "" then
      callback(input)
    end
  end)
end

function M.send(message, opts)
  opts = opts or {}
  local deliver_flag = opts.follow_up and "--follow-up" or "--steer"

  prompt_for_message(message, function(final_message)
    choose_agent(function(agent)
      run_cli({ "send", "--agent", tostring(agent.pid), deliver_flag, final_message }, function(result)
        vim.notify(vim.trim(result.stdout or "Sent to pi."), vim.log.levels.INFO)
      end)
    end)
  end)
end

function M.status()
  choose_agent(function(agent)
    run_cli({ "status", "--agent", tostring(agent.pid) }, function(result)
      local output = vim.trim(result.stdout or "")
      if output == "" then
        output = describe_agent(agent)
      end
      vim.notify(output, vim.log.levels.INFO)
    end)
  end)
end

function M.list()
  local agents = list_agents()
  if #agents == 0 then
    vim.notify("No running pi-bridge agents found.", vim.log.levels.WARN)
    return
  end

  local lines = {}
  for index, agent in ipairs(agents) do
    table.insert(lines, string.format("%d) %s", index, describe_agent(agent)))
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

local function chat_insert_line(chat, line, index)
  if not vim.api.nvim_buf_is_valid(chat.buf) then
    return nil
  end

  local line_count = vim.api.nvim_buf_line_count(chat.buf)
  local insert_at = index or math.max(line_count - 1, 0)
  vim.api.nvim_buf_set_lines(chat.buf, insert_at, insert_at, false, { line })
  return insert_at
end

local function chat_set_line(chat, index, line)
  if not vim.api.nvim_buf_is_valid(chat.buf) then
    return
  end

  vim.api.nvim_buf_set_lines(chat.buf, index, index + 1, false, { line })
end

local function append_markdown_block(chat, heading, text)
  text = tostring(text or "")
  if text == "" then
    return
  end

  chat_insert_line(chat, "### " .. heading)
  chat_insert_line(chat, "")
  for _, line in ipairs(vim.split(text, "\n", { plain = true })) do
    chat_insert_line(chat, line)
  end
  chat_insert_line(chat, "")
end

local function append_assistant_delta(chat, delta)
  delta = tostring(delta or "")
  if delta == "" then
    return
  end

  if chat.assistant_line == nil then
    chat_insert_line(chat, "### Pi")
    chat_insert_line(chat, "")
    chat.assistant_line = chat_insert_line(chat, "")
  end

  local parts = vim.split(delta, "\n", { plain = true })
  for index, part in ipairs(parts) do
    if index == 1 then
      local current = vim.api.nvim_buf_get_lines(chat.buf, chat.assistant_line, chat.assistant_line + 1, false)[1] or ""
      chat_set_line(chat, chat.assistant_line, current .. part)
    else
      chat.assistant_line = chat_insert_line(chat, part, chat.assistant_line + 1)
    end
  end
end

local function chat_send(chat, payload)
  if chat.pipe == nil or chat.pipe:is_closing() then
    vim.notify("Pi bridge chat is disconnected", vim.log.levels.ERROR)
    return
  end

  chat.pipe:write(vim.json.encode(payload) .. "\n")
end

local function is_active_chat()
  return active_chat ~= nil and vim.api.nvim_buf_is_valid(active_chat.buf)
end

local function attachment_text(attachment)
  local fence = attachment.filetype ~= "" and attachment.filetype or "text"
  return table.concat({
    "Context from " .. attachment.source .. ":",
    "```" .. fence,
    attachment.text,
    "```",
  }, "\n")
end

local function render_attachment(chat, attachment)
  chat_insert_line(chat, "### Context: `" .. attachment.source .. "`")
  chat_insert_line(chat, "")
  chat_insert_line(chat, "```" .. (attachment.filetype ~= "" and attachment.filetype or "text"))
  for _, line in ipairs(vim.split(attachment.text, "\n", { plain = true })) do
    chat_insert_line(chat, line)
  end
  chat_insert_line(chat, "```")
  chat_insert_line(chat, "")
end

local function add_attachment(chat, attachment)
  table.insert(chat.contexts, attachment)
  render_attachment(chat, attachment)
end

local function compose_message(chat, message)
  if #chat.contexts == 0 then
    return message
  end

  local parts = {}
  for _, attachment in ipairs(chat.contexts) do
    table.insert(parts, attachment_text(attachment))
  end
  table.insert(parts, "User question:\n" .. message)

  return table.concat(parts, "\n\n")
end

local function handle_chat_event(chat, event)
  if event.type == "subscribed" then
    chat_insert_line(chat, "# Pi Bridge")
    chat_insert_line(chat, "")
    chat_insert_line(chat, "_Connected to " .. describe_agent(event.agent or {}) .. "_")
    chat_insert_line(chat, "")
    return
  end

  if event.type == "history" then
    for _, message in ipairs(event.messages or {}) do
      if message.role == "user" then
        append_markdown_block(chat, "You", message.text)
      elseif message.role == "assistant" then
        append_markdown_block(chat, "Pi", message.text)
      elseif message.role == "toolResult" and message.isError then
        append_markdown_block(chat, "Tool error", message.text)
      end
    end
    return
  end

  if event.type == "user" then
    if chat.last_sent ~= nil and vim.trim(event.text or "") == chat.last_sent then
      chat.last_sent = nil
      return
    end
    append_markdown_block(chat, "You", event.text)
    return
  end

  if event.type == "assistant_start" then
    chat_insert_line(chat, "### Pi")
    chat_insert_line(chat, "")
    chat.assistant_line = chat_insert_line(chat, "")
    return
  end

  if event.type == "assistant_delta" then
    append_assistant_delta(chat, event.delta)
    return
  end

  if event.type == "assistant_end" then
    chat.assistant_line = nil
    chat_insert_line(chat, "")
    return
  end

  if event.type == "tool_start" then
    local summary = event.summary and event.summary ~= "" and (" " .. event.summary) or ""
    chat_insert_line(chat, string.format("> ↳ tool `%s`%s", event.name or "unknown", summary))
    return
  end

  if event.type == "tool_end" then
    chat_insert_line(chat, string.format("> %s tool `%s`", event.ok and "✓" or "✗", event.name or "unknown"))
    return
  end

  if event.ok == false then
    chat_insert_line(chat, "> **Error:** " .. tostring(event.error or "unknown error"))
  end
end

local function connect_chat(chat, agent)
  local pipe = vim.uv.new_pipe(false)
  chat.pipe = pipe
  chat.buffer = ""

  pipe:connect(agent.socketPath, function(error)
    vim.schedule(function()
      if error then
        vim.notify("Failed to connect to pi bridge: " .. tostring(error), vim.log.levels.ERROR)
        return
      end

      chat_send(chat, { type = "subscribe", history = true })
    end)
  end)

  pipe:read_start(function(error, data)
    vim.schedule(function()
      if error then
        chat_insert_line(chat, "> **Error:** " .. tostring(error))
        return
      end

      if data == nil then
        chat_insert_line(chat, "# Disconnected")
        return
      end

      chat.buffer = chat.buffer .. data
      local newline = chat.buffer:find("\n", 1, true)
      while newline ~= nil do
        local line = chat.buffer:sub(1, newline - 1):gsub("\r$", "")
        chat.buffer = chat.buffer:sub(newline + 1)
        if vim.trim(line) ~= "" then
          local ok, event = pcall(vim.json.decode, line)
          if ok then
            handle_chat_event(chat, event)
          else
            chat_insert_line(chat, "> **Error:** invalid bridge event: " .. line)
          end
        end
        newline = chat.buffer:find("\n", 1, true)
      end
    end)
  end)
end

local function current_filetype(path)
  local matched = vim.filetype.match { filename = path }
  if matched ~= nil and matched ~= "" then
    return matched
  end

  return vim.bo.filetype or ""
end

local function selection_bounds(buf, opts)
  local start_line = opts.line1
  local end_line = opts.line2
  local start_col = 1
  local end_col = nil

  local visual_start = vim.fn.getpos "'<"
  local visual_end = vim.fn.getpos "'>"
  local start_buf = visual_start[1] == 0 and buf or visual_start[1]
  local end_buf = visual_end[1] == 0 and buf or visual_end[1]

  if opts.range > 0 and start_buf == buf and end_buf == buf and visual_start[2] > 0 and visual_end[2] > 0 then
    local visual_start_line = visual_start[2]
    local visual_end_line = visual_end[2]
    local range_start = math.min(visual_start_line, visual_end_line)
    local range_end = math.max(visual_start_line, visual_end_line)

    if opts.line1 == range_start and opts.line2 == range_end then
      start_line = visual_start[2]
      start_col = visual_start[3]
      end_line = visual_end[2]
      end_col = visual_end[3]

      if start_line > end_line or (start_line == end_line and start_col > end_col) then
        start_line, end_line = end_line, start_line
        start_col, end_col = end_col, start_col
      end

      if end_col >= vim.v.maxcol or start_col >= vim.v.maxcol then
        start_col = 1
        end_col = nil
      end
    end
  end

  return start_line, start_col, end_line, end_col
end

local function selected_text(buf, start_line, start_col, end_line, end_col)
  if end_col ~= nil then
    local ok, text = pcall(vim.api.nvim_buf_get_text, buf, start_line - 1, start_col - 1, end_line - 1, end_col, {})
    if ok and #text > 0 then
      return table.concat(text, "\n")
    end
  end

  return table.concat(vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false), "\n")
end

local function make_attachment(opts)
  if opts.range == 0 then
    vim.notify("Select code first, then run :PiBridgeAttachSelection", vim.log.levels.WARN)
    return nil
  end

  local buf = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(buf)
  local display_path = path ~= "" and vim.fn.fnamemodify(path, ":.") or "[No Name]"
  local start_line, start_col, end_line, end_col = selection_bounds(buf, opts)
  local text = selected_text(buf, start_line, start_col, end_line, end_col)

  if vim.trim(text) == "" then
    vim.notify("Selection is empty", vim.log.levels.WARN)
    return nil
  end

  local source
  if end_col ~= nil then
    source = string.format("%s:%d:%d-%d:%d", display_path, start_line, start_col, end_line, end_col)
  else
    source = string.format("%s:%d-%d", display_path, start_line, end_line)
  end

  return {
    source = source,
    text = text,
    filetype = current_filetype(path),
  }
end

local function open_chat(agent, opts)
  opts = opts or {}
  vim.cmd "botright 80vsplit"
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)

  vim.bo[buf].buftype = "prompt"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_buf_set_name(buf, "pi-bridge://" .. tostring(agent.pid or agent.socketPath))
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
  vim.fn.prompt_setprompt(buf, "You> ")

  local chat = {
    agent = agent,
    buf = buf,
    pipe = nil,
    buffer = "",
    assistant_line = nil,
    contexts = {},
    last_sent = nil,
  }
  active_chat = chat

  if opts.attachment ~= nil then
    add_attachment(chat, opts.attachment)
  end

  vim.fn.prompt_setcallback(buf, function(text)
    local message = vim.trim(text or "")
    if message == "" then
      return
    end

    local full_message = compose_message(chat, message)
    chat.contexts = {}
    chat.last_sent = full_message
    chat_send(chat, { type = "prompt", message = full_message, deliverAs = "steer" })
  end)

  vim.keymap.set("n", "q", function()
    if chat.pipe ~= nil and not chat.pipe:is_closing() then
      chat.pipe:close()
    end
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end, { buffer = buf, desc = "Close pi bridge chat" })

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      if active_chat == chat then
        active_chat = nil
      end
      if chat.pipe ~= nil and not chat.pipe:is_closing() then
        chat.pipe:close()
      end
    end,
  })

  connect_chat(chat, agent)
  vim.cmd.startinsert()
end

function M.chat()
  choose_agent(open_chat)
end

function M.attach_selection(opts)
  local attachment = make_attachment(opts)
  if attachment == nil then
    return
  end

  if is_active_chat() then
    add_attachment(active_chat, attachment)
    vim.notify("Attached context to Pi chat: " .. attachment.source, vim.log.levels.INFO)
    return
  end

  choose_agent(function(agent)
    open_chat(agent, { attachment = attachment })
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("PiBridgeSend", function(opts)
    M.send(opts.args ~= "" and opts.args or range_text(opts), { follow_up = false })
  end, {
    nargs = "*",
    range = true,
    desc = "Send a prompt to a running pi-bridge agent",
  })

  vim.api.nvim_create_user_command("PiBridgeFollowUp", function(opts)
    M.send(opts.args ~= "" and opts.args or range_text(opts), { follow_up = true })
  end, {
    nargs = "*",
    range = true,
    desc = "Queue a follow-up prompt for a running pi-bridge agent",
  })

  vim.api.nvim_create_user_command("PiBridgeStatus", M.status, {
    desc = "Show status for a running pi-bridge agent",
  })

  vim.api.nvim_create_user_command("PiBridgeList", M.list, {
    desc = "List running pi-bridge agents",
  })

  vim.api.nvim_create_user_command("PiBridgeChat", M.chat, {
    desc = "Open an interactive chat split for a running pi-bridge agent",
  })

  vim.api.nvim_create_user_command("PiBridgeAttachSelection", M.attach_selection, {
    range = true,
    desc = "Attach the selected code as context in the Pi chat split",
  })

  local keymaps = require "config.keymaps"
  keymaps.set("n", "<leader>pc", M.chat, { desc = "Open Pi bridge chat", group = "pi" })
  keymaps.set("v", "<leader>pa", ":<C-U>'<,'>PiBridgeAttachSelection<CR>", {
    desc = "Attach selection to Pi chat",
    group = "pi",
    silent = true,
  })
end

return M
