local set = vim.opt

set.background = "dark"
set.clipboard = "unnamedplus"
set.completeopt = "noinsert,menuone,noselect"
set.scrolloff = 5
set.expandtab = true
set.smarttab = true
set.tabstop = 2
set.softtabstop = 2
set.shiftwidth = 2
set.autoindent = true
set.foldexpr = "nvim_treesitter#foldexpr()"
set.foldmethod = "manual"
set.hidden = true
set.inccommand = "split"
set.mouse = "a"
set.number = true
set.relativenumber = true
set.hlsearch = false
set.incsearch = true
set.splitbelow = true
set.splitright = true
set.swapfile = false
set.termguicolors = true
set.title = true
set.ttimeoutlen = 0
set.updatetime = 250
set.wildmenu = true
set.wrap = true

vim.g.mapleader = " "
vim.cmd([[
  filetype indent on
  syntax on
]])
