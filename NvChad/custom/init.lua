local autocmd = vim.api.nvim_create_autocmd

autocmd("BufWritePre", {
	pattern = "*",
	command = "lua vim.lsp.buf.formatting_sync()",
})
