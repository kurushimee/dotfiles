local M = {}

local userPlugins = require "custom.plugins"
M.plugins = {
   user = userPlugins,
   override = {
      ["hrsh7th/nvim-cmp"] = {
        sources = {
          { name = 'cmp_tabnine' }
       }
     }
   }
}

return M
