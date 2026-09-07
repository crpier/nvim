local M = {}
local padding = vim.api.nvim_create_namespace "change-review-padding"

-- Use Neovim's own filler rows, including linematch, rather than parsing Git hunks.
local function rows(win)
  return vim.api.nvim_win_call(win, function()
    local result, filler = {}, 0
    for line = 1, vim.api.nvim_buf_line_count(0) do
      filler = filler + vim.fn.diff_filler(line)
      result[line] = line + filler
    end
    return result
  end)
end

function M.refresh(source_ns)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      vim.api.nvim_buf_clear_namespace(buf, padding, 0, -1)
    end
  end
  local placed = {}
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local windows = vim.tbl_filter(function(win)
      return vim.wo[win].diff
    end, vim.api.nvim_tabpage_list_wins(tab))
    -- Two-way review only. Do not guess pairings in merge layouts.
    if #windows == 2 then
      local positions = { rows(windows[1]), rows(windows[2]) }
      for side = 1, 2 do
        local source = vim.api.nvim_win_get_buf(windows[side])
        local target = vim.api.nvim_win_get_buf(windows[3 - side])
        if source ~= target then
          for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(source, source_ns, 0, -1, { details = true })) do
            local lines = mark[4].virt_lines
            local display_row = positions[side][mark[2] + 1]
            if lines and #lines > 0 and display_row then
              local anchor = 0
              for line, row in ipairs(positions[3 - side]) do
                if row > display_row then
                  break
                end
                anchor = line
              end
              -- Inside an insertion the other side has filler, not an addressable
              -- line. Put padding before that filler; unchanged code below aligns.
              -- Virtual lines above the first buffer line can be invisible at
              -- topline=1. At BOF, use the first addressable line instead.
              local above = false
              local row = math.max(0, anchor - 1)
              local key = table.concat({ source, mark[1], target, row, tostring(above) }, ":")
              if not placed[key] then
                placed[key] = true
                local blanks = {}
                for _ = 1, #lines do
                  blanks[#blanks + 1] = { { "", "Normal" } }
                end
                vim.api.nvim_buf_set_extmark(target, padding, row, 0, {
                  virt_lines = blanks,
                  virt_lines_above = above,
                })
              end
            end
          end
        end
      end
    end
  end
end

return M
