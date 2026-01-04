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

  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    config = function()
      require("todo-comments").setup {
        signs = false,
      }
    end,
    keys = {
      {
        "sto",
        function()
          require("snacks").picker.todo_comments()
        end,
        desc = "Open TODOs in snacks picker",
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
