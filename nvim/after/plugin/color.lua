vim.cmd([[colorscheme nord]])

require("indent_blankline").setup()
require("lualine").setup({
	options = {
		theme = "nord",
	},
})
