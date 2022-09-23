local present, null_ls = pcall(require, "null-ls")

if not present then
	return
end

local b = null_ls.builtins

local sources = {

	-- webdev stuff
	b.formatting.prettier.with({ filetypes = { "html", "markdown", "css" } }),

	-- Lua
	b.formatting.stylua,

	-- Python
	b.formatting.isort,
	b.formatting.black.with({ extra_args = { "--line-length", "79" } }),
	b.diagnostics.flake8,

	-- C#
	b.formatting.csharpier,

	-- Shell
	b.formatting.shfmt,
	b.diagnostics.shellcheck.with({ diagnostics_format = "#{m} [#{c}]" }),
}

null_ls.setup({
	sources = sources,
})