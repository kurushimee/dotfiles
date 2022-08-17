local nnoremap = require("iver.keymap").nnoremap
local inoremap = require("iver.keymap").inoremap
local tnoremap = require("iver.keymap").tnoremap

nnoremap("<leader>pv", "<cmd>Ex<CR>")
nnoremap("<leader>m", "<cmd>MaximizerToggle!<CR>")
nnoremap("<c-q>", "<cmd>FTermToggle<CR>")
inoremap("<c-q>", "<cmd>FTermToggle<CR>")
tnoremap("<c-q>", "<c-\\><c-n><cmd>FTermToggle<CR>")
