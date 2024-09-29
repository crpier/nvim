return {
  {
    "theprimeagen/harpoon",
    keys = {
      {
        "mm",
        function()
          require("harpoon.mark").add_file()
        end,
      },
      {
        "mq",
        function()
          require("harpoon.ui").toggle_quick_menu()
        end,
      },
      {
        "ma",
        function()
          require("harpoon.ui").nav_file(1)
        end,
      },
      {
        "ms",
        function()
          require("harpoon.ui").nav_file(2)
        end,
      },
      {
        "md",
        function()
          require("harpoon.ui").nav_file(3)
        end,
      },
      {
        "mf",
        function()
          require("harpoon.ui").nav_file(4)
        end,
      },
      {
        "mg",
        function()
          require("harpoon.term").gotoTerminal(1)
        end,
      },
    },
  },

  -- TODO: try to be smarter about enabling this, so that we get highlighting
  -- maybe an autocommand on BufRead that checks if there's a todo in the buffer?
  -- maybe also a InsertLeave?
  {
    "folke/todo-comments.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("todo-comments").setup {}
      require("telescope").load_extension "todo-comments"
    end,
    keys = {
      {
        "st",
        "<cmd>TodoTelescope<CR>",
        desc = "Toggle todo comments",
      },
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next todo",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous todo",
      },
    },
  },

  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup {
        update_focused_file = {
          enable = true,
          update_root = true,
          ignore_list = {},
        },
      }
    end,
    keys = {
      {
        "<leader>e",
        "<cmd>NvimTreeToggle<CR>",
        desc = "Toggle nvim-tree",
      },
    },
  },
}
