local M = {}

M.swenv = {
	n = {
		["<leader>pv"] = {
			function()
				require("swenv.api").pick_venv()
			end,
			"pick venv",
		},
	},
}

return M
