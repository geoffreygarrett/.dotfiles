final: prev: {
  neovim = prev.neovim.override {
    configure = {
      customRC = ''
        ${prev.neovim.configure.customRC or ""}
        lua << EOF
          -- ChatGPT plugin configuration
          return {
              "jackMort/ChatGPT.nvim",
              event = "VeryLazy",
              config = function()
                  require("chatgpt").setup({
                      api_key_cmd = '${final.key-fetcher}/bin/key-fetcher openai-api-key',
                  })
              end,
              dependencies = {
                  "MunifTanjim/nui.nvim",
                  "nvim-lua/plenary.nvim",
                  "folke/trouble.nvim",
                  "nvim-telescope/telescope.nvim",
              },
          }
        EOF
      '';
    };
  };
}
