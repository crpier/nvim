return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons",
      "nvim-telescope/telescope-fzf-native.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-project.nvim",
    },
    cmd = "Telescope",
    config = function()
      local telescope = require "telescope"
      local project_base_dirs = {
        { path = "~/Projects", max_depth = 2 },
        "~/.config/nvim",
        "~/.dotfiles",
        "~/vault",
      }
      for _, v in ipairs(require("config.utils").load_local_options().project_base_dirs) do
        table.insert(project_base_dirs, v)
      end

      telescope.setup {
        extensions = {
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
          },
          project = {
            base_dirs = project_base_dirs,
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {},
          },
        },
      }
      telescope.load_extension "fzf"
      telescope.load_extension "ui-select"
      telescope.load_extension "project"
    end,
    keys = {
      {
        "sf",
        function()
          require("telescope.builtin").git_files()
        end,
      },
      {
        "sF",
        function()
          require("telescope.builtin").find_files { hidden = true }
        end,
      },
      {
        "sl",
        function()
          require("telescope.builtin").live_grep()
        end,
      },
      {
        "su",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find()
        end,
      },
      {
        "so",
        function()
          require("telescope.builtin").oldfiles()
        end,
      },
      {
        "s/",
        function()
          require("telescope.builtin").grep_string {
            search = vim.fn.input "Grep > ",
          }
        end,
      },
      {
        "sd",
        function()
          require("telescope.builtin").diagnostics {}
        end,
        desc = "Open all diagnostics in Telescope",
      },
      {
        "sk",
        function()
          require("telescope.builtin").keymaps()
        end,
      },
      {
        "s<space>",
        function()
          require("telescope.builtin").buffers()
        end,
      },
      {
        "sw",
        function()
          require("telescope.builtin").grep_string {}
        end,
      },
      {
        "sm",
        function()
          require("telescope.builtin").marks {}
        end,
      },
      {
        "sgc",
        function()
          require("telescope.builtin").git_status()
        end,
      },
      {
        "sgb",
        function()
          require("telescope.builtin").git_branches()
        end,
      },
      {
        "sp",
        function()
          require("telescope").extensions.project.project {}
        end,
        desc = "Search projects",
      },
      -- TODO: I'd like something that only shows registers 0-9
      {
        "sr",
        function()
          require("telescope.builtin").registers()
        end,
        desc = "Search registers",
      },
    },
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
  },
  {
    "hedyhli/outline.nvim",
    cmd = "Outline",
    config = function()
      require("outline").setup {}
    end,
    keys = { {
      "<leader>so",
      function()
        require("outline").toggle()
      end,
    } },
  },
}
