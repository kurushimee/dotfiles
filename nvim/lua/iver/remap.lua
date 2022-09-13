local nnoremap = require("iver.keymap").nnoremap
local inoremap = require("iver.keymap").inoremap
local tnoremap = require("iver.keymap").tnoremap

-- Neotree
nnoremap("<leader>pv", "<cmd>Neotree toggle<cr>")

-- Maximizer
nnoremap("<leader>m", "<cmd>MaximizerToggle!<cr>")

-- FTerm
nnoremap("<c-q>", "<cmd>FTermToggle<cr>")
inoremap("<c-q>", "<cmd>FTermToggle<cr>")
tnoremap("<c-q>", "<c-\\><c-n><cmd>FTermToggle<cr>")

-- Telescope
nnoremap("<leader>tf", "<cmd>Telescope find_files<cr>")
nnoremap("<leader>tl", "<cmd>Telescope live_grep<cr>")

-- Git
nnoremap("<leader>Ga", "<cmd>G add .<cr>")
nnoremap("<leader>Gc", "<cmd>G commit<cr>")
nnoremap("<leader>Gp", "<cmd>G push<cr>")
nnoremap("<leader>Gd", "<cmd>G pull<cr>")

-- Color Picker
nnoremap("<c-c>", "<cmd>PickColor<cr>")
inoremap("<c-c>", "<cmd>PickColorInsert<cr>")
