local M = {}

local registered = {}

local function normalize_modes(mode)
  if type(mode) == "table" then
    return vim.deepcopy(mode)
  end
  return { mode }
end

local function copy_registration(mode, lhs, rhs, opts)
  opts = opts or {}
  return {
    mode = normalize_modes(mode),
    lhs = lhs,
    desc = opts.desc,
    group = opts.group,
    buffer = opts.buffer,
    rhs_type = type(rhs),
  }
end

function M.set(mode, lhs, rhs, opts)
  opts = opts or {}
  local vim_opts = vim.deepcopy(opts)
  vim_opts.group = nil
  vim.keymap.set(mode, lhs, rhs, vim_opts)
  table.insert(registered, copy_registration(mode, lhs, rhs, opts))
end

function M.registered()
  return vim.deepcopy(registered)
end

return M
