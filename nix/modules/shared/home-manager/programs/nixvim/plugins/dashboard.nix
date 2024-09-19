{
  pkgs,
  lib,
  config,
  ...
}:
let
  lolcat-cmd = pkgs.lib.escapeShellArg "${pkgs.lolcat}/bin/lolcat";
  header-content = ''



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
  xdg.configFile."nixvim/dashboard-header.txt".text = header-content;
  programs.nixvim = {
    plugins.dashboard.enable = true;
    extraConfigLua = ''
      local dashboard = require('dashboard')

      -- Set the padding constants
      local DESCRIPTION_PADDING = 20
      local ICON_PADDING = 2

      -- Function to add padding to a string (left or right)
      local function pad_string(str, padding, direction)
        if direction == "left" then
          return string.rep(' ', padding) .. str
        else
          return str .. string.rep(' ', padding)
        end
      end

      -- Set up an autocmd to apply highlights after the colorscheme is loaded
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.cmd([[
            highlight DashboardHeader guifg=#c3e88d
            highlight DashboardFooter guifg=#717CB4
            highlight DashboardDesc guifg=#717CB4
            highlight DashboardKey guifg=#f78c6c
            highlight DashboardIcon guifg=#717CB4
          ]])
        end
      })

      dashboard.setup({
        theme = 'doom',
        config = {
          header = vim.fn.readfile('${config.home.homeDirectory}/.config/nixvim/dashboard-header.txt'),
          center = {
            {
              icon = pad_string('󰍉 ', ICON_PADDING, "right"),
              icon_hl = 'DashboardIcon',
              desc = pad_string('Find File', DESCRIPTION_PADDING, "right"),
              desc_hl = 'DashboardDesc',
              key = 'f',
              key_hl = 'DashboardKey',
              action = 'Telescope find_files'
            },
            {
              icon = pad_string(' ', ICON_PADDING, "right"),
              icon_hl = 'DashboardIcon',
              desc = pad_string('Find Dotfiles', DESCRIPTION_PADDING, "right"),
              desc_hl = 'DashboardDesc',
              key = 'd',
              key_hl = 'DashboardKey',
              action = 'Telescope find_files cwd=${config.home.homeDirectory}/.dotfiles'
            },
            {
              icon = pad_string(' ', ICON_PADDING, "right"),
              icon_hl = 'DashboardIcon',
              desc = pad_string('Find Word', DESCRIPTION_PADDING, "right"),
              desc_hl = 'DashboardDesc',
              key = 'w',
              key_hl = 'DashboardKey',
              action = 'Telescope live_grep'
            },
            {
              icon = pad_string(' ', ICON_PADDING, "right"),
              icon_hl = 'DashboardIcon',
              desc = pad_string('Recent Files', DESCRIPTION_PADDING, "right"),
              desc_hl = 'DashboardDesc',
              key = 'r',
              key_hl = 'DashboardKey',
              action = 'Telescope oldfiles'
            },
            {
              icon = pad_string(' ', ICON_PADDING, "right"),
              icon_hl = 'DashboardIcon',
              desc = pad_string('New File', DESCRIPTION_PADDING, "right"),
              desc_hl = 'DashboardDesc',
              key = 'n',
              key_hl = 'DashboardKey',
              action = 'enew'
            },
          },
          footer = { "", "NixVim - Powered by Nix " },
          preview = {
            command = '${lolcat-cmd}',
            file_path = '~/.config/nixvim/dashboard-header.txt',
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
