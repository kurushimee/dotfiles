local lspconfig = require'lspconfig'

local pid = vim.fn.getpid()
local omnisharp_bin = "/home/iver/Documents/omnisharp/OmniSharp.exe"

require("lsp-format").setup {}

vim.cmd 'autocmd FileType cs setlocal tabstop=4 softtabstop=4 shiftwidth=4'
lspconfig.omnisharp.setup {
    cmd = { "mono", omnisharp_bin, "--languageserver" , "--hostPID", tostring(pid) },
    on_attach = require "lsp-format".on_attach
}

require("mason").setup()
require("mason-lspconfig").setup()

require('lspkind').init({
    -- defines how annotations are shown
    -- default: symbol
    -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
    mode = 'symbol_text',

    -- default symbol map
    -- can be either 'default' or
    -- 'codicons' for codicon preset (requires vscode-codicons font installed)
    --
    -- default: 'default'
    preset = 'codicons',

    -- override preset symbols
    --
    -- default: {}
    symbol_map = {
      Text = '',
      Method = 'ƒ',
      Function = '',
      Constructor = '',
      Variable = '',
      Class = '',
      Interface = 'ﰮ',
      Module = '',
      Property = '',
      Unit = '',
      Value = '',
      Enum = '了',
      Keyword = '',
      Snippet = '﬌',
      Color = '',
      File = '',
      Folder = '',
      EnumMember = '',
      Constant = '',
      Struct = ''
    },
})
