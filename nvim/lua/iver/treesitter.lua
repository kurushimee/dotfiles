require 'nvim-treesitter.configs'.setup {
  sync_install = false,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },

  indent = { enable = true }
}

require 'colorizer'.setup {
  filetypes = {
    'css',
    'html'
  }
}
