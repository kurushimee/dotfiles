vim.g.catppuccin_flavour = "mocha"

require("catppuccin").setup({
  integrations = {
    treesitter = true,
    native_lsp = { enabled = true },
    cmp = true,
    gitgutter = true,
    gitsigns = true,
    telescope = true,
    dashboard = true
  }
})

vim.cmd [[colorscheme catppuccin]]

local ctp_feline = require('catppuccin.groups.integrations.feline')

ctp_feline.setup({})

require("feline").setup({
	components = ctp_feline.get(),
})
