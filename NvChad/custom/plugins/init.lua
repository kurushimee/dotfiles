local overrides = require "custom.plugins.overrides"

return {
  ["nvim-telescope/telescope.nvim"] = {
    override_options = overrides.telescope
  },

  ["goolord/alpha-nvim"] = {
    disable = false,
    override_options = overrides.alpha
  },

  ["neovim/nvim-lspconfig"] = {
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.plugins.lspconfig"
    end,
  },

  ["ray-x/cmp-treesitter"] = {},
  ["hrsh7th/cmp-cmdline"] = {},
  ["hrsh7th/nvim-cmp"] = {
    override_options = overrides.cmp,
    config = function()
      require "plugins.configs.cmp"
      require "custom.plugins.cmp"
    end,
  },

  ["nvim-treesitter/nvim-treesitter"] = {
    override_options = overrides.treesitter,
  },

  ["williamboman/mason.nvim"] = {
    override_options = overrides.mason,
  },

  ["kyazdani42/nvim-tree.lua"] = {
    override_options = overrides.nvimtree,
  },

  ["jose-elias-alvarez/null-ls.nvim"] = {
    after = "nvim-lspconfig",
    config = function()
      require "custom.plugins.null-ls"
    end,
  },

  ["ahmedkhalf/project.nvim"] = {
    cmd = "Telescope project",
    config = function()
      require("project_nvim").setup()
    end
  }
}
