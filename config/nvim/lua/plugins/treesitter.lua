return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { "lua", "rust", "toml" }, -- Install Lua, Rust, and TOML parsers
        highlight = {
          enable = true,  -- Enable syntax highlighting
        },
        indent = {
          enable = true,  -- Enable indenting based on treesitter
        },
      })
    end,
  }
}
