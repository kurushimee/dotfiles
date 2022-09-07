-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Completion
  use 'hrsh7th/cmp-buffer'

  use { 'catppuccin/nvim', as = 'catppuccin' }
  use {
    'CosmicNvim/cosmic-ui',
    requires = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' },
    config = function()
      require('cosmic-ui').setup()
    end
  }

  use {
    'smzm/hydrovim',
    requires = { 'MunifTanjim/nui.nvim' }
  }
  use {
    'akinsho/flutter-tools.nvim',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      require("flutter-tools").setup()
    end
  }
  use 'mfussenegger/nvim-dap'
  use 'neovim/nvim-lspconfig'
  use 'jose-elias-alvarez/null-ls.nvim'
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'lukas-reineke/lsp-format.nvim'
  use { "L3MON4D3/LuaSnip", run = "make install_jsregexp" }
  use 'saadparwaiz1/cmp_luasnip'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-path'
  use 'ray-x/cmp-treesitter'
  use 'hrsh7th/nvim-cmp'
  use 'onsails/lspkind-nvim'
  use 'NvChad/nvim-colorizer.lua'
  use({ 'ziontee113/color-picker.nvim',
    config = function()
      require('color-picker')
    end,
  })
  use {
    'yamatsum/nvim-cursorline',
    config = function()
      require('nvim-cursorline').setup {
        cursorline = {
          enable = true,
          timeout = 100,
          number = true,
        },
        cursorword = { enable = true }
      }
    end
  }
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup {}
    end
  }

  use 'tpope/vim-dispatch'
  use 'tpope/vim-commentary'
  use { 'Shougo/vimproc.vim', run = 'make' }
  use {
    'w0rp/ale',
    ft = { 'sh', 'zsh', 'bash', 'c', 'cpp', 'cmake', 'html', 'markdown', 'racket', 'vim', 'tex' },
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
  use 'lukas-reineke/indent-blankline.nvim'
  use 'numToStr/FTerm.nvim'
  use 'kyazdani42/nvim-web-devicons'
  use 'lewis6991/gitsigns.nvim'
  use 'feline-nvim/feline.nvim'
  use 'glepnir/dashboard-nvim'
  use 'andweeb/presence.nvim'
  use 'NMAC427/guess-indent.nvim'
  use 'jiangmiao/auto-pairs'
  use {
    'windwp/nvim-ts-autotag',
    config = function()
      require('nvim-ts-autotag').setup()
    end
  }
  use {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup {}
    end
  }
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.0',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }
  use {
    'max397574/better-escape.nvim',
    config = function()
      require('better_escape').setup {
        mapping = { "jj" }
      }
    end
  }
  use 'szw/vim-maximizer'
  use 'tpope/vim-fugitive'
  use 'airblade/vim-gitgutter'
  use 'vimwiki/vimwiki'
end)
