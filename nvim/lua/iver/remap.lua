local nnoremap = require("iver.keymap").nnoremap
local vnoremap = require("iver.keymap").vnoremap
local inoremap = require("iver.keymap").inoremap
local tnoremap = require("iver.keymap").tnoremap

-- NetRW
nnoremap("<leader>pv", "<cmd>Ex<cr>")

-- Maximizer
nnoremap("<leader>m", "<cmd>MaximizerToggle!<cr>")

-- FTerm
nnoremap("<c-q>", "<cmd>FTermToggle<cr>")
inoremap("<c-q>", "<cmd>FTermToggle<cr>")
tnoremap("<c-q>", "<c-\\><c-n><cmd>FTermToggle<cr>")

-- Cosmic-UI
nnoremap("gn", '<cmd>lua require("cosmic-ui").rename()<cr>')
nnoremap("<leader>ga", '<cmd>lua require("cosmic-ui").code_actions()<cr>')
vnoremap("<leader>ga", '<cmd>lua require("cosmic-ui").range_code_actions()<cr>')
