local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

return require("packer").startup(function(use)
	use("wbthomason/packer.nvim")

	-- LSP
	use({ "neovim/nvim-lspconfig" })
	use({ "williamboman/mason.nvim" })
	use({ "williamboman/mason-lspconfig.nvim" })
	use({ "j-hui/fidget.nvim" })
	use({ "folke/neodev.nvim" })
	use({ "jose-elias-alvarez/null-ls.nvim" })

	-- Snippets
	use({ "L3MON4D3/LuaSnip" })
	use({ "rafamadriz/friendly-snippets" })

	-- Autocompletion
	use({ "hrsh7th/nvim-cmp" })
	use({ "hrsh7th/cmp-nvim-lsp" })
	use({ "hrsh7th/cmp-path" })
	use({ "saadparwaiz1/cmp_luasnip" })
	use({ "hrsh7th/cmp-nvim-lua" })
	use({ "hrsh7th/cmp-emoji" })

	-- Treesitter
	use({ "nvim-treesitter/nvim-treesitter", run = { ":TSUpdate" } })
	use({ -- Additional text objects via treesitter
		"nvim-treesitter/nvim-treesitter-textobjects",
	})

	-- Telescope stuff
	use({
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use({
		"nvim-telescope/telescope-fzf-native.nvim",
		requires = { "nvim-telescope/telescope.nvim" },
		run = "make",
	})
	use({ "ahmedkhalf/project.nvim" })

	-- Looks
	use("rebelot/kanagawa.nvim")
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})

	-- Navigation
	use("theprimeagen/harpoon")

	-- Git
	use("tpope/vim-fugitive")
	use("tpope/vim-rhubarb")
	use("lewis6991/gitsigns.nvim")

	-- Operators and motions
	use({ "tpope/vim-unimpaired" })
	use({
		"kylechui/nvim-surround",
	})
	use({ "numToStr/Comment.nvim" }) -- "gc" to comment visual regions/lines

	-- New commands
	-- TODO: mapping
	use({ "ojroques/vim-oscyank" })
	use("mbbill/undotree")

	-- Misc
	use({ "alec-gibson/nvim-tetris" })

	if packer_bootstrap then
		require("packer").sync()
	end
end)
