local nvim_lsp = require'lspconfig'

local pid = vim.fn.getpid()
-- local omnisharp_bin = "/home/iver/Documents/OmniSharp/run"
local omnisharp_bin = "/home/iver/Documents/omnisharp/OmniSharp.exe"

require'lspconfig'.omnisharp.setup {
    -- cmd = { omnisharp_bin, "--languageserver" , "--hostPID", tostring(pid) };
    cmd = { "mono", omnisharp_bin, "--languageserver" , "--hostPID", tostring(pid) };
}

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
