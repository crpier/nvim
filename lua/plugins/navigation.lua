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
    event = "VeryLazy",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("todo-comments").setup {
        signs = false,
      }
      require("telescope").load_extension "todo-comments"
    end,
    keys = {
      {
        "sto",
        "<cmd>TodoTelescope<CR>",
        desc = "Open TODOs in telescope",
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
}
