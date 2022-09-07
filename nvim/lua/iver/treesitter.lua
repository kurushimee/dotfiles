require 'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },
  indent = { enable = true },
  autotag = {
    enable = true,
    filetypes = {
      "html",
      "xml"
    }
  }
}

require 'colorizer'.setup {
  filetypes = {
    'css',
    'html'
  }
}
