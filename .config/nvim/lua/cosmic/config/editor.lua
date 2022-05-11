-- Override Cosmic editor options

local g = vim.g
local map = require('cosmic.utils').map
local o = vim.o
local wo = vim.wo
local opt = vim.opt

-- Set GUI font
opt.guifont = { "FiraCode NF", "h12" }

-- Enable scrolloff beyond  last line
o.scrolloff = 5
wo.scrolloff = 5
opt.scrolloff = 5
