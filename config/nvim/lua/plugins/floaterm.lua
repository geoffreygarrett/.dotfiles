return {
    "voldikss/vim-floaterm",
    config = function()
        vim.api.nvim_set_keymap('n', '<leader>ft',
            ":FloatermNew --name=myfloat --height=0.8 --width=0.7 --autoclose=2<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', 't', ":FloatermToggle myfloat<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('t', '<Esc>', "<C-\\><C-n>:q<CR>", { noremap = true, silent = true })
    end,
}
