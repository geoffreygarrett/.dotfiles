{ pkgs, ... }:
{
  programs.nixvim = {
    # Enable Material theme
    #    colorschemes.material = {
    #      enable = true;
    #      style = "deep-ocean";
    #      # You can add more Material-specific settings here if needed
    #    };

    # Set theme priority and custom initialization
    extraPlugins = [
      {
        plugin = pkgs.vimPlugins.material-nvim;
        config = ''
          lua <<EOF
            vim.g.material_style = "deep ocean"
            vim.cmd.colorscheme("material")
            -- You can configure highlights by doing something like:
            vim.cmd.hi("Comment gui=none")
          EOF
        '';
      }
    ];

    colorscheme = "material-nvim";

    # Ensure the theme is loaded before other plugins
    extraConfigVim = ''
      " Set Material theme as a high priority to load before other start plugins
      let g:material_priority = 1000
    '';

    # Optional: If you want to keep Tokyonight as an alternative, you can add it like this:
    # colorschemes.tokyonight = {
    #   enable = false;  # Set to true if you want to use it instead of Material
    #   style = "night";
    # };
  };
}
