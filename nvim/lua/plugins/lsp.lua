local BufLoad = { "BufReadPre", "BufNewFile" }

return {
	"VonHeikemen/lsp-zero.nvim",
	event = BufLoad,
	dependencies = {
		-- LSP Support
		{ "neovim/nvim-lspconfig", event = BufLoad },
		{ "williamboman/mason.nvim", event = BufLoad },
		{ "williamboman/mason-lspconfig.nvim", event = BufLoad },

		-- Autocompletion
		{ "hrsh7th/nvim-cmp", event = "InsertEnter" },
		{ "hrsh7th/cmp-buffer", event = "InsertEnter" },
		{ "hrsh7th/cmp-path", event = "InsertEnter" },
		{ "saadparwaiz1/cmp_luasnip", event = "InsertEnter" },
		{ "hrsh7th/cmp-nvim-lsp", event = "InsertEnter" },
		{ "hrsh7th/cmp-nvim-lua", event = "InsertEnter" },

		-- Snippets
		{ "L3MON4D3/LuaSnip", event = "InsertEnter" },
		{ "rafamadriz/friendly-snippets", event = "InsertEnter" },
	},
	config = function()
		local lsp = require("lsp-zero")

		lsp.preset("recommended")

		lsp.ensure_installed({
			"lua_ls",
		})

		-- Fix Undefined global 'vim'
		lsp.configure("lua_ls", {
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
				},
			},
		})

		local cmp = require("cmp")
		local cmp_select = { behavior = cmp.SelectBehavior.Select }
		local cmp_mappings = lsp.defaults.cmp_mappings({
			["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
			["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
			["<Enter>"] = cmp.mapping.confirm({ select = true }),
			["<C-Space>"] = cmp.mapping.complete(),
		})

		cmp_mappings["<Tab>"] = nil
		cmp_mappings["<S-Tab>"] = nil

		lsp.setup_nvim_cmp({
			mapping = cmp_mappings,
		})

		lsp.set_preferences({
			suggest_lsp_servers = false,
		})

		lsp.on_attach(function(client, bufnr)
			local opts = { buffer = bufnr, remap = false }

			vim.keymap.set("n", "gd", function()
				vim.lsp.buf.definition()
			end, opts)
			vim.keymap.set("n", "K", function()
				vim.lsp.buf.hover()
			end, opts)
			vim.keymap.set("n", "<leader>vws", function()
				vim.lsp.buf.workspace_symbol()
			end, opts)
			vim.keymap.set("n", "<leader>vd", function()
				vim.diagnostic.open_float()
			end, opts)
			vim.keymap.set("n", "[d", function()
				vim.diagnostic.goto_next()
			end, opts)
			vim.keymap.set("n", "]d", function()
				vim.diagnostic.goto_prev()
			end, opts)
			vim.keymap.set("n", "<leader>vca", function()
				vim.lsp.buf.code_action()
			end, opts)
			vim.keymap.set("n", "<leader>vrr", function()
				vim.lsp.buf.references()
			end, opts)
			vim.keymap.set("n", "<leader>vrn", function()
				vim.lsp.buf.rename()
			end, opts)
			vim.keymap.set("i", "<C-h>", function()
				vim.lsp.buf.signature_help()
			end, opts)
		end)

		lsp.setup()

		vim.diagnostic.config({
			virtual_text = true,
		})
	end,
}
