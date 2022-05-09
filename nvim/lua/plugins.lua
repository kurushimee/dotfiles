require('packer').startup(function(use)
  use {'wbthomason/packer.nvim', event = 'VimEnter'}
  use 'kyazdani42/nvim-web-devicons'
  use {'glepnir/dashboard-nvim', after = 'nvim-web-devicons'}
  use {
    'feline-nvim/feline.nvim',
    after = 'nvim-web-devicons',
    requires = 'lewis6991/gitsigns.nvim'
  }
  use {'akinsho/bufferline.nvim',  after = 'nvim-web-devicons'}
  use {'lukas-reineke/indent-blankline.nvim', event = 'BufRead'}
  use {
    'nvim-telescope/telescope.nvim',
    requires = 'nvim-lua/plenary.nvim'
  }
end)

require('feline').setup()
require("bufferline").setup{}
