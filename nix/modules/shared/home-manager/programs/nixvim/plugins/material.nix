{ pkgs, ... }:
{
  programs.nixvim = {

    # colorschemes.catppuccin.enable = true;
    plugins.lualine.enable = true;

    # Add the Material theme plugin
    extraPlugins = [
      pkgs.vimPlugins.material-nvim
    ];

    # Configure and apply the Material theme
    extraConfigLua = ''
      require("material").setup()

      -- Set up Material theme
      vim.g.material_style = "deep ocean"

      -- Load the colorscheme
      vim.cmd.colorscheme("material")

      -- Custom highlight groups
      vim.cmd.hi("Comment gui=none")

      -- Set Material theme as a high priority to load before other start plugins
      vim.g.material_priority = 1000

      -- Additional Material theme settings can be added here
      -- For example:
      -- vim.g.material_terminal_italics = 1
      -- vim.g.material_theme_style = 'palenight'
      -- vim.g.material_variable_color = '#ff0000'
    '';

    # Optionally, you can set the colorscheme here as well
    # colorscheme = "material";
  };
}
