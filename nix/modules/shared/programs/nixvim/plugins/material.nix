{ pkgs, config, ... }:
{
  programs.nixvim = {
    plugins = {
      lualine = {
        enable = true;
        settings.options.theme = "material";
      };
    };

    extraPlugins = [
      # pkgs.vimPlugins.material-nvim
    ];

    colorscheme = "material";
    # colorscheme = "material-deep-ocean";

    extraConfigLua = ''
      local palette = {
        base00 = "#${config.colorScheme.palette.base00}",
        base01 = "#${config.colorScheme.palette.base01}",
        base02 = "#${config.colorScheme.palette.base02}",
        base03 = "#${config.colorScheme.palette.base03}",
        base04 = "#${config.colorScheme.palette.base04}",
        base05 = "#${config.colorScheme.palette.base05}",
        base06 = "#${config.colorScheme.palette.base06}",
        base07 = "#${config.colorScheme.palette.base07}",
        base08 = "#${config.colorScheme.palette.base08}",
        base09 = "#${config.colorScheme.palette.base09}",
        base0A = "#${config.colorScheme.palette.base0A}",
        base0B = "#${config.colorScheme.palette.base0B}",
        base0C = "#${config.colorScheme.palette.base0C}",
        base0D = "#${config.colorScheme.palette.base0D}",
        base0E = "#${config.colorScheme.palette.base0E}",
        base0F = "#${config.colorScheme.palette.base0F}",
      }

      require('material').setup({
          contrast = {
              terminal = false, -- Enable contrast for the built-in terminal
              sidebars = false, -- Enable contrast for sidebar-like windows ( for example Nvim-Tree )
              floating_windows = false, -- Enable contrast for floating windows
              cursor_line = false, -- Enable darker background for the cursor line
              lsp_virtual_text = false, -- Enable contrasted background for lsp virtual text
              non_current_windows = false, -- Enable contrasted background for non-current windows
              filetypes = {}, -- Specify which filetypes get the contrasted (darker) background
          },

          styles = { -- Give comments style such as bold, italic, underline etc.
              comments = { --[[ italic = true ]] },
              strings = { --[[ bold = true ]] },
              keywords = { --[[ underline = true ]] },
              functions = { --[[ bold = true, undercurl = true ]] },
              variables = {},
              operators = {},
              types = {},
          },

          plugins = { -- Uncomment the plugins that you use to highlight them
              -- Available plugins:
              -- "coc",
              -- "colorful-winsep",
              -- "dap",
              -- "dashboard",
              -- "eyeliner",
              -- "fidget",
              -- "flash",
              "gitsigns",
              -- "harpoon",
              -- "hop",
              -- "illuminate",
              -- "indent-blankline",
              -- "lspsaga",
              -- "mini",
              -- "neogit",
              -- "neotest",
              "neo-tree",
              -- "neorg",
              -- "noice",
              "nvim-cmp",
              -- "nvim-navic",
              -- "nvim-tree",
              -- "nvim-web-devicons",
              -- "rainbow-delimiters",
              -- "sneak",
              -- "telescope",
              -- "trouble",
              "which-key",
              -- "nvim-notify",
          },

          disable = {
              colored_cursor = false, -- Disable the colored cursor
              borders = false, -- Disable borders between vertically split windows
              background = false, -- Prevent the theme from setting the background (NeoVim then uses your terminal background)
              term_colors = false, -- Prevent the theme from setting terminal colors
              eob_lines = false -- Hide the end-of-buffer lines
          },

          high_visibility = {
              lighter = false, -- Enable higher contrast text for lighter style
              darker = true -- Enable higher contrast text for darker style
          },

          lualine_style = "default", -- Lualine style ( can be 'stealth' or 'default' )

          async_loading = true, -- Load parts of the theme asynchronously for faster startup (turned on by default)

          custom_colors = function(colors)
            colors.editor.bg = palette.base00
            colors.editor.bg_alt = palette.base01
            colors.editor.fg = palette.base05
            colors.editor.fg_dark = palette.base04
            colors.editor.selection = palette.base02
            colors.editor.contrast = palette.base01
            colors.editor.active = palette.base02
            colors.editor.border = palette.base01
            colors.editor.line_numbers = palette.base03
            colors.editor.highlight = palette.base02
            colors.editor.disabled = palette.base03
            colors.editor.accent = palette.base0D

            colors.main.red = palette.base08
            colors.main.green = palette.base0B
            colors.main.yellow = palette.base0A
            colors.main.blue = palette.base0D
            colors.main.paleblue = palette.base0C
            colors.main.cyan = palette.base0C
            colors.main.purple = palette.base0E
            colors.main.orange = palette.base09
            colors.main.gray = palette.base03

            colors.syntax.comments = palette.base03
            colors.syntax.variables = palette.base08
            colors.syntax.functions = palette.base0D
            colors.syntax.keywords = palette.base09
            colors.syntax.types = palette.base0A
          end,

          custom_highlights = {}, -- Overwrite highlights with your own
      })

      -- vim.cmd 'colorscheme material-deep-ocean'
    '';
  };
}
