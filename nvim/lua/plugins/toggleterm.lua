local Util = require("util")

local function toggle_term(dir)
	local args = ""
	if dir then
		args = " dir=" .. dir
	end
	vim.cmd("ToggleTerm" .. args)
end

return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		vim.keymap.set("n", "<leader>ft", function()
			toggle_term(Util.get_root())
		end, { desc = "Terminal (root dir)" })
		vim.keymap.set("n", "<leader>fT", function()
			toggle_term()
		end, { desc = "Terminal (cwd)" })
		vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })

		require("toggleterm").setup()
	end,
}
