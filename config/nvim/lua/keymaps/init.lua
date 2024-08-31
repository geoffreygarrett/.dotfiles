-- ~/.config/nvim/lua/keys/init.lua

local function load_keymaps()
    -- Key Mappings
    vim.g.mapleader = " "

    -- Telescope key mappings
    vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true })

    -- Oil key mapping
    vim.api.nvim_set_keymap('n', '<leader>o', '<cmd>Oil<cr>', { noremap = true, silent = true })

    -- Load other keymap files
    require('keymaps.cargo')
end

load_keymaps()
