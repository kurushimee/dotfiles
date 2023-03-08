return {
    "tpope/vim-fugitive",
    config = function()
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

        local iver_Fugitive = vim.api.nvim_create_augroup("iver_Fugitive", {})

        local autocmd = vim.api.nvim_create_autocmd
        autocmd("BufWinEnter", {
            group = iver_Fugitive,
            pattern = "*",
            callback = function()
                if vim.bo.ft ~= "fugitive" then
                    return
                end

                local bufnr = vim.api.nvim_get_current_buf()
                local opts = { buffer = bufnr, remap = false }
                vim.keymap.set("n", "<leader>gp", function()
                    vim.cmd.Git("push")
                end, opts)

                -- rebase always
                vim.keymap.set("n", "<leader>gr", function()
                    vim.cmd.Git({ "pull", "--rebase" })
                end, opts)

                -- NOTE: It allows me to easily set the branch I am pushing and any tracking
                -- needed if I did not set the branch up correctly
                vim.keymap.set("n", "<leader>go", ":Git push -u origin ", opts)
            end,
        })
    end,
}
