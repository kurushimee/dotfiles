local set = vim.opt

set.number = true
set.relativenumber = true
set.autoindent = true
set.smartindent = true
set.tabstop = 2
set.softtabstop = 2
set.shiftwidth = 2
set.expandtab = true
set.smarttab = true
set.hlsearch = false
set.incsearch = true
set.termguicolors = true
set.foldexpr = "nvim_treesitter#foldexpr()"
set.foldmethod = "manual"
set.hidden = true
set.inccommand = "split"
set.mouse = "a"
set.splitbelow = true
set.splitright = true
set.swapfile = false
set.title = true
set.wildmenu = true
set.wrap = true
set.completeopt = "noinsert,menuone,noselect"

vim.g.mapleader = " "
vim.cmd([[
  filetype plugin indent on
  syntax on
]])
