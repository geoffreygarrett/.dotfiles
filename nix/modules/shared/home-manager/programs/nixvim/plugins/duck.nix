{ pkgs, ... }:
let
  duck-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "duck-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "tamton-aquib";
      repo = "duck.nvim";
      rev = "d8a6b08af440e5a0e2b3b357e2f78bb1883272cd";
      sha256 = "sha256-97QSkZHpHLq1XyLNhPz88i9VuWy6ux7ZFNJx/g44K2A=";
    };
  };
in
{
  programs.nixvim = {
    extraPlugins = [ duck-nvim ];
    extraConfigLua = ''
      require("duck").setup()
      vim.keymap.set('n', '<leader>dd', function() require("duck").hatch() end, { desc = "Hatch duck" })
      vim.keymap.set('n', '<leader>dk', function() require("duck").cook() end, { desc = "Cook last duck" })
      vim.keymap.set('n', '<leader>da', function() require("duck").cook_all() end, { desc = "Cook all ducks" })
    '';
  };
}
