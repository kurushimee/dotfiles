local nnoremap = require("iver.keymap").nnoremap
local vnoremap = require("iver.keymap").vnoremap
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
nnoremap("<leader>Gp", "<cmd>G push")

-- Cosmic-UI
nnoremap("gn", '<cmd>lua require("cosmic-ui").rename()<cr>')
nnoremap("<leader>ga", '<cmd>lua require("cosmic-ui").code_actions()<cr>')
vnoremap("<leader>ga", '<cmd>lua require("cosmic-ui").range_code_actions()<cr>')

-- Language server
nnoremap("<leader>tt", "<cmd>TroubleToggle<cr>")
nnoremap("gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")
nnoremap("gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
nnoremap("K", "<cmd>lua vim.lsp.buf.hover()<cr>")
nnoremap("gi", "<cmd>lua vim.lsp.buf.implementation()<cr>")
nnoremap("<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
nnoremap("gr", "<cmd>lua vim.lsp.buf.references()<cr>")
nnoremap("<leader>f", "<cmd>lua vim.lsp.buf.formatting()<cr>")

-- Color Picker
nnoremap("<c-c>", "<cmd>PickColor<cr>")
inoremap("<c-c>", "<cmd>PickColorInsert<cr>")
