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
  use { "j-hui/fidget.nvim", tag = "legacy" }
  use {
    "folke/neodev.nvim",
    cond = function()
      return os.getenv "SSH_CLIENT" == nil
    end,
  }
  use { "jose-elias-alvarez/null-ls.nvim" }
  use {
    "SmiteshP/nvim-navic",
    requires = "neovim/nvim-lspconfig",

    cond = function()
      return os.getenv "SSH_CLIENT" == nil
    end,
  }

  -- Snippets
  use {
    "L3MON4D3/LuaSnip",
    cond = function()
      return os.getenv "SSH_CLIENT" == nil
    end,
  }
  use {
    "rafamadriz/friendly-snippets",
    cond = function()
      return os.getenv "SSH_CLIENT" == nil
    end,
  }

  -- Autocompletion
  use { "hrsh7th/nvim-cmp" }
  use { "hrsh7th/cmp-nvim-lsp" }
  use { "hrsh7th/cmp-path" }
  use {
    "saadparwaiz1/cmp_luasnip",
    cond = function()
      return os.getenv "SSH_CLIENT" == nil
    end,
  }
  use {
    "hrsh7th/cmp-nvim-lua",
    cond = function()
      return os.getenv "SSH_CLIENT" == nil
    end,
  }
  use { "hrsh7th/cmp-emoji" }

  -- Treesitter
  use { "nvim-treesitter/nvim-treesitter", run = { ":TSUpdate" } }
  use { -- Additional text objects via treesitter
    "nvim-treesitter/nvim-treesitter-textobjects",
  }
  use {
    "nvim-treesitter/playground",
    cond = function()
      return os.getenv "SSH_CLIENT" == nil
    end,
  }

  -- Telescope
  use {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    requires = { { "nvim-lua/plenary.nvim" } },
  }
  use {
    "nvim-telescope/telescope-fzf-native.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    run = "make",
  }
  use { "ahmedkhalf/project.nvim" }

  -- DAP
  use "mfussenegger/nvim-dap"
  use {
    "rcarriga/nvim-dap-ui",
    requires = { "mfussenegger/nvim-dap", "mfussenegger/nvim-dap-python" },
  }
  use "mfussenegger/nvim-dap-python"
  use {
    "theHamsta/nvim-dap-virtual-text",
    requires = { "mfussenegger/nvim-dap", "mfussenegger/nvim-dap-python" },
  }

  -- Looks
  use {
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true },
  }

  -- Navigation
  use "theprimeagen/harpoon"

  -- Git
  use "tpope/vim-fugitive"
  use {
    "tpope/vim-rhubarb",
    cond = function()
      return os.getenv "SSH_CLIENT" == nil
    end,
  }
  use "lewis6991/gitsigns.nvim"

  -- Operators and motions
  use { "tpope/vim-unimpaired" }
  use {
    "kylechui/nvim-surround",
  }
  use { "numToStr/Comment.nvim" } -- "gc" to comment visual regions/lines

  -- New commands
  use { "ojroques/vim-oscyank" }
  use {
    "mbbill/undotree",
    cond = function()
      return os.getenv "SSH_CLIENT" == nil
    end,
  }

  -- Misc
  use "lewis6991/impatient.nvim"
  use {
    "crpier/fast-jobs.nvim",
    cond = function()
      return os.getenv "SSH_CLIENT" == nil
    end,
  }
  -- Detect tabstop and shiftwidth automatically
  use "tpope/vim-sleuth"

  use {
    "renerocksai/calendar-vim",
    cond = function()
      return os.getenv "SSH_CLIENT" == nil
    end,
  }
  use {
    "renerocksai/telekasten.nvim",
    cond = function()
      return os.getenv "SSH_CLIENT" == nil
    end,
  }

  -- Filetype
  use {
    "dag/vim-fish",
    ft = "fish",
    cond = function()
      return os.getenv "SSH_CLIENT" == nil
    end,
  }

  -- Trials
  use {
    "eandrju/cellular-automaton.nvim",
    cond = function()
      return os.getenv "SSH_CLIENT" == nil
    end,
  }

  use { "folke/todo-comments.nvim" }
  -- Lua
  use {
    "folke/twilight.nvim",
  }

  use "norcalli/nvim-colorizer.lua"
  -- update to latest version
  use { "lukas-reineke/indent-blankline.nvim", tag="v2.20.8" }

  use { "akinsho/bufferline.nvim", tag = "v3.*", requires = "nvim-tree/nvim-web-devicons" }

  use "nvim-treesitter/nvim-treesitter-refactor"

  use "nvim-tree/nvim-tree.lua"
  use "ellisonleao/gruvbox.nvim"

  use "HiPhish/rainbow-delimiters.nvim"
  use "github/copilot.vim"
  use "LiadOz/nvim-dap-repl-highlights"

  -- use "folke/flash.nvim"

  pcall(require, "impatient")
  if packer_bootstrap then
    require("packer").sync()
  end
end)
