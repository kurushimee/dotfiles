local M = {}

local function button(sc, txt, keybind)
	local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")

	local opts = {
		position = "center",
		text = txt,
		shortcut = sc,
		cursor = 5,
		width = 36,
		align_shortcut = "right",
		hl = "AlphaButtons",
	}

	if keybind then
		opts.keymap = { "n", sc_, keybind, { noremap = true, silent = true } }
	end

	return {
		type = "button",
		val = txt,
		on_press = function()
			local key = vim.api.nvim_replace_termcodes(sc_, true, false, true) or ""
			vim.api.nvim_feedkeys(key, "normal", false)
		end,
		opts = opts,
	}
end

M.telescope = {
	extensions_list = { "themes", "terms", "projects" },
}

M.alpha = {
	buttons = {
		val = {
			button("SPC f f", "  Find File  ", ":Telescope find_files<CR>"),
			button("SPC f o", "  Recent File  ", ":Telescope oldfiles<CR>"),
			button("SPC f p", "  Recent Projects  ", ":Telescope projects<CR>"),
			button("SPC f w", "  Find Word  ", ":Telescope live_grep<CR>"),
			button("SPC b m", "  Bookmarks  ", ":Telescope marks<CR>"),
			button("SPC t h", "  Themes  ", ":Telescope themes<CR>"),
			button("SPC e s", "  Settings", ":e $MYVIMRC | :cd %:p:h <CR>"),
		},
	},
	headerPaddingTop = { type = "padding", val = 2 },
}

M.cmp = {
	sources = {
		{ name = "luasnip" },
		{ name = "nvim_lsp" },
		{ name = "buffer" },
		{ name = "nvim_lua" },
		{ name = "path" },
		{ name = "treesitter" },
	},
}

M.treesitter = {
	ensure_installed = {
		"lua",
	},
	indent = {
		enable = true,
		disable = { "python" },
	},
	yati = { enable = true },
}

M.mason = {
	ensure_installed = {
		-- lua stuff
		"lua-language-server",
		"stylua",
	},
}

-- git support in nvimtree
M.nvimtree = {
	git = {
		enable = true,
	},

	renderer = {
		highlight_git = true,
		icons = {
			show = {
				git = true,
			},
		},
	},
}

M.nvterm = {
	terminals = {
		shell = "pwsh.exe",
	},
}

return M
