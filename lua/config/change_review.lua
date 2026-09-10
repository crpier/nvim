local M = {}

local ns = vim.api.nvim_create_namespace "change-review"
local sessions = {}
local store = require "config.change_review_store"
local hunks = require "config.change_review_hunks"
local quickfix = require "config.change_review_quickfix"

local function session_for(root)
  if not sessions[root] then
    local comments, token = store.load(root)
    local session = { root = root, comments = comments, files = {}, next_id = 1, store_token = token }
    for _, comment in ipairs(comments) do
      comment.root = root
      session.next_id = math.max(session.next_id, comment.id + 1)
    end
    sessions[root] = session
  end
  return sessions[root]
end
local rendering = false

local function schedule_render()
  if rendering then
    return
  end
  rendering = true
  vim.schedule(function()
    local ok, err = pcall(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and #vim.fn.win_findbuf(buf) > 0 then
          M.attach(buf)
        end
      end
      for _, session in pairs(sessions) do
        quickfix.sync(session.snapshot)
      end
      require("config.change_review_padding").refresh(ns)
    end)
    rendering = false
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end)
end

local function git(root, args)
  local cmd = { "git", "-C", root }
  vim.list_extend(cmd, args)
  local result = vim.system(cmd, { text = false }):wait(10000)
  if result.code ~= 0 then
    error(vim.trim(result.stderr or "Git command failed"), 0)
  end
  return result.stdout or ""
end

local function working_file(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype ~= "" or name == "" or name:match "^%w+://" then
    error("Review comments require a working-copy file, not a historical or scratch buffer", 0)
  end
  return vim.fs.normalize(name)
end

local function context()
  local target = quickfix.target()
  if target and sessions[target.root] then
    return sessions[target.root]
  end
  local buf = vim.api.nvim_get_current_buf()
  local ok, name = pcall(working_file, buf)
  local dir = ok and vim.fs.dirname(name) or vim.t.change_review_root or vim.fn.getcwd()
  local root = vim.trim(git(dir, { "rev-parse", "--show-toplevel" }))
  root = vim.fs.normalize(root)
  return session_for(root)
end

local function relative(session, path)
  local prefix = session.root .. "/"
  assert(path:sub(1, #prefix) == prefix, "File is outside the review repository")
  return path:sub(#prefix + 1)
end

-- Build once. Opening a picker or another viewer never resets review progress.
function M.refresh(session)
  session = session or context()
  assert(sessions[session.root] == session, "Review session was cleared")
  if not session.snapshot then
    session.snapshot = hunks.build(session.root)
    session.files = session.snapshot.files
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      hunks.attach(session.snapshot, buf)
    end
  end
  return session
end

-- Low-level rebuild; user-facing callers must obtain confirmation first.
function M.rebuild(session)
  session = session or context()
  assert(sessions[session.root] == session, "Review session was cleared")
  local snapshot = hunks.build(session.root)
  hunks.clear(session.snapshot)
  quickfix.replace(session.snapshot, snapshot)
  session.snapshot, session.files = snapshot, snapshot.files
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    hunks.attach(snapshot, buf)
  end
  quickfix.sync(snapshot)
  schedule_render()
  return session
end

local function changed(session)
  quickfix.sync(session.snapshot)
  vim.cmd "redrawstatus"
  schedule_render()
end

local function current_range(comment)
  if comment.buf and vim.api.nvim_buf_is_loaded(comment.buf) and comment.mark then
    local pos = vim.api.nvim_buf_get_extmark_by_id(comment.buf, ns, comment.mark, { details = true })
    if #pos > 0 then
      return pos[1] + 1, pos[3].end_row or pos[1] + 1
    end
  end
  return comment.first, comment.last
end

local function persist(session)
  local records = {}
  for _, comment in ipairs(session.comments) do
    -- Don't persist line movements caused only by unsaved source edits.
    if comment.buf and vim.api.nvim_buf_is_loaded(comment.buf) and not vim.bo[comment.buf].modified then
      local first, last = current_range(comment)
      comment.first = math.max(1, first)
      comment.last = math.max(comment.first, last)
    end
    records[#records + 1] = {
      id = comment.id,
      path = comment.path,
      text = comment.text,
      first = comment.first,
      last = comment.last,
      excerpt = comment.excerpt,
      file_level = comment.file_level,
      resolved = comment.resolved or false,
    }
  end
  session.store_token = store.save(session.root, records, session.store_token)
end

local function source_at(comment)
  local first, last = current_range(comment)
  if comment.buf and vim.api.nvim_buf_is_loaded(comment.buf) then
    return vim.api.nvim_buf_get_lines(comment.buf, first - 1, last, false)
  end
  local path = comment.root .. "/" .. comment.path
  if vim.fn.filereadable(path) == 0 then
    return nil
  end
  return vim.list_slice(vim.fn.readfile(path), first, last)
end

local function needs_check(comment)
  if comment.file_level then
    return false
  end
  return not vim.deep_equal(source_at(comment), comment.excerpt)
end

local function decorate(comment, buf)
  if comment.resolved or not vim.api.nvim_buf_is_loaded(buf) then
    return
  end
  local first, last = current_range(comment)
  if comment.buf and comment.mark and vim.api.nvim_buf_is_valid(comment.buf) then
    pcall(vim.api.nvim_buf_del_extmark, comment.buf, ns, comment.mark)
  end
  local count = vim.api.nvim_buf_line_count(buf)
  if comment.file_level then
    first, last = count, count
  else
    first = math.max(1, math.min(first, count))
    last = math.max(first, math.min(last, count))
  end
  comment.buf = buf
  local label = comment.file_level and "File review" or "Review"
  local lines = { { { "╭─ " .. label .. " #" .. comment.id, "DiagnosticInfo" } } }
  local width = 80
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    local info = vim.fn.getwininfo(win)[1]
    if info then
      width = math.min(width, math.max(1, info.width - info.textoff - 3))
    end
  end
  for _, line in ipairs(vim.split(comment.text, "\n", { plain = true })) do
    local chunk = ""
    for i = 0, vim.fn.strchars(line) - 1 do
      local char = vim.fn.strcharpart(line, i, 1)
      if chunk ~= "" and vim.fn.strdisplaywidth(chunk .. char) > width then
        lines[#lines + 1] = { { "│ " .. chunk, "DiagnosticInfo" } }
        chunk = ""
      end
      chunk = chunk .. char
    end
    lines[#lines + 1] = { { "│ " .. chunk, "DiagnosticInfo" } }
  end
  lines[#lines + 1] = { { "╰─", "DiagnosticInfo" } }
  comment.mark = vim.api.nvim_buf_set_extmark(buf, ns, first - 1, 0, {
    end_row = last,
    right_gravity = false,
    end_right_gravity = true,
    sign_text = "RC",
    sign_hl_group = "DiagnosticInfo",
    virt_lines = lines,
    virt_lines_above = false,
  })
  schedule_render()
end

function M.attach(buf)
  local ok, path = pcall(working_file, buf)
  if not ok then
    return
  end
  local root = vim.fs.root(path, ".git")
  if root then
    local loaded, err = pcall(session_for, vim.fs.normalize(root))
    if not loaded then
      vim.notify("Cannot restore review comments: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
  end
  for _, session in pairs(sessions) do
    hunks.attach(session.snapshot, buf)
    for _, comment in ipairs(session.comments) do
      if path == comment.root .. "/" .. comment.path then
        decorate(comment, buf)
      end
    end
  end
end

function M.add_comment(text, first, last, file_level)
  assert(vim.trim(text) ~= "", "Comment cannot be empty")
  local buf = vim.api.nvim_get_current_buf()
  local path = working_file(buf)
  local session = context()
  local count = vim.api.nvim_buf_line_count(buf)
  assert(first >= 1 and last >= first and last <= count, "Invalid comment range")
  local comment = {
    id = session.next_id,
    root = session.root,
    path = relative(session, path),
    first = first,
    last = last,
    file_level = file_level or false,
    excerpt = file_level and {} or vim.api.nvim_buf_get_lines(buf, first - 1, last, false),
    text = text,
    buf = buf,
  }
  session.next_id = session.next_id + 1
  session.comments[#session.comments + 1] = comment
  decorate(comment, buf)
  persist(session)
  return comment
end

local function save_comment(comment, text)
  local session = sessions[comment.root]
  assert(session, "Review session was cleared")
  if text == "" then
    comment.first, comment.last = current_range(comment)
    for i, item in ipairs(session.comments) do
      if item == comment then
        table.remove(session.comments, i)
        break
      end
    end
    if comment.buf and comment.mark and vim.api.nvim_buf_is_valid(comment.buf) then
      pcall(vim.api.nvim_buf_del_extmark, comment.buf, ns, comment.mark)
    end
    comment.mark = nil
  else
    -- A subsequent save after undoing a deletion restores this same comment.
    if not vim.tbl_contains(session.comments, comment) then
      session.comments[#session.comments + 1] = comment
    end
    comment.text = text
    if comment.buf and vim.api.nvim_buf_is_valid(comment.buf) then
      decorate(comment, comment.buf)
    end
  end
  schedule_render()
  persist(session)
end

local function comment_title(path, first, last, file_level)
  if file_level then
    return " File review · " .. path .. " "
  elseif first == last then
    return " Line review · " .. path .. ":" .. first .. " "
  end
  return " Hunk/range review · " .. path .. ":" .. first .. "-" .. last .. " "
end

local function editor(text, title, save)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf, "change-review-comment://" .. buf)
  vim.bo[buf].buftype = "acwrite"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n", { plain = true }))
  vim.bo[buf].modified = false
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      local value = vim.trim(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"))
      save(value)
      vim.bo[buf].modified = false
    end,
  })
  local width = math.max(1, math.min(90, vim.o.columns - 4))
  local height = math.max(1, math.min(12, vim.o.lines - 6))
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    style = "minimal",
    border = "rounded",
    title = title,
  })
end

local function compose(first, last, file_level)
  working_file(vim.api.nvim_get_current_buf())
  local origin = vim.api.nvim_get_current_buf()
  -- Editing an existing range should not create another comment on top of it.
  local session = context()
  local path = relative(session, working_file(origin))
  for _, comment in ipairs(session.comments) do
    local start_line, end_line = current_range(comment)
    if
      not comment.resolved
      and comment.path == path
      and comment.file_level == file_level
      and (file_level or (start_line == first and end_line == last))
    then
      editor(comment.text, comment_title(path, start_line, end_line, file_level), function(text)
        save_comment(comment, text)
      end)
      return
    end
  end
  -- Capture the range before opening a scratch buffer.
  local created
  editor("", comment_title(path, first, last, file_level), function(text)
    if created then
      save_comment(created, text)
    elseif text ~= "" then
      assert(vim.api.nvim_buf_is_valid(origin), "Source buffer no longer exists")
      vim.api.nvim_buf_call(origin, function()
        created = M.add_comment(text, first, last, file_level)
      end)
    end
  end)
end

-- Read cached review state only: statusline redraws must not scan Git or
-- invalidate approval while the user edits.
function M.status(buf)
  local ok, path = pcall(working_file, buf or vim.api.nvim_get_current_buf())
  if not ok then
    return ""
  end
  for _, session in pairs(sessions) do
    for _, file in ipairs(session.files) do
      if file.whole and path == session.root .. "/" .. file.path then
        return file.reviewed and "[x] Reviewed" or "[ ] Pending review"
      end
    end
  end
  return ""
end

function M.toggle_file(session, file)
  M.refresh(session)
  hunks.toggle_file(session.snapshot, file)
  changed(session)
end

local function with_unit(callback)
  local target = quickfix.target()
  if target then
    local session = sessions[target.root]
    local snapshot = session and session.snapshot
    if snapshot and snapshot.id == target.snapshot and snapshot.units[target.unit] then
      callback(session, snapshot.units[target.unit])
    end
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  if not pcall(working_file, buf) then
    return
  end
  local session = M.refresh()
  local snapshot = session.snapshot
  local matches = hunks.at(snapshot, buf, vim.api.nvim_win_get_cursor(0)[1])
  if #matches == 1 then
    callback(session, matches[1])
  elseif #matches > 1 then
    vim.ui.select(matches, { prompt = "Overlapping snapshot hunks", format_item = hunks.label }, function(unit)
      if unit and sessions[session.root] == session and session.snapshot == snapshot then
        callback(session, unit)
      end
    end)
  end
end

function M.toggle()
  with_unit(function(session, unit)
    hunks.toggle(session.snapshot, unit)
    changed(session)
  end)
end

function M.quickfix()
  quickfix.open(M.refresh().snapshot)
end

function M.preview_hunk()
  with_unit(function(session, unit)
    quickfix.preview(session.snapshot, unit)
  end)
end

local function open_diff(session, path)
  -- The main review entry point uses Diffview's defaults without overrides.
  -- Only a file chosen from the checklist gets an explicit root and path filter.
  if path then
    vim.cmd("DiffviewOpen -C=" .. vim.fn.fnameescape(session.root) .. " -- " .. vim.fn.fnameescape(path))
  else
    vim.cmd "DiffviewOpen"
  end
  vim.t.change_review_root = session.root
end

local function files(pending_only)
  local session = M.refresh()
  local entries = pending_only and vim.tbl_filter(function(file)
    return not file.reviewed
  end, session.files) or session.files
  vim.ui.select(entries, {
    prompt = "Review files against HEAD",
    format_item = function(file)
      return (file.reviewed and "[x] " or "[ ] ") .. file.path .. (file.deleted and " (deleted)" or "")
    end,
  }, function(file)
    if not file then
      return
    end
    vim.ui.select({ "Open diff", "Edit file", "Toggle reviewed" }, { prompt = file.path }, function(action)
      if action == "Open diff" then
        open_diff(session, file.path)
      elseif action == "Edit file" then
        if file.deleted then
          vim.notify("Deleted file: use Open diff", vim.log.levels.WARN)
        else
          vim.cmd.edit(vim.fn.fnameescape(session.root .. "/" .. file.path))
        end
      elseif action == "Toggle reviewed" then
        local ok, err = pcall(M.toggle_file, session, file)
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end
    end)
  end)
end

function M.jump_comment(direction)
  local buf = vim.api.nvim_get_current_buf()
  local path = working_file(buf)
  local session = context()
  local locations, seen = {}, {}
  for _, comment in ipairs(session.comments) do
    if not comment.resolved and comment.root .. "/" .. comment.path == path then
      local line = comment.file_level and vim.api.nvim_buf_line_count(buf) or current_range(comment)
      line = math.max(1, math.min(line, vim.api.nvim_buf_line_count(buf)))
      if not seen[line] then
        seen[line] = true
        locations[#locations + 1] = line
      end
    end
  end
  if #locations == 0 then
    vim.notify "No outstanding comments in this file"
    return
  end
  table.sort(locations, function(a, b)
    return direction > 0 and a < b or direction < 0 and a > b
  end)
  local cursor = vim.api.nvim_win_get_cursor(0)[1]
  local index = 1
  for i, line in ipairs(locations) do
    if (line - cursor) * direction > 0 then
      index = i
      break
    end
  end
  index = (index + vim.v.count1 - 2) % #locations + 1
  vim.api.nvim_win_set_cursor(0, { locations[index], 0 })
  vim.cmd "normal! zvzz"
end

local function comments()
  local session = context()
  local pending = vim.tbl_filter(function(c)
    return not c.resolved
  end, session.comments)
  vim.ui.select(pending, {
    prompt = "Outstanding review comments",
    format_item = function(c)
      return (needs_check(c) and "[check location] " or "")
        .. c.path
        .. ":"
        .. current_range(c)
        .. " "
        .. c.text:gsub("\n", " ")
    end,
  }, function(c)
    if not c then
      return
    end
    vim.ui.select({ "Jump", "Edit comment", "Resolve" }, { prompt = c.path }, function(action)
      if action == "Jump" then
        if vim.fn.filereadable(c.root .. "/" .. c.path) == 0 then
          vim.notify("File missing; original excerpt remains in export", vim.log.levels.WARN)
          return
        end
        vim.cmd.edit(vim.fn.fnameescape(c.root .. "/" .. c.path))
        vim.api.nvim_win_set_cursor(0, { math.min(current_range(c), vim.api.nvim_buf_line_count(0)), 0 })
      elseif action == "Edit comment" then
        local first, last = current_range(c)
        editor(c.text, comment_title(c.path, first, last, c.file_level), function(text)
          save_comment(c, text)
        end)
      elseif action == "Resolve" then
        c.resolved = true
        persist(session)
        schedule_render()
        if c.buf and c.mark and vim.api.nvim_buf_is_valid(c.buf) then
          pcall(vim.api.nvim_buf_del_extmark, c.buf, ns, c.mark)
        end
      end
    end)
  end)
end

function M.export(session)
  session = session or context()
  local out = {
    "# Code review",
    "",
    "Address these comments within the current work part. Don't commit or expand scope.",
    "",
    "Working-copy feedback for " .. session.root .. ".",
    "",
  }
  for _, c in ipairs(session.comments) do
    if not c.resolved then
      local first, last = current_range(c)
      local location = c.file_level and "file" or (first .. "-" .. last)
      vim.list_extend(out, { "## " .. c.path .. " · " .. location, "", c.text, "" })
      if needs_check(c) then
        vim.list_extend(
          out,
          { "Location needs checking: source changed or disappeared. Original excerpt follows.", "" }
        )
      end
      if #c.excerpt > 0 then
        -- Indented code blocks cannot be closed by backticks in source text.
        for _, line in ipairs(c.excerpt) do
          out[#out + 1] = "    " .. line
        end
        out[#out + 1] = ""
      end
    end
  end
  return table.concat(out, "\n")
end

local function copy_text(text)
  vim.fn.setreg("+", text)
  vim.notify "Review copied to +; comments retained"
end

function M.copy(session)
  copy_text(M.export(session))
end

local function preview()
  local session = context()
  local text = M.export(session)
  vim.cmd "botright new"
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n", { plain = true }))
  vim.bo[buf].modifiable = false
  vim.keymap.set("n", "y", function()
    copy_text(text)
  end, { buffer = buf, desc = "Copy whole review" })
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
  vim.notify "Review export: y copies everything, q closes"
end

function M.clear(session)
  session = session or context()
  for _, c in ipairs(session.comments) do
    if c.buf and c.mark and vim.api.nvim_buf_is_valid(c.buf) then
      pcall(vim.api.nvim_buf_del_extmark, c.buf, ns, c.mark)
    end
  end
  local previous_comments = session.comments
  session.comments = {}
  local ok, err = pcall(persist, session)
  if not ok then
    session.comments = previous_comments
    schedule_render()
    error(err, 0)
  end
  hunks.clear(session.snapshot)
  quickfix.retire(session.snapshot)
  sessions[session.root] = nil
  schedule_render()
end

function M.setup(config)
  store.setup(config)
  local actions = {
    open = function()
      open_diff(M.refresh())
    end,
    files = function()
      files(false)
    end,
    pending = function()
      files(true)
    end,
    comment = function(opts)
      compose(opts.line1, opts.line2, false)
    end,
    ["file-comment"] = function()
      compose(1, 1, true)
    end,
    comments = comments,
    next = function()
      M.jump_comment(1)
    end,
    prev = function()
      M.jump_comment(-1)
    end,
    export = preview,
    copy = function()
      M.copy()
    end,
    quickfix = M.quickfix,
    ["preview-hunk"] = M.preview_hunk,
    refresh = function()
      local session = context()
      local function rebuild()
        local ok, err = pcall(function()
          M.rebuild(session)
          if vim.fn.exists ":DiffviewRefresh" == 2 then
            vim.cmd "DiffviewRefresh"
          end
        end)
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end
      if session.snapshot then
        vim.ui.select({ "Cancel", "Rebuild snapshot" }, {
          prompt = "Reset all hunk checkmarks and rescan disk? Comments will be retained.",
        }, function(choice)
          if choice == "Rebuild snapshot" then
            rebuild()
          end
        end)
      else
        rebuild()
      end
    end,
    toggle = M.toggle,
    clear = function()
      local session = context()
      vim.ui.select({ "Cancel", "Clear review" }, { prompt = "Discard comments and approvals?" }, function(choice)
        if choice == "Clear review" then
          M.clear(session)
        end
      end)
    end,
  }
  vim.api.nvim_create_user_command("ChangeReview", function(opts)
    local action = actions[opts.args ~= "" and opts.args or "open"]
    if not action then
      vim.notify("Unknown review action", vim.log.levels.ERROR)
      return
    end
    local ok, err = pcall(action, opts)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end, {
    nargs = "?",
    range = true,
    complete = function(lead)
      return vim.tbl_filter(function(key)
        return key:sub(1, #lead) == lead
      end, vim.tbl_keys(actions))
    end,
  })
  local group = vim.api.nvim_create_augroup("ChangeReview", { clear = true })
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function(event)
      M.attach(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd(
    { "BufWinEnter", "WinClosed", "WinResized", "TextChanged", "TextChangedI", "DiffUpdated" },
    {
      group = group,
      callback = schedule_render,
    }
  )
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function(event)
      for _, session in pairs(sessions) do
        if
          vim.tbl_contains(session.comments, function(c)
            return c.buf == event.buf
          end, { predicate = true })
        then
          local ok, err = pcall(persist, session)
          if not ok then
            vim.notify("Could not save review comments: " .. tostring(err), vim.log.levels.ERROR)
          end
        end
      end
    end,
  })
  -- Preserve the last known range before an unloaded buffer loses its extmarks.
  vim.api.nvim_create_autocmd("BufUnload", {
    group = group,
    callback = function(event)
      for _, session in pairs(sessions) do
        hunks.detach(session.snapshot, event.buf)
        for _, c in ipairs(session.comments) do
          if c.buf == event.buf then
            if not vim.bo[event.buf].modified then
              c.first, c.last = current_range(c)
              c.first = math.max(1, c.first)
              c.last = math.max(c.first, c.last)
            end
            c.buf, c.mark = nil, nil
          end
        end
      end
    end,
  })
  local map = require("config.keymaps").set
  map("n", "]n", "<cmd>ChangeReview next<cr>", { desc = "Next review comment", group = "change-review" })
  map("n", "[n", "<cmd>ChangeReview prev<cr>", { desc = "Previous review comment", group = "change-review" })
  for key, spec in pairs {
    ro = { "open", "Open change review" },
    rf = { "files", "Review file checklist" },
    rn = { "pending", "Unreviewed files" },
    rr = { "toggle", "Toggle hunk reviewed" },
    rq = { "quickfix", "Review hunks in quickfix" },
    rp = { "preview-hunk", "Preview snapshot hunk" },
    rR = { "refresh", "Rebuild review snapshot and refresh Diffview" },
    rc = { "comment", "Add review comment" },
    rC = { "file-comment", "Add file review comment" },
    rl = { "comments", "Review comments" },
    ry = { "export", "Export review" },
    rY = { "copy", "Copy review to +" },
  } do
    map("n", "<leader>" .. key, "<cmd>ChangeReview " .. spec[1] .. "<cr>", { desc = spec[2], group = "change-review" })
  end
  map("x", "<leader>rc", ":ChangeReview comment<cr>", { desc = "Comment on selected lines", group = "change-review" })
end

return M
