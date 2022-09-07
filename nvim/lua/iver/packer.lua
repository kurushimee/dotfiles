-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
	-- Plugin manager
	use("wbthomason/packer.nvim")

	-- Completion
	use("ray-x/cmp-treesitter")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-path")
	use("hrsh7th/nvim-cmp")

	-- Snippets
	use({ "L3MON4D3/LuaSnip", run = "make install_jsregexp" })
	use("saadparwaiz1/cmp_luasnip")

	-- Formatting
	use("jose-elias-alvarez/null-ls.nvim")

	-- Language server
	use("neovim/nvim-lspconfig")
	use({ "williamboman/mason-lspconfig.nvim", requires = { "williamboman/mason.nvim" } })
	use({ "onsails/lspkind-nvim", requires = { "kyazdani42/nvim-web-devicons" } })
	use({
		"CosmicNvim/cosmic-ui",
		requires = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
		config = function()
			require("cosmic-ui").setup()
		end,
	})
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup()
		end,
	})

	-- Debugger
	use("mfussenegger/nvim-dap")

	-- Python
	use({
		"smzm/hydrovim",
		requires = { "MunifTanjim/nui.nvim" },
	})

	-- Flutter
	use({
		"akinsho/flutter-tools.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("flutter-tools").setup()
		end,
	})

	-- Syntax parser
	use({
		"nvim-treesitter/nvim-treesitter",
		run = function()
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
	})

	-- Utilities
	use("numToStr/FTerm.nvim")
	use("jiangmiao/auto-pairs")
	use({
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	})
	use("NvChad/nvim-colorizer.lua")
	use("tpope/vim-commentary")
	use("NMAC427/guess-indent.nvim")
	use({
		"max397574/better-escape.nvim",
		config = function()
			require("better_escape").setup({
				mapping = { "jj" },
			})
		end,
	})
	use({
		"ziontee113/color-picker.nvim",
		config = function()
			require("color-picker")
		end,
	})
	use({
		"kylechui/nvim-surround",
		tag = "*",
		config = function()
			require("nvim-surround").setup()
		end,
	})

	-- Git
	use("mhinz/vim-signify")
	use("lewis6991/gitsigns.nvim")
	use("tpope/vim-fugitive")

	-- File browsing
	use("junegunn/fzf")
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.0",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use({
		"ahmedkhalf/project.nvim",
		config = function()
			require("project_nvim").setup({})
		end,
	})

	-- Interface
	use({ "nvim-neo-tree/neo-tree.nvim", branch = "v2.x" })
	use("feline-nvim/feline.nvim")
	use("glepnir/dashboard-nvim")
	use("yamatsum/nvim-cursorline")
	use("lukas-reineke/indent-blankline.nvim")
	use("szw/vim-maximizer")

	-- Color scheme
	use({ "catppuccin/nvim", as = "catppuccin" })

	-- Miscellaneous
	use("andweeb/presence.nvim")
	use("vimwiki/vimwiki")
end)
