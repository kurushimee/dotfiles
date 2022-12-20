local overrides = require("custom.plugins.overrides")

return {
	["nvim-telescope/telescope.nvim"] = {
		override_options = overrides.telescope,
	},

	["goolord/alpha-nvim"] = {
		disable = false,
		override_options = overrides.alpha,
	},

	["neovim/nvim-lspconfig"] = {
		config = function()
			require("custom.plugins.configs.lspconfig")
		end,
	},

	["ray-x/cmp-treesitter"] = { after = "cmp-cmdline" },
	["hrsh7th/cmp-cmdline"] = { after = "cmp-path" },
	["hrsh7th/nvim-cmp"] = {
		override_options = overrides.cmp,
		config = function()
			require("custom.plugins.configs.cmp")
		end,
	},

	["nvim-treesitter/nvim-treesitter"] = {
		override_options = overrides.treesitter,
	},

	["williamboman/mason.nvim"] = {
		override_options = overrides.mason,
	},

	["kyazdani42/nvim-tree.lua"] = {
		override_options = overrides.nvimtree,
	},

	["jose-elias-alvarez/null-ls.nvim"] = {
		after = "nvim-lspconfig",
		config = function()
			require("custom.plugins.configs.null-ls")
		end,
	},

	["ahmedkhalf/project.nvim"] = {
		config = function()
			require("project_nvim").setup()
		end,
	},

	["yioneko/nvim-yati"] = {
		after = "nvim-treesitter",
	},

	["windwp/nvim-autopairs"] = {
		config = function()
			require("plugins.configs.others").autopairs()
			require("custom.plugins.configs.autopairs")
		end,
	},

	["AckslD/swenv.nvim"] = {},

	["stevearc/dressing.nvim"] = {},
}
