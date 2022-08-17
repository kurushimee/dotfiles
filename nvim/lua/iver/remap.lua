local nnoremap = require("iver.keymap").nnoremap
local FTermToggle = require("iver.keymap").FTermToggle
local FTermExit = require("iver.keymap").FTermExit

nnoremap("<leader>pv", "<cmd>Ex<CR>")
nnoremap("<leader>tt", "<cmd>FTermToggle<CR>")
nnoremap("<leader>td", "<cmd>FTermExit<CR>")
