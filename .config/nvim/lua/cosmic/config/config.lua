local pid = vim.fn.getpid()
local omnisharp_bin = "/home/iver/omnisharp/"

local config = {
  lsp = {
    servers = {
      omnisharp = {
        cmd = { omnisharp_bin, "--languageserver" , "--hostPID", tostring(pid) },
        on_attach = function(client)
          require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
        end
      }
    }
  },

  nvim_cmp = {
    sources = {
      { name = 'cmp_tabnine' }
    }
  },

  add_plugins = {
    'airblade/vim-gitgutter',
    {
      'tzachar/cmp-tabnine',
      run = './install.sh',
      requires = 'hrsh7th/nvim-cmp'
    }
  }
}

return config
