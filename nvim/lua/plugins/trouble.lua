return {
    "folke/trouble.nvim",
    config = function()
        vim.keymap.set("n", "<leader>tq", "<cmd>TroubleToggle quickfix<cr>", { silent = true, noremap = true })
    end,
}
