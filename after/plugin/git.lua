------ Git ------
-- gitsigns
-- vim.api.nvim_set_hl(0, "GitSignsAddNr", { bg = "none" })
local ok, gitsigns = pcall(require, "gitsigns")
if ok then
  gitsigns.setup {
    -- numhl = true,
    -- signcolumn = false,
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end
      -- Navigation
      map("n", "]h", function()
        if vim.wo.diff then
          return "]h"
        end
        vim.schedule(function()
          gs.next_hunk()
        end)
        return "<Ignore>"
      end, { expr = true })
      map("n", "[h", function()
        if vim.wo.diff then
          return "[h"
        end
        vim.schedule(function()
          gs.prev_hunk()
        end)
        return "<Ignore>"
      end, { expr = true })

      -- Actions
      map("n", "g.", gs.stage_hunk)
      map("n", "g>", gs.stage_buffer)
      map("n", "g,", gs.reset_hunk)
      map("n", "g<", gs.reset_buffer)
      map("n", "g;", gs.undo_stage_hunk)
      map("n", "g/", gs.preview_hunk)
      map("n", "gl", function()
        gs.blame_line { full = false }
      end)
      map("n", "gL", function()
        gs.blame_line { full = true }
      end)
      map("n", "dvo", gs.diffthis)
      map("n", "dvm", function()
        gs.diffthis "master"
      end)
      map("n", "dvn", function()
        gs.diffthis "main"
      end)
      map("n", "dv1", function()
        gs.diffthis "HEAD~1"
      end)
      map("n", "dv2", function()
        gs.diffthis "HEAD~2"
      end)
      map("n", "dv3", function()
        gs.diffthis "HEAD~3"
      end)
      map("n", "dv4", function()
        gs.diffthis "HEAD~4"
      end)
      map("n", "dv5", function()
        gs.diffthis "HEAD~5"
      end)
      map("n", "dv6", function()
        gs.diffthis "HEAD~6"
      end)
      map("n", "yogd", gs.toggle_deleted)

      -- Text object
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")

      -- local hls = {
      --   "GitSignsAddNr",
      --   "GitSignsChangeNr",
      --   "GitSignsDeleteNr",
      --   "GitSignsTopdeleteNr",
      --   "GitSignsChangedeleteNr",
      --   "GitSignsUntrackedNr",
      -- }

      -- Adjust GitSigns highlights to have bg=none, but keep the old fg
      -- for _, hl in ipairs(hls) do
      --   local old_highlight = vim.api.nvim_get_hl_by_name(hl, true)
      --   old_highlight.background = nil
      --   vim.api.nvim_set_hl(0, hl, old_highlight)
      -- end
    end,
  }
end

--[[
- g commands:
  - gH
  - g.
  - g,
  - g/
  - gi
  - gM
  - gm
  - gV
  - gy
  - g;
]]
-- fugitive
vim.keymap.set("n", "gs", "<cmd>silent! tab G<CR>")
vim.keymap.set("n", "<leader>gs", "<cmd>Git push<CR>")
vim.keymap.set("n", "<leader>gu", "<cmd>Git pull<CR>")
vim.keymap.set("n", "<leader>gl", "<cmd>tab Git log -n 10<cr>")
vim.keymap.set("n", "<leader>gL", "<cmd>tab Git log<cr>")
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>")

-- Still on the fence about these
-- vim.keymap.set("n", "<leader>gc", "<cmd>Git clean -fd<CR>")
-- vim.keymap.set("n", "gh", "<cmd>Git fetch<cr>")
