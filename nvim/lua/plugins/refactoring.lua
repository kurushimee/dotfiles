return {
	"ThePrimeagen/refactoring.nvim",
	config = function()
		vim.api.nvim_set_keymap(
			"v",
			"<leader>rs",
			":lua require('refactoring').select_refactor()<CR>",
			{ noremap = true, silent = true, expr = false }
		)
	end,
}
