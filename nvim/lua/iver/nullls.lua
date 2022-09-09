---@diagnostic disable-next-line: unused-local
local diagnostics = require("null-ls").builtins.diagnostics

local formatting = require("null-ls").builtins.formatting
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local code_actions = require("null-ls").builtins.code_actions

require("null-ls").setup({
	sources = {
		code_actions.gitsigns,
		code_actions.refactoring,

		formatting.prettier,
		formatting.stylua,
		formatting.uncrustify,
	},
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				callback = function()
					vim.lsp.buf.formatting_sync()
				end,
			})
		end
	end,
})

vim.cmd([[ autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync() ]])
