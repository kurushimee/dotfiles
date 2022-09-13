require("nvim-treesitter.configs").setup({
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = true,
	},
	indent = { enable = true, disable = { "python" } },
	autotag = {
		enable = true,
		filetypes = {
			"html",
			"xml",
		},
	},
})

require("colorizer").setup({
	filetypes = {
		"css",
		"html",
	},
})
