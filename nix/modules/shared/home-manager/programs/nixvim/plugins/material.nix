{ pkgs, ... }:
{
  programs.nixvim = {
    plugins = {
      lualine = {
        enable = true;
        theme = "material";
      };
    };

    extraPlugins = [
      pkgs.vimPlugins.material-nvim
    ];

    extraConfigLua = ''
      require('material').setup({
        contrast = {
          terminal = false,
          sidebars = false,
          floating_windows = false,
          cursor_line = false,
          non_current_windows = false,
          filetypes = {},
        },
        styles = {
          comments = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
        },
        plugins = {
          "telescope",
          "nvim-cmp",
          "nvim-web-devicons",
          "indent-blankline",
          "nvim-tree",
        },
        high_visibility = {
          lighter = false,
          darker = false,
        },
        disable = {
          background = true,
          term_colors = false,
          eob_lines = false,
        },
        lualine_style = "default",
      })
      vim.cmd 'colorscheme material'
      vim.g.material_style = "deep ocean"
      vim.cmd.colorscheme("material")
    '';
  };
}
