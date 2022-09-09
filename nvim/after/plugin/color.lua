vim.g.catppuccin_flavour = "mocha"

-- require("catppuccin").setup({
-- 	integrations = {
-- treesitter = true,
-- native_lsp = { enabled = true },
-- cmp = true,
-- gitgutter = true,
-- gitsigns = true,
-- telescope = true,
-- indent_blankline = { enabled = true },
-- dashboard = true,
-- },
-- })
require("nightfox").setup({
	modules = {
		cmp = true,
		dashboard = true,
		gitsigns = true,
		lsp_trouble = true,
		native_lsp = true,
		neotree = true,
		telescope = true,
		treesitter = true,
	},
})

-- vim.cmd [[colorscheme catppuccin]]
vim.cmd([[colorscheme carbonfox]])

-- local ctp_feline = require("catppuccin.groups.integrations.feline")

-- ctp_feline.setup({})

-- require("feline").setup({
-- components = ctp_feline.get(),
-- })

vim.cmd([[highlight IndentBlanklineIndent1 guibg=#1f1f1f gui=nocombine]])
vim.cmd([[highlight IndentBlanklineIndent2 guibg=#1a1a1a gui=nocombine]])

require("indent_blankline").setup({
	char = "",
	char_highlight_list = {
		"IndentBlanklineIndent1",
		"IndentBlanklineIndent2",
	},
	space_char_highlight_list = {
		"IndentBlanklineIndent1",
		"IndentBlanklineIndent2",
	},
	show_trailing_blankline_indent = false,
})
