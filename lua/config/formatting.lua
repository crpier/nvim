local M = {}

local function buffer_path(bufnr)
  return vim.api.nvim_buf_get_name(bufnr)
end

local function buffer_text(bufnr)
  return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n") .. "\n"
end

local function text_to_lines(text)
  local lines = vim.split(text, "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines)
  end
  return lines
end

local function executable(command)
  return vim.fn.executable(command) == 1
end

local function dirname(path)
  return vim.fn.fnamemodify(path, ":h")
end

local function formatter_cwd(formatter, bufnr)
  if formatter.cwd ~= nil then
    return formatter.cwd(bufnr)
  end
  local path = buffer_path(bufnr)
  return path ~= "" and dirname(path) or vim.fn.getcwd()
end

local function changedtick(bufnr)
  return vim.api.nvim_buf_get_changedtick(bufnr)
end

local function same_buffer(bufnr, expected_changedtick)
  return vim.api.nvim_buf_is_valid(bufnr) and changedtick(bufnr) == expected_changedtick
end

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.WARN, { title = "formatting" })
end

local function replace_buffer(bufnr, text)
  local lines = text_to_lines(text)
  if vim.deep_equal(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), lines) then
    return
  end

  local view = vim.fn.winsaveview()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.fn.winrestview(view)
end

local function apply_lsp_fallback(bufnr)
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  if #clients == 0 then
    notify "No external formatter or LSP client available"
    return
  end
  vim.lsp.buf.format { bufnr = bufnr, async = true }
end

local function run_stdin_formatter(formatter, bufnr, input, callback)
  local args = type(formatter.args) == "function" and formatter.args(bufnr) or formatter.args or {}
  local command = vim.list_extend({ formatter.cmd }, vim.deepcopy(args))
  vim.system(command, { text = true, stdin = input, cwd = formatter_cwd(formatter, bufnr) }, function(result)
    vim.schedule(function()
      local exit_codes = formatter.exit_codes or { 0 }
      local ok = vim.tbl_contains(exit_codes, result.code)
      if not ok then
        callback(nil, vim.trim(result.stderr or result.stdout or "formatter failed"))
        return
      end
      callback(result.stdout ~= "" and result.stdout or input)
    end)
  end)
end

local function temporary_file_for(bufnr)
  local source = buffer_path(bufnr)
  local dir = source ~= "" and dirname(source) or vim.fn.getcwd()
  local extension = vim.fn.fnamemodify(source, ":e")
  local suffix = extension ~= "" and "." .. extension or ""
  return dir .. "/.nvim-format-" .. vim.fn.strftime "%Y%m%d%H%M%S" .. "-" .. math.random(100000, 999999) .. suffix
end

local function run_file_formatter(formatter, bufnr, input, callback)
  local temp = temporary_file_for(bufnr)
  vim.fn.writefile(text_to_lines(input), temp)

  local args = type(formatter.args) == "function" and formatter.args(bufnr, temp) or formatter.args or {}
  args = vim.tbl_map(function(arg)
    return arg == "$FILENAME" and temp or arg
  end, vim.deepcopy(args))

  local command = vim.list_extend({ formatter.cmd }, args)
  vim.system(command, { text = true, cwd = formatter_cwd(formatter, bufnr) }, function(result)
    vim.schedule(function()
      local exit_codes = formatter.exit_codes or { 0 }
      local ok = vim.tbl_contains(exit_codes, result.code)
      if not ok then
        vim.fn.delete(temp)
        callback(nil, vim.trim(result.stderr or result.stdout or "formatter failed"))
        return
      end

      local lines = vim.fn.readfile(temp)
      vim.fn.delete(temp)
      callback(table.concat(lines, "\n") .. (#lines > 0 and "\n" or ""))
    end)
  end)
end

local function run_formatters(bufnr, formatters, index, input, expected_changedtick)
  if index > #formatters then
    vim.schedule(function()
      if same_buffer(bufnr, expected_changedtick) then
        replace_buffer(bufnr, input)
      else
        notify "Buffer changed while formatting; skipped applying formatter output"
      end
    end)
    return
  end

  local formatter = formatters[index]
  local runner = formatter.stdin == false and run_file_formatter or run_stdin_formatter
  runner(formatter, bufnr, input, function(output, err)
    if err ~= nil then
      vim.schedule(function()
        notify(formatter.name .. " failed: " .. err)
      end)
      return
    end
    run_formatters(bufnr, formatters, index + 1, output, expected_changedtick)
  end)
end

--- Format a buffer with configured external commands, falling back to LSP when none are available.
---@param opts? {bufnr?: number}
function M.format(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  local configured = require("config.toolchain").formatters_for(filetype)

  local missing = {}
  for _, formatter in ipairs(configured) do
    if not executable(formatter.cmd) then
      missing[#missing + 1] = string.format("%s requires `%s`", formatter.name, formatter.cmd)
    end
  end
  if #missing > 0 then
    notify("Missing formatter executable(s): " .. table.concat(missing, ", "))
  end

  local available = vim.tbl_filter(function(formatter)
    return executable(formatter.cmd)
  end, configured)

  if #available == 0 then
    apply_lsp_fallback(bufnr)
    return
  end

  run_formatters(bufnr, available, 1, buffer_text(bufnr), changedtick(bufnr))
end

--- Install the manual formatting keymap that replaced conform.nvim's mapping.
function M.setup()
  require("config.keymaps").set("n", "gq", function()
    M.format { async = true }
  end, { desc = "Format buffer", group = "formatting" })
end

return M
