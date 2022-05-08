-- Load packer.nvim
vim.cmd("packadd packer.nvim")

return require('packer').startup(function()
  use {'wbthomason/packer.nvim', event = 'VimEnter'}
  use 'kyazdani42/nvim-web-devicons'
  use {'glepnir/dashboard-nvim', after = 'nvim-web-devicons'}
  use {'feline-nvim/feline.nvim',  after = 'nvim-web-devicons'}
  use {'akinsho/bufferline.nvim',  after = 'nvim-web-devicons'}
  use {'lukas-reineke/indent-blankline.nvim', event = 'BufRead'}
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
end)
