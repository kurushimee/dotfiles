return {
	"neanias/everforest-nvim",
	priority = 1000,
	config = function()
		local everforest = require("everforest")
		everforest.setup({ background = "hard" })
		require("everforest").load()
	end,
}
