local M = {}
local anchors = vim.api.nvim_create_namespace "change-review-hunk-anchors"
local labels = vim.api.nvim_create_namespace "change-review-hunks"
local serial = 0

local function git(root, args, no_index)
  local cmd = { "git", "--literal-pathspecs", "-C", root }
  vim.list_extend(cmd, args)
  local result = vim.system(cmd, { text = false }):wait(10000)
  assert(result.code == 0 or (no_index and result.code == 1), result.stderr or "Git scan failed")
  return result.stdout or ""
end

local function lines(text)
  return vim.split(text, "\n", { plain = true, trimempty = false })
end

-- Snapshot only on-disk changes. Build completely before replacing an old snapshot.
function M.build(root)
  local head = vim.trim(git(root, { "rev-parse", "--verify", "HEAD" }))
  local names = vim.split(
    git(root, {
      "diff",
      "--no-ext-diff",
      "--no-renames",
      "--name-status",
      "-z",
      head,
      "--",
    }),
    "\0",
    { plain = true, trimempty = true }
  )
  local paths = {}
  for i = 1, #names, 2 do
    paths[names[i + 1]] = names[i]
  end
  for _, path in
    ipairs(
      vim.split(
        git(root, { "ls-files", "--others", "--exclude-standard", "-z" }),
        "\0",
        { plain = true, trimempty = true }
      )
    )
  do
    paths[path] = "?"
  end
  -- Reject dirty source buffers rather than place disk anchors into different text.
  local modified = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.bo[buf].modified then
      modified[vim.fs.normalize(vim.api.nvim_buf_get_name(buf))] = true
    end
  end
  for path in pairs(paths) do
    assert(not modified[root .. "/" .. path], "Save changes before rebuilding review: " .. path)
  end
  serial = serial + 1
  local snapshot = { root = root, head = head, id = serial, files = {}, units = {} }
  for _, path in ipairs(vim.fn.sort(vim.tbl_keys(paths))) do
    local status = paths[path]
    local args = {
      "diff",
      "--no-ext-diff",
      "--no-textconv",
      "--no-renames",
      "--no-color",
      "--unified=0",
      "--inter-hunk-context=0",
      "--submodule=short",
    }
    if status == "?" then
      vim.list_extend(args, { "--no-index", "--", "/dev/null", root .. "/" .. path })
    else
      vim.list_extend(args, { head, "--", path })
    end
    local patch = lines(git(root, args, status == "?"))
    local stat = vim.uv.fs_lstat(root .. "/" .. path)
    local preview_only = status == "D" or status == "T" or (stat and stat.type ~= "file") or false
    for _, line in ipairs(patch) do
      if line:match "^Binary files " then
        preview_only = true
      end
    end
    local file = {
      path = path,
      deleted = status == "D",
      reviewed = false,
      units = {},
      status = status,
      preview_only = preview_only,
    }
    snapshot.files[#snapshot.files + 1] = file
    local function add(first, last, preview, kind)
      local unit = {
        id = #snapshot.units + 1,
        file = file,
        first = first,
        last = last,
        preview = preview,
        kind = kind,
        reviewed = false,
      }
      file.units[#file.units + 1] = unit
      snapshot.units[#snapshot.units + 1] = unit
      return unit
    end
    if status == "A" or status == "?" or preview_only then
      local kind = status == "D" and "Deleted file" or (status == "A" or status == "?") and "New file" or "File change"
      add(1, 1, patch, kind)
      file.whole = true
    else
      local active
      for _, line in ipairs(patch) do
        local old, old_count, new, new_count = line:match "^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@"
        if old then
          local count = tonumber(new_count) or 1
          local first = math.max(1, tonumber(new))
          active = add(first, math.max(first, first + count - 1), {}, count == 0 and "Deletion" or "Hunk")
          active.old_first, active.old_count = tonumber(old), tonumber(old_count) or 1
        end
        if active then
          active.preview[#active.preview + 1] = line
        end
      end
      if #file.units == 0 then
        add(1, 1, patch, "File change") -- Binary, mode-only, symlink or submodule change.
        file.whole = true
      end
    end
  end
  return snapshot
end

function M.range(unit)
  local first, last = unit.first, unit.last
  if unit.buf and vim.api.nvim_buf_is_loaded(unit.buf) then
    local count = vim.api.nvim_buf_line_count(unit.buf)
    if unit.file.whole then
      return 1, count
    end
    if unit.mark then
      local pos = vim.api.nvim_buf_get_extmark_by_id(unit.buf, anchors, unit.mark, { details = true })
      if #pos > 0 then
        first, last = pos[1] + 1, pos[3].end_row or pos[1] + 1
      end
    end
    first = math.max(1, math.min(first, count))
    last = math.max(first, math.min(last, count))
  end
  return first, last
end

function M.label(unit)
  return (unit.reviewed and "[x] " or "[ ] ") .. unit.kind .. " #" .. unit.id
end

function M.attach(snapshot, buf)
  if not snapshot or not vim.api.nvim_buf_is_loaded(buf) or vim.bo[buf].buftype ~= "" then
    return
  end
  local path = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
  for _, unit in ipairs(snapshot.units) do
    if unit.buf == buf and path ~= snapshot.root .. "/" .. unit.file.path then
      M.detach(snapshot, buf)
      vim.api.nvim_buf_clear_namespace(buf, anchors, 0, -1)
      vim.api.nvim_buf_clear_namespace(buf, labels, 0, -1)
      break
    end
  end
  for _, file in ipairs(snapshot.files) do
    if path == snapshot.root .. "/" .. file.path and not file.preview_only then
      vim.api.nvim_buf_clear_namespace(buf, labels, 0, -1)
      local groups = {}
      for _, unit in ipairs(file.units) do
        unit.buf = buf
        local first, last = M.range(unit)
        unit.mark = vim.api.nvim_buf_set_extmark(buf, anchors, first - 1, 0, {
          id = unit.mark,
          end_row = last,
          right_gravity = true,
          end_right_gravity = false,
        })
        groups[first] = groups[first] or {}
        table.insert(groups[first], { "  " .. M.label(unit), unit.reviewed and "DiagnosticOk" or "DiagnosticWarn" })
      end
      for first, text in pairs(groups) do
        vim.api.nvim_buf_set_extmark(buf, labels, first - 1, 0, { virt_text = text, virt_text_pos = "eol" })
      end
    end
  end
end

function M.detach(snapshot, buf)
  if not snapshot then
    return
  end
  for _, unit in ipairs(snapshot.units) do
    if unit.buf == buf then
      unit.first, unit.last = M.range(unit)
      unit.buf, unit.mark = nil, nil
    end
  end
end

function M.clear(snapshot)
  if not snapshot then
    return
  end
  for _, unit in ipairs(snapshot.units) do
    if unit.buf and vim.api.nvim_buf_is_valid(unit.buf) then
      vim.api.nvim_buf_clear_namespace(unit.buf, anchors, 0, -1)
      vim.api.nvim_buf_clear_namespace(unit.buf, labels, 0, -1)
    end
  end
end

function M.at(snapshot, buf, line)
  M.attach(snapshot, buf)
  local matches = {}
  for _, unit in ipairs(snapshot.units) do
    if unit.buf == buf then
      local first, last = M.range(unit)
      if line >= first and line <= last then
        matches[#matches + 1] = unit
      end
    end
  end
  return matches
end

function M.toggle(snapshot, unit)
  assert(snapshot.units[unit.id] == unit, "Review snapshot was rebuilt; select a current hunk")
  unit.reviewed = not unit.reviewed
  unit.file.reviewed = true
  for _, item in ipairs(unit.file.units) do
    if not item.reviewed then
      unit.file.reviewed = false
    end
  end
  if unit.buf then
    M.attach(snapshot, unit.buf)
  end
end

function M.toggle_file(snapshot, file)
  assert(vim.tbl_contains(snapshot.files, file), "Review snapshot was rebuilt; reopen the checklist")
  local reviewed = not file.reviewed
  for _, unit in ipairs(file.units) do
    unit.reviewed = reviewed
  end
  file.reviewed = reviewed
  for _, unit in ipairs(file.units) do
    if unit.buf then
      M.attach(snapshot, unit.buf)
      break
    end
  end
end

return M
