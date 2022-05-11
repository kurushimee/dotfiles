-- Override Cosmic editor options

local g = vim.g
local map = require('cosmic.utils').map
local o = vim.o
local wo = vim.wo
local opt = vim.opt

-- Enable scrolloff beyond  last line
o.scrolloff = 10
wo.scrolloff = 10
opt.scrolloff = 10
