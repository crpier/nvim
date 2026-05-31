return {
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
      require("gitsigns").setup {
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          map("n", "]c", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true })
          map("n", "[c", function()
            if vim.wo.diff then
              return "[c"
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

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
        end,
      }
    end,
  },
  -- amongst your other plugins
  {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
    cmd = { "Git", "GBrowse", "Gvdiffsplit" },
    keys = {
      {
        "gs",
        function()
          vim.cmd "tab Git"
        end,
        desc = "Git status",
      },
      {
        "<leader>gu",
        function()
          vim.cmd "Git pull"
        end,
        desc = "Git pull",
      },
      {
        "<leader>gs",
        function()
          vim.cmd "Git push"
        end,
        desc = "Git push",
      },
      {
        "<leader>ga",
        function()
          vim.cmd "Git add ."
        end,
        desc = "Git add .",
      },
    },
  },
}
