local ON_LOCAL = os.getenv "SSH_CLIENT" == nil

local lazy = require "lazy"
lazy.setup {
  spec = {
    -- add your plugins here
    { "neovim/nvim-lspconfig" },
    -- LSP
    { "williamboman/mason-lspconfig.nvim" },
    { "j-hui/fidget.nvim", cond = ON_LOCAL },
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "luvit-meta/library", words = { "vim%.uv" } },
        },
      },
    },
    { "Bilal2453/luvit-meta" },
    { -- optional completion source for require statements and module annotations
      "hrsh7th/nvim-cmp",
      opts = function(_, opts)
        opts.sources = opts.sources or {}
        table.insert(opts.sources, {
          name = "lazydev",
          group_index = 0, -- set group index to 0 to skip loading LuaLS completions
        })
      end,
    },

    { "mfussenegger/nvim-lint", cond = ON_LOCAL },
    { "stevearc/conform.nvim", cond = ON_LOCAL },
    {
      "SmiteshP/nvim-navic",
      cond = ON_LOCAL,
    },

    -- Snippets
    {
      "L3MON4D3/LuaSnip",
      cond = ON_LOCAL,
    },
    {
      "rafamadriz/friendly-snippets",
      cond = ON_LOCAL,
    },

    -- Autocompletion
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-path" },
    { "saadparwaiz1/cmp_luasnip", cond = ON_LOCAL },
    { "hrsh7th/cmp-nvim-lua", cond = ON_LOCAL },
    { "hrsh7th/cmp-emoji", cond = ON_LOCAL },

    -- Treesitter
    { "nvim-treesitter/nvim-treesitter", run = { ":TSUpdate" } },
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      cond = ON_LOCAL,
    },
    { "nvim-treesitter/nvim-treesitter-refactor", cond = ON_LOCAL },
    {
      "nvim-treesitter/playground",
      cond = ON_LOCAL,
      cmd = "TSPlaygroundToggle",
    },
    {
      "hedyhli/outline.nvim",
      cond = ON_LOCAL,
      cmd = "Outline",
      config = function()
        require("outline").setup {
          -- Your setup opts here (leave empty to use defaults)
        }
      end,
    },

    -- Telescope

    -- Navigation
    { "nvim-tree/nvim-tree.lua", cond = ON_LOCAL },

    -- DAP
    { "mfussenegger/nvim-dap", cond = ON_LOCAL },
    { "rcarriga/nvim-dap-ui", cond = ON_LOCAL },
    { "mfussenegger/nvim-dap-python", cond = ON_LOCAL },
    { "theHamsta/nvim-dap-virtual-text", cond = ON_LOCAL },
    { "LiadOz/nvim-dap-repl-highlights", cond = ON_LOCAL },
    { "nvim-neotest/nvim-nio" },

    -- Looks
    {
      "nvim-lualine/lualine.nvim",
    },
    { "lukas-reineke/indent-blankline.nvim" },
    { "akinsho/bufferline.nvim" },
    { "ellisonleao/gruvbox.nvim", lazy = false },
    { "HiPhish/rainbow-delimiters.nvim", cond = ON_LOCAL },

    -- Navigation
    { "theprimeagen/harpoon" },
    { "folke/todo-comments.nvim", cond = ON_LOCAL },

    -- Git
    { "tpope/vim-fugitive" },
    {
      "tpope/vim-rhubarb",
      cond = ON_LOCAL,
    },
    { "lewis6991/gitsigns.nvim" },

    -- Operators and motions
    { "tpope/vim-unimpaired", lazy = false },
    -- Collection of various small independent plugins/modules
    { "echasnovski/mini.nvim" },
    { "kylechui/nvim-surround" },
    { "numToStr/Comment.nvim" },
    { "crpier/fast-jobs.nvim", cond = ON_LOCAL },

    -- New commands
    { "ojroques/vim-oscyank", lazy = false },
    { "mbbill/undotree", cond = ON_LOCAL },

    -- Misc
    { "eandrju/cellular-automaton.nvim", cond = ON_LOCAL, cmd = "CellularAutomaton" },

    -- Detect tabstop and shiftwidth automatically
    { "tpope/vim-sleuth" },

    -- Filetype
    { "dag/vim-fish", ft = "fish" },

    -- Trials
    { "folke/twilight.nvim", cond = ON_LOCAL },

    { "supermaven-inc/supermaven-nvim", lazy = false },
    { "yetone/avante.nvim", build = "make", cmd = "Avante" },
    { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "Avante" } },
    { "MunifTanjim/nui.nvim" },
  },
  checker = { enabled = false },
  defaults = {
    lazy = true,
  },
  vim.keymap.set("n", "<leader>la", require("lazy").home),
}
