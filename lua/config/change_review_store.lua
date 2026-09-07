local M = {}
local directory

function M.setup(opts)
  directory = opts and opts.state_dir or vim.fn.stdpath "state" .. "/change-review"
end

local function path(root)
  assert(directory, "Review storage has not been initialized")
  return directory .. "/" .. vim.fn.sha256(root) .. ".json"
end

local function read(filename)
  if vim.fn.filereadable(filename) == 0 then
    return nil
  end
  return table.concat(vim.fn.readfile(filename), "\n")
end

local function token(text)
  return text and vim.fn.sha256(text) or "missing"
end

function M.load(root)
  local text = read(path(root))
  if not text then
    return {}, token(nil)
  end
  local value = vim.json.decode(text)
  assert(
    type(value) == "table" and value.version == 1 and value.root == root and type(value.comments) == "table",
    "Invalid review state: " .. path(root)
  )
  local ids = {}
  for _, c in ipairs(value.comments) do
    assert(
      type(c) == "table"
        and type(c.id) == "number"
        and c.id >= 1
        and c.id % 1 == 0
        and not ids[c.id]
        and type(c.path) == "string"
        and c.path ~= ""
        and not c.path:match "^/"
        and not ("/" .. c.path .. "/"):find("/../", 1, true)
        and type(c.text) == "string"
        and type(c.excerpt) == "table"
        and type(c.first) == "number"
        and c.first >= 1
        and c.first % 1 == 0
        and type(c.last) == "number"
        and c.last >= c.first
        and c.last % 1 == 0
        and type(c.file_level) == "boolean"
        and type(c.resolved) == "boolean",
      "Invalid stored review comment"
    )
    ids[c.id] = true
    for _, line in ipairs(c.excerpt) do
      assert(type(line) == "string", "Invalid stored excerpt")
    end
  end
  return value.comments, token(text)
end

-- Atomic replacement protects against interrupted writes. A lock and token check
-- prevent two editors from silently replacing each other's saved comments.
function M.save(root, comments, previous)
  vim.fn.mkdir(directory, "p", 448)
  local filename = path(root)
  local lock = filename .. ".lock"
  local fd, err = vim.uv.fs_open(lock, "wx", 384)
  assert(fd, "Cannot lock review state (another writer or stale lock): " .. lock .. ": " .. tostring(err))
  vim.uv.fs_close(fd)
  local temp = filename .. "." .. vim.fn.getpid() .. ".tmp"
  local result
  local ok, failure = pcall(function()
    assert(
      token(read(filename)) == previous,
      "Review comments changed in another Neovim instance; reopen before saving"
    )
    local text = vim.json.encode { version = 1, root = root, comments = comments }
    assert(vim.fn.writefile({ text }, temp) == 0, "Could not write review state")
    assert(vim.uv.fs_chmod(temp, 384))
    assert(vim.uv.fs_rename(temp, filename))
    result = token(text)
  end)
  vim.uv.fs_unlink(temp)
  vim.uv.fs_unlink(lock)
  if not ok then
    error(failure, 0)
  end
  return result
end

return M
