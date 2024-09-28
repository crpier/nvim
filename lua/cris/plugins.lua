local ON_LOCAL = os.getenv "SSH_CLIENT" == nil

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy").setup {
  spec = {
    -- add your plugins here
    { "neovim/nvim-lspconfig" },
    -- LSP
    { "williamboman/mason.nvim" },
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
    { "Bilal2453/luvit-meta", lazy = true },
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
    { "mfussenegger/nvim-lint", cond = ON_LOCAL },
    { "stevearc/conform.nvim", cond = ON_LOCAL },

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
    { "nvim-lua/plenary.nvim" },
    {
      "nvim-telescope/telescope.nvim",
    },
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
    },
    "nvim-telescope/telescope-ui-select.nvim",
    -- use a fork until  vim.lsp.buf_get_clients() is removed from upstream
    { "LennyPhoenix/project.nvim", lazy = false, branch = "fix-get_clients" },

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
    {
      "kyazdani42/nvim-web-devicons",
    },
    { "lukas-reineke/indent-blankline.nvim" },
    { "akinsho/bufferline.nvim" },
    { "ellisonleao/gruvbox.nvim" },
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
    { "eandrju/cellular-automaton.nvim", cond = ON_LOCAL },

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
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
  defaults = {
    lazy = true,
  },
}
