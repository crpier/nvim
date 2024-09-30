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
        end,
      }
    end,
  },
  -- amongst your other plugins
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup {}
    end,
    keys = {
      {
        -- TODO: make this toggle-able so that it can be kept in in the background
        "<leader>lg",
        function()
          local Terminal = require("toggleterm.terminal").Terminal
          local lazygit = Terminal:new {
            cmd = "lazygit",
            dir = "git_dir",
            direction = "float",
            float_opts = {
              border = "none",
              width = vim.o.columns,
              height = vim.o.lines,
            },
            -- function to run on opening the terminal
            on_open = function(term)
              vim.cmd "startinsert!"
              vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
            end,
            -- function to run on closing the terminal
            on_close = function(term)
              vim.cmd "startinsert!"
            end,
          }

          lazygit:open()
        end,
      },
    },
    lazy = false,
  },
  {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
    cmd = { "Git", "GBrowse" },
    keys = { {
      "gs",
      function()
        vim.cmd "tab Git"
      end,
    } },
  },
}
