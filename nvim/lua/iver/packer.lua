-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {'catppuccin/nvim', as = 'catppuccin'}
  use {
    'CosmicNvim/cosmic-ui',
    requires = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' },
    config = function()
      require('cosmic-ui').setup()
    end
  }
  use {'neoclide/coc.nvim', branch = 'release'}
  use 'OmniSharp/omnisharp-vim'
  use 'tpope/vim-dispatch'
  use 'tpope/vim-commentary'
  use {'Shougo/vimproc.vim', run = 'make'}
  use {
    'w0rp/ale',
    ft = {'sh', 'zsh', 'bash', 'c', 'cpp', 'cmake', 'html', 'markdown', 'racket', 'vim', 'tex'},
    cmd = 'ALEEnable',
    config = 'vim.cmd[[ALEEnable]]'
  }
  use 'junegunn/fzf'
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end
  }
  use {
    "kylechui/nvim-surround",
    tag = "*",
    config = function()
      require("nvim-surround").setup({})
    end
  }
  use 'numToStr/FTerm.nvim'
  use 'sunjon/shade.nvim'
  use 'kyazdani42/nvim-web-devicons'
  use 'lewis6991/gitsigns.nvim'
  use 'feline-nvim/feline.nvim'
  use 'glepnir/dashboard-nvim'
  use 'andweeb/presence.nvim'
  use {'ZhiyuanLck/smart-pairs', event = 'InsertEnter', config = function() require('pairs'):setup() end}
  use {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup {}
    end
  }
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.0',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {
    'max397574/better-escape.nvim',
    config = function()
      require('better_escape').setup {
        mapping = {"jj"}
      }
    end
  }
  use 'szw/vim-maximizer'
  use 'tpope/vim-fugitive'
  use 'airblade/vim-gitgutter'
end)
