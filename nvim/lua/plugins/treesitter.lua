return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = { "nvim-treesitter/nvim-treesitter-context" },
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		ensure_installed = {
			"bash",
			"help",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"query",
			"regex",
		},
		sync_install = false,
		auto_install = true,
		highlight = { enable = true },
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
