local ON_LOCAL = os.getenv "SSH_CLIENT" == nil

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system { "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path }
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

local packer = require "packer"
vim.keymap.set("n", "<leader>pi", packer.install)
vim.keymap.set("n", "<leader>ps", packer.sync)
vim.keymap.set("n", "<leader>pS", packer.status)

packer.init {
  compile_on_sync = true,
  git = { clone_timeout = 6000 },
  display = {
    open_fn = function()
      return require("packer.util").float { border = "single" }
    end,
  },
}
return require("packer").startup(function(use)
  use "wbthomason/packer.nvim"

  -- LSP
  use { "neovim/nvim-lspconfig" }
  use { "williamboman/mason.nvim" }
  use { "williamboman/mason-lspconfig.nvim" }
  use { "j-hui/fidget.nvim", cond = ON_LOCAL }
  use {
    "folke/neodev.nvim",
    cond = ON_LOCAL,
  }
  use {
    "SmiteshP/nvim-navic",
    requires = "neovim/nvim-lspconfig",
    cond = ON_LOCAL,
  }
  use { "mfussenegger/nvim-lint", cond = ON_LOCAL }
  use { "stevearc/conform.nvim", cond = ON_LOCAL }

  -- Snippets
  use {
    "L3MON4D3/LuaSnip",
    cond = ON_LOCAL,
  }
  use {
    "rafamadriz/friendly-snippets",
    cond = ON_LOCAL,
  }

  -- Autocompletion
  use { "hrsh7th/nvim-cmp" }
  use { "hrsh7th/cmp-nvim-lsp" }
  use { "hrsh7th/cmp-path" }
  use {
    "saadparwaiz1/cmp_luasnip",
    cond = ON_LOCAL,
  }
  use {
    "hrsh7th/cmp-nvim-lua",
    cond = ON_LOCAL,
  }
  use { "hrsh7th/cmp-emoji", cond = ON_LOCAL }

  -- Treesitter
  use { "nvim-treesitter/nvim-treesitter", run = { ":TSUpdate" } }
  use { -- Additional text objects via treesitter
    "nvim-treesitter/nvim-treesitter-textobjects",
    cond = ON_LOCAL,
  }
  use { "nvim-treesitter/nvim-treesitter-refactor", cond = ON_LOCAL }
  use {
    "nvim-treesitter/playground",
    cond = ON_LOCAL,
  }
  use { "simrat39/symbols-outline.nvim", cond = ON_LOCAL }

  -- Telescope
  use {
    "nvim-telescope/telescope.nvim",
    requires = { { "nvim-lua/plenary.nvim" } },
  }
  use {
    "nvim-telescope/telescope-fzf-native.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    run = "make",
  }
  use "nvim-telescope/telescope-ui-select.nvim"
  use { "ahmedkhalf/project.nvim" }

  -- Navigation
  use { "nvim-tree/nvim-tree.lua", cond = ON_LOCAL }

  -- DAP
  use { "mfussenegger/nvim-dap", cond = ON_LOCAL }
  use {
    "rcarriga/nvim-dap-ui",
    requires = { "mfussenegger/nvim-dap", "mfussenegger/nvim-dap-python" },
    cond = ON_LOCAL,
  }
  use { "mfussenegger/nvim-dap-python", cond = ON_LOCAL }
  use {
    "theHamsta/nvim-dap-virtual-text",
    requires = { "mfussenegger/nvim-dap", "mfussenegger/nvim-dap-python" },
    cond = ON_LOCAL,
  }
  use { "LiadOz/nvim-dap-repl-highlights", cond = ON_LOCAL }

  -- Looks
  use {
    "nvim-lualine/lualine.nvim",
  }
  use {
    "kyazdani42/nvim-web-devicons",
  }
  use { "norcalli/nvim-colorizer.lua", cond = ON_LOCAL }
  use "lukas-reineke/indent-blankline.nvim"
  use { "akinsho/bufferline.nvim" }
  use { "ellisonleao/gruvbox.nvim" }
  use { "HiPhish/rainbow-delimiters.nvim", cond = ON_LOCAL }

  -- Navigation
  use "theprimeagen/harpoon"
  use { "folke/todo-comments.nvim", cond = ON_LOCAL }

  -- Git
  use "tpope/vim-fugitive"
  use {
    "tpope/vim-rhubarb",
    cond = ON_LOCAL,
  }
  use "lewis6991/gitsigns.nvim"

  -- Operators and motions
  use { "tpope/vim-unimpaired" }
  -- Collection of various small independent plugins/modules
  use {
    "echasnovski/mini.nvim",
  }
  use {
    "kylechui/nvim-surround",
  }
  use { "numToStr/Comment.nvim" } -- "gc" to comment visual regions/lines
  use {
    "crpier/fast-jobs.nvim",
    cond = ON_LOCAL,
  }

  -- New commands
  use { "ojroques/vim-oscyank" }
  use {
    "mbbill/undotree",
    cond = ON_LOCAL,
  }

  -- Misc
  use "lewis6991/impatient.nvim"
  use {
    "eandrju/cellular-automaton.nvim",
    cond = ON_LOCAL,
  }
  use {
    "renerocksai/calendar-vim",
    cond = ON_LOCAL,
  }
  use {
    "renerocksai/telekasten.nvim",
    cond = ON_LOCAL,
  }

  -- Detect tabstop and shiftwidth automatically
  use "tpope/vim-sleuth"

  -- Filetype
  use {
    "dag/vim-fish",
    ft = "fish",
  }

  -- Trials
  use {
    "folke/twilight.nvim",
    cond = ON_LOCAL,
  }

  -- TODO:
  -- use {
  --   "mrcjkb/rustaceanvim",
  --   lazy = false, -- This plugin is already lazy
  -- }

  -- use('crispgm/nvim-go')

  pcall(require, "impatient")
  if packer_bootstrap then
    require("packer").sync()
  end
end)
