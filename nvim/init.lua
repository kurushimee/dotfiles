-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Show numbers and show them relative
vim.wo.number = true
vim.o.rnu = true

-- Enable break indent
vim.o.breakindent = true
-- Fix tab indentation
vim.o.shiftwidth = 4
vim.o.tabstop = 4

-- Set highlight on search
vim.o.hlsearch = false
-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time. If in this many ms nothing is typed the swap file will be written to disk
vim.o.updatetime = 250
-- Decrease time in ms for a mapped sequence to complete
vim.o.timeoutlen = 300

-- Enable 24-bit RGB color in the terminal ui
vim.o.termguicolors = true

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- Keep signcolumn on by default, otherwise on startup, gitsigns will turn it on
vim.wo.signcolumn = "yes"

-- Show tab characters and trailing crap
vim.o.list = true
vim.o.listchars = "trail:~,tab:> ,nbsp:␣"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Remap so jk work better with lines that are wrapped
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- Editor colorscheme
		{
			"catppuccin/nvim",
			name = "catppuccin",
			priority = 1000,
			config = function()
				vim.cmd.colorscheme("catppuccin")
			end,
		},

		-- Detect tabstop and shiftwidth automatically
		{ "tpope/vim-sleuth" },

		-- "gc" to comment visual regions/lines
		{ "numToStr/Comment.nvim", opts = {} },

		-- git signs
		{
			"lewis6991/gitsigns.nvim",
			opts = {
				signs = {
					add = { text = "+" },
					change = { text = "~" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
				on_attach = function(bufnr)
					vim.keymap.set(
						"n",
						"<leader>hp",
						require("gitsigns").preview_hunk,
						{ buffer = bufnr, desc = "Preview git hunk" }
					)
				end,
			},
		},

		-- telescope
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		{
			"nvim-telescope/telescope.nvim",
			tag = "0.1.8",
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function()
				-- Enable telescope fzf native
				require("telescope").load_extension("fzf")
			end,
		},

		-- treesitter
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			dependencies = {
				"nvim-treesitter/nvim-treesitter-textobjects",
			},
		},

		-- lualine
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			opts = {
				options = {
					theme = "catppuccin",
				},
			},
		},

		-- Neovim LSP
		{
			"neovim/nvim-lspconfig",
			dependencies = {
				"williamboman/mason.nvim",
				"williamboman/mason-lspconfig.nvim",
				-- Useful status updates for LSP
				-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
				{ "j-hui/fidget.nvim", tag = "legacy", opts = {} },
			},
		},

		-- which key
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {},
		},

		{ -- Autoformat
			"stevearc/conform.nvim",
			lazy = false,
			keys = {
				{
					"<leader>f",
					function()
						require("conform").format({ async = true, lsp_fallback = true })
					end,
					mode = "",
					desc = "[F]ormat buffer",
				},
			},
			opts = {
				notify_on_error = false,
				format_on_save = function(bufnr)
					-- Disable "format_on_save lsp_fallback" for languages that don't
					-- have a well standardized coding style. You can add additional
					-- languages here or re-enable it for the disabled ones.
					local disable_filetypes = { c = true, cpp = false }
					return {
						timeout_ms = 1000,
						lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
					}
				end,
				formatters_by_ft = {
					lua = { "stylua" },
					gdscript = { "gdformat" },
					-- Conform can also run multiple formatters sequentially
					-- python = { "isort", "black" },
					--
					-- You can use a sub-list to tell conform to run *until* a formatter
					-- is found.
					-- javascript = { { "prettierd", "prettier" } },
				},
			},
		},

		-- CMP
		{
			"hrsh7th/nvim-cmp",
			dependencies = {
				-- Adds LSP completion capabilities
				"hrsh7th/cmp-nvim-lsp",
				{ "L3MON4D3/LuaSnip", opts = {} },
			},
		},
		-- Codeium
		{
			"Exafunction/codeium.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"hrsh7th/nvim-cmp",
			},
			opts = {},
		},

		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			-- Optional dependency
			dependencies = { "hrsh7th/nvim-cmp" },
			config = function()
				require("nvim-autopairs").setup({})
				-- If you want to automatically add `(` after selecting a function or method
				local cmp_autopairs = require("nvim-autopairs.completion.cmp")
				local cmp = require("cmp")
				cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
			end,
		},

		-- DAP
		{
			"mfussenegger/nvim-dap",
			dependencies = {
				"rcarriga/nvim-dap-ui",
				dependencies = {
					-- Required dependency for nvim-dap-ui
					"nvim-neotest/nvim-nio",
				},
			},
		},

		-- Linting
		{
			"mfussenegger/nvim-lint",
			event = { "BufReadPre", "BufNewFile" },
			config = function()
				local lint = require("lint")
				lint.linters_by_ft = {
					lua = { "luacheck" },
					gdscript = { "gdlint" },
				}
				lint.linters.luacheck.args = {
					"--globals",
					"vim",
					"--",
				}

				local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
				vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
					group = lint_augroup,
					callback = function()
						require("lint").try_lint()
					end,
				})
			end,
		},
	},

	-- colorscheme that will be used when installing plugins
	install = { colorscheme = { "catppuccin" } },

	-- automatically check for plugin updates
	checker = { enabled = true },
})

-- telescope keymaps
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
-- Shortcut for searching your Neovim configuration files
vim.keymap.set("n", "<leader>sn", function()
	builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
	-- Use the current buffer's path as the starting point for the git search
	local current_file = vim.api.nvim_buf_get_name(0)
	local current_dir
	local cwd = vim.fn.getcwd()
	-- If the buffer is not associated with a file, return nil
	if current_file == "" then
		current_dir = cwd
	else
		-- Extract the directory from the current file's path
		current_dir = vim.fn.fnamemodify(current_file, ":h")
	end

	-- Find the Git root directory from the current file's path
	local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
	if vim.v.shell_error ~= 0 then
		print("Not a git repository. Searching on current working directory")
		return cwd
	end
	return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
	local git_root = find_git_root()
	if git_root then
		require("telescope.builtin").live_grep({
			search_dirs = { git_root },
		})
	end
end
vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})
vim.keymap.set("n", "<leader>sG", ":LiveGrepGitRoot<cr>", { desc = "[S]earch by [G]rep on Git Root" })

vim.keymap.set("n", "<leader><space>", builtin.buffers, { desc = "[ ] Find existing buffers" })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
	-- NOTE: Remember that lua is a real programming language, and as such it is possible
	-- to define small helper and utility functions so you don't have to repeat yourself
	-- many times.
	--
	-- In this case, we create a function that lets us more easily define mappings specific
	-- for LSP related items. It sets the mode, buffer and description for us each time.
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

	nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
	nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	nmap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
	nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
	nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
	nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

	-- See `:help K` for why this keymap
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

	-- Lesser used LSP functionality
	nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		vim.lsp.buf.format()
	end, { desc = "Format current buffer with LSP" })
end

-- Enable the following language servers
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
	clangd = {},
	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
			diagnostics = { globals = { "vim" } },
		},
	},
}

-- Setup Godot LSP separately
require("lspconfig").gdscript.setup({
	cmd = { "godot-wsl-lsp" },
})

-- Ensure the servers above are installed
local mason_lspconfig = require("mason-lspconfig")

require("mason").setup()
mason_lspconfig.setup({
	ensure_installed = vim.tbl_keys(servers),
})

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

mason_lspconfig.setup_handlers({
	function(server_name)
		require("lspconfig")[server_name].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers[server_name],
			filetypes = (servers[server_name] or {}).filetypes,
		})
	end,
})

-- Configure nvim-cmp
-- See `:help cmp`
local cmp = require("cmp")
-- luasnip is setup in the lazy dependency line

cmp.setup({
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	completion = {
		completeopt = "menu,menuone,noinsert",
	},
	mapping = cmp.mapping.preset.insert({
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
		["<C-f>"] = cmp.mapping.scroll_docs(-4),
		["<C-y>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Insert, -- Move adjacent text to the right
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }), -- {'i', 's'} Specifies the modes this mapping should be active in. Insert and Select
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "codeium" },
	},
})

-- Configure Treesitter
-- Defer setup after first render to improve startup time of 'nvim $filename'
vim.defer_fn(function()
	require("nvim-treesitter.configs").setup({
		-- Add languages to be installed here that you want installed for treesitter
		ensure_installed = { "c", "lua", "vim", "vimdoc", "gdscript", "godot_resource" },
		sync_install = false,

		highlight = { enable = true },
		-- Indent with the "=" operator
		indent = { enable = true },

		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<C-space>",
				node_incremental = "<C-space>",
				scope_incremental = "<C-s>",
				node_decremental = "<M-space>", -- Alt+space, might have to disable the Ubuntu hot key for this
			},
		},

		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- Automatically jump forward to the relevant textobj, like a function
				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					["aa"] = "@parameter.outer",
					["ia"] = "@parameter.inner",
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
				},
			},
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				-- Go to the next function or class start and end
				goto_next_start = {
					["]m"] = "@function.outer",
					["]]"] = "@class.outer",
				},
				goto_next_end = {
					["]M"] = "@function.outer",
					["]["] = "@class.outer",
				},
				-- Go to the previous function or class start and end
				goto_previous_start = {
					["[m"] = "@function.outer",
					["[["] = "@class.outer",
				},
				goto_previous_end = {
					["[M"] = "@function.outer",
					["[]"] = "@class.outer",
				},
			},
			swap = {
				enable = true,
				swap_next = {
					["<leader>a"] = "@parameter.inner",
				},
				swap_previous = {
					["<leader>A"] = "@parameter.inner",
				},
			},
		},
	})
end, 0)

-- nvim-dap config
local dap = require("dap")
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
vim.keymap.set("n", "<F12>", dap.continue, { desc = "Debug: Start/Continue" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F8>", dap.terminate, { desc = "Debug: Terminate" })

dap.adapters.godot = {
	type = "server",
	host = "localhost",
	port = 6006,
}

dap.configurations.gdscript = {
	{
		type = "godot",
		request = "launch", -- either "launch" or "attach"
		name = "Launch Main Scene",
		-- specific to gdscript
		project = "${workspaceFolder}",
	},
}

local dapui = require("dapui")
dapui.setup({
	-- Set icons to characters that are more likely to work in every terminal.
	--    Feel free to remove or use ones that you like more! :)
	--    Don't feel like these are good choices.
	icons = { expanded = "â–¾", collapsed = "â–¸", current_frame = "*" },
	controls = {
		icons = {
			pause = "â¸",
			play = "â–¶",
			step_into = "âŽ",
			step_over = "â­",
			step_out = "â®",
			step_back = "b",
			run_last = "â–¶â–¶",
			terminate = "â¹",
			disconnect = "â",
		},
	},
})

-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
vim.keymap.set("n", "<F7>", dapui.toggle, { desc = "Debug: See last session result." })

dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

-- Enable neovim to be the external editor for Godot, if the cwd has a project.godot file
if vim.fn.filereadable(vim.fn.getcwd() .. "/project.godot") == 1 then
	local addr = "/tmp/godot.pipe"
	vim.fn.serverstart(addr)
end
