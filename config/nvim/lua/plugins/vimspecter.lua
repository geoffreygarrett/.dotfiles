-- ~/.config/nvim/lua/plugins/vimspector.lua

return {
    "puremourning/vimspector",
    config = function()
        -- Vimspector UI settings
        vim.g.vimspector_sidebar_width = 85
        vim.g.vimspector_bottombar_height = 15
        vim.g.vimspector_terminal_maxwidth = 70

        -- Key mappings for Vimspector
        vim.api.nvim_set_keymap('n', '<F9>', '<cmd>call vimspector#Launch()<cr>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<F5>', '<cmd>call vimspector#StepOver()<cr>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<F8>', '<cmd>call vimspector#Reset()<cr>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<F11>', '<cmd>call vimspector#StepInto()<cr>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<F12>', '<cmd>call vimspector#StepOut()<cr>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', "Db", ":call vimspector#ToggleBreakpoint()<cr>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', "Dw", ":call vimspector#AddWatch()<cr>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', "De", ":call vimspector#Evaluate()<cr>", { noremap = true, silent = true })
    end,
}
