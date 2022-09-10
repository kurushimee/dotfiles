local lspconfig = require("lspconfig")
local caps = vim.lsp.protocol.make_client_capabilities()
caps = require("cmp_nvim_lsp").update_capabilities(caps)
---@diagnostic disable-next-line: unused-local
local no_format = function(client, bufnr)
	client.resolved_capabilities.document_formatting = false
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
