return {
	"tpope/vim-fugitive",
	dependencies = { "tpope/vim-rhubarb" },
	config = function()
		vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Show git status" })
		vim.keymap.set("n", "<leader>gc", ":Git commit -a", { desc = "Commit all local changes" })
		vim.keymap.set("n", "<leader>gp", ":Git push", { desc = "Push changes to origin" })
	end,
}
