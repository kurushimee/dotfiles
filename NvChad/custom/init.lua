-- FONT
vim.cmd([[
set guifont=JetBrainsMono\ NF:h12
]])

-- TABNINE
-- local tabnine = require('cmp_tabnine.config')
-- tabnine:setup({
	-- max_lines = 1000;
	-- max_num_results = 5;
	-- sort = true;
	-- run_on_every_keystroke = true;
	-- snippet_placeholder = '..';
	-- show_prediction_strength = false;
-- })

-- MAPPINGS
local map = require("core.utils").map

map("n", "<leader>cc", ":Telescope <CR>")
map("n", "<leader>q", ":q <CR>")
