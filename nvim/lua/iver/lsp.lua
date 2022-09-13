local lspconfig = require("lspconfig")
local caps = vim.lsp.protocol.make_client_capabilities()
caps = require("cmp_nvim_lsp").update_capabilities(caps)

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<space>e", "<cmd>Lspsaga show_line_diagnostics<cr>", opts)
vim.keymap.set("n", "<space>e", "<cmd>Lspsaga show_cursor_diagnostics<cr>", opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
	vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<cr>", bufopts)
	vim.keymap.set("n", "gh", "<cmd>Lspsaga lsp_finder<cr>", bufopts)
	vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>", bufopts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
	vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
	vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
	vim.keymap.set("n", "<space>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)
	vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set("n", "<space>rn", "<cmd>Lspsaga rename<cr>", bufopts)
	vim.keymap.set("n", "<space>ca", "<cmd>Lspsaga code_action<cr>", bufopts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
	vim.keymap.set("n", "<space>f", vim.lsp.buf.formatting, bufopts)
end

local no_format = function(client, bufnr)
	client.resolved_capabilities.document_formatting = false
	on_attach(client, bufnr)
end

-- Capabilities
caps.textDocument.completion.completionItem.snippetSupport = true

-- Lua
lspconfig.sumneko_lua.setup({
	Capabilities = caps,
	on_attach = no_format,
})
-- Python
lspconfig.pyright.setup({
	Capabilities = caps,
	on_attach = on_attach,
})
-- Emmet
lspconfig.emmet_ls.setup({
	Capabilities = caps,
	filetypes = {
		"css",
		"html",
		"sass",
		"scss",
	},
	on_attach = no_format,
})
-- C#
-- local pid = vim.fn.getpid()
-- local omnisharp_bin = "/home/iver/Documents/omnisharp/OmniSharp.exe"
-- vim.cmd 'autocmd FileType cs setlocal tabstop=4 softtabstop=4 shiftwidth=4'
-- lspconfig.omnisharp.setup {
--   cmd = { "mono", omnisharp_bin, "--languageserver", "--hostPID", tostring(pid) },
--   on_attach = no_format
-- }
lspconfig.omnisharp.setup({
	Capabilities = caps,
	on_attach = no_format,
})

require("mason").setup()
require("mason-lspconfig").setup()

require("lspkind").init({
	-- defines how annotations are shown
	-- default: symbol
	-- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
	mode = "symbol_text",

	-- default symbol map
	-- can be either 'default' or
	-- 'codicons' for codicon preset (requires vscode-codicons font installed)
	--
	-- default: 'default'
	preset = "codicons",

	-- override preset symbols
	--
	-- default: {}
	symbol_map = {
		Text = "",
		Method = "ƒ",
		Function = "",
		Constructor = "",
		Variable = "",
		Class = "",
		Interface = "ﰮ",
		Module = "",
		Property = "",
		Unit = "",
		Value = "",
		Enum = "了",
		Keyword = "",
		Snippet = "﬌",
		Color = "",
		File = "",
		Folder = "",
		EnumMember = "",
		Constant = "",
		Struct = "",
	},
})
