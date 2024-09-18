{
  pkgs,
  lib,
  config,
  ...
}:

let
  lolcat-cmd = pkgs.lib.escapeShellArg "${pkgs.lolcat}/bin/lolcat";
  header-file = pkgs.writeText "nvim-dashboard-header.txt" ''


      ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          
       ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       
             ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     
              ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    
             ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   
      ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  
     ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   
    ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  
    ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ 
         ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     
          ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     


  '';
in
{
  programs.nixvim = {
    plugins.dashboard.enable = true;
    extraConfigLua = ''
      local dashboard = require('dashboard')
      dashboard.setup({
        theme = 'doom',
        config = {
          header = vim.fn.readfile('${header-file}'),
          center = {
            {
              icon = ' ',
              desc = 'Find File',
              desc_hl = 'String',
              key = 'f',
              key_hl = 'Number',
              action = 'Telescope find_files'
            },
            {
              icon = ' ',
              desc = 'Find Dotfiles',
              desc_hl = 'String',
              key = 'd',
              key_hl = 'Number',
              action = 'Telescope find_files cwd=${config.home.homeDirectory}/.dotfiles'
            },
            {
              icon = ' ',
              desc = 'Find Word',
              desc_hl = 'String',
              key = 'w',
              key_hl = 'Number',
              action = 'Telescope live_grep'
            },
            {
              icon = ' ',
              desc = 'Recent Files',
              desc_hl = 'String',
              key = 'r',
              key_hl = 'Number',
              action = 'Telescope oldfiles'
            },
            {
              icon = ' ',
              desc = 'New File',
              desc_hl = 'String',
              key = 'n',
              key_hl = 'Number',
              action = 'enew'
            },
          },
          footer = { "NixVim - Powered by Nix" },
          preview = {
            command = 'lolcat',
            file_path = '${header-file}',
            file_height = 20,
            file_width = 85
          }
        }
      })
    '';
  };

  # Ensure lolcat is available
  home.packages = with pkgs; [ lolcat ];
}
