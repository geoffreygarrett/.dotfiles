{ pkgs, config, ... }:

let
  theme = config.colorScheme.palette;
  luaPalette = ''
    local palette = {
      base00 = "${theme.base00}",
      base01 = "${theme.base01}",
      base02 = "${theme.base02}",
      base03 = "${theme.base03}",
      base04 = "${theme.base04}",
      base05 = "${theme.base05}",
      base06 = "${theme.base06}",
      base07 = "${theme.base07}",
      base08 = "${theme.base08}",
      base09 = "${theme.base09}",
      base0A = "${theme.base0A}",
      base0B = "${theme.base0B}",
      base0C = "${theme.base0C}",
      base0D = "${theme.base0D}",
      base0E = "${theme.base0E}",
      base0F = "${theme.base0F}",
    }
  '';

in
{
  programs.nixvim = {
    plugins = {
      lualine = {
        enable = true;
        settings.options.theme = "material";
      };
    };

    extraPlugins = [
      pkgs.vimPlugins.material-nvim
    ];

    extraConfigLua = ''
      ${luaPalette}

      vim.opt.termguicolors = true
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
          strings = {},
          keywords = {},
          functions = {},
          variables = {},
          operators = {},
          types = {},
        },
        plugins = {
          "gitsigns",
          "neo-tree",
          "nvim-cmp",
          "which-key",
          "telescope",
          "rainbow-delimiters",
          "dashboard",
        },
        disable = {
          colored_cursor = true,
          borders = true,
          background = true,
          term_colors = true,
          eob_lines = false,
        },
        high_visibility = {
          lighter = false,
          darker = true,
        },
        lualine_style = "default",
        async_loading = true,
        custom_colors = function(colors)
          -- Main colors
          colors.main = {
            white = "#" .. palette.base07,
            gray = "#" .. palette.base04,
            black = "#" .. palette.base00,
            red = "#" .. palette.base08,
            green = "#" .. palette.base0B,
            yellow = "#" .. palette.base0A,
            blue = "#" .. palette.base0D,
            paleblue = "#" .. palette.base0C,
            cyan = "#" .. palette.base0C,
            purple = "#" .. palette.base0E,
            orange = "#" .. palette.base09,
            darkred = "#" .. palette.base08,
            darkgreen = "#" .. palette.base0B,
            darkyellow = "#" .. palette.base0A,
            darkblue = "#" .. palette.base0D,
            darkcyan = "#" .. palette.base0C,
            darkpurple = "#" .. palette.base0E,
            darkorange = "#" .. palette.base09,
          }
          -- Editor colors
          colors.editor = {
            bg = "#" .. palette.base00,
            bg_alt = "#" .. palette.base01,
            fg = "#" .. palette.base05,
            fg_dark = "#" .. palette.base04,
            selection = "#" .. palette.base02,
            contrast = "#" .. palette.base00,
            active = "#" .. palette.base02,
            border = "#" .. palette.base01,
            line_numbers = "#" .. palette.base03,
            highlight = "#" .. palette.base02,
            disabled = "#" .. palette.base03,
            accent = "#" .. palette.base0D,
            cursor = "#" .. palette.base05,
            title = "#" .. palette.base05,
            link = "#" .. palette.base0C,
          }
          -- Syntax colors
          colors.syntax = {
            comments = "#" .. palette.base03,
            variable = colors.editor.fg,
            field = colors.editor.fg,
            keyword = colors.main.purple,
            value = colors.main.orange,
            operator = colors.main.cyan,
            fn = colors.main.blue,
            string = colors.main.green,
            type = colors.main.yellow,
          }
          -- LSP colors
          colors.lsp = {
            error = "#" .. palette.base08,
            warning = colors.main.yellow,
            info = colors.main.paleblue,
            hint = colors.main.purple,
          }
          -- Git colors
          colors.git = {
            added = colors.main.green,
            removed = colors.main.red,
            modified = colors.main.blue,
          }
          -- Background colors
          colors.backgrounds = {
            sidebars = colors.editor.bg,
            floating_windows = colors.editor.bg,
            non_current_windows = colors.editor.bg,
            cursor_line = colors.editor.active,
          }
        end,
        custom_highlights = function(colors)
          return {
            -- General Identifiers
            ["@variable"] = { fg = colors.syntax.variable },
            ["@variable.builtin"] = { fg = colors.main.purple },
            ["@variable.parameter"] = { fg = colors.main.orange },
            ["@variable.member"] = { fg = colors.syntax.field },

            -- Types
            ["@type"] = { fg = colors.syntax.type },
            ["@type.builtin"] = { fg = colors.syntax.keyword, italic = true },
            ["@type.qualifier"] = { fg = colors.main.cyan },
            ["@type.definition"] = { fg = colors.main.yellow },
            ["@storageclass"] = { fg = colors.main.cyan },
            ["@storageclass.lifetime"] = { fg = colors.main.orange },
            ["@attribute"] = { fg = colors.main.blue },
            ["@property"] = { fg = colors.syntax.field },
            ["@derive"] = { fg = colors.main.purple },

            -- Functions
            ["@function"] = { fg = colors.syntax.fn },
            ["@function.builtin"] = { fg = colors.syntax.fn },
            -- ["@function.macro"] = { fg = colors.syntax.fn },
            ["@method"] = { fg = colors.syntax.fn },
            ["@constructor"] = { fg = colors.syntax.fn },

            -- Keywords
            ["@keyword"] = { fg = colors.syntax.keyword, italic = true },
            ["@keyword.import"] = { fg = colors.syntax.keyword, italic = true },
            ["@keyword.function"] = { fg = colors.syntax.keyword, italic = true },
            ["@keyword.operator"] = { fg = colors.syntax.operator },
            ["@keyword.return"] = { fg = colors.syntax.keyword,  italic = true },
            ["@keyword.modifier"] = { fg = colors.syntax.keyword, italic = true },
            ["@keyword.coroutine"] = { fg = colors.main.purple, bg = "NONE" },
            ["@conditional"] = { fg = colors.syntax.keyword },
            ["@repeat"] = { fg = colors.syntax.keyword },
            ["@label"] = { fg = colors.main.yellow },
            ["@include"] = { fg = colors.syntax.keyword },
            ["@exception"] = { fg = colors.main.red },

            -- Constants
            ["@constant"] = { fg = colors.main.white },
            ["@lsp.type.const.rust"] = { fg = colors.syntax.value },
            ["@constant.builtin"] = { fg = colors.main.white, italic = true },
            ["@constant.macro"] = { fg = colors.main.white },

            -- Punctuation
            ["@punctuation.delimiter"] = { fg = colors.main.cyan },
            ["@punctuation.bracket"] = { fg = colors.main.cyan },
            ["@punctuation.special"] = { fg = colors.main.cyan },

            -- Comments
            ["@comment"] = { fg = colors.syntax.comments, italic = true },
            ["@comment.documentation"] = { fg = colors.syntax.comments, italic = true },

            -- Other
            ["@_expr"] = { fg = colors.main.white, bold = true, cterm = { bold = true } },

            -- Strings
            ["@string"] = { fg = colors.syntax.string },
            ["@string.regex"] = { fg = colors.main.yellow },
            ["@string.escape"] = { fg = colors.main.cyan },
            ["@string.special"] = { fg = colors.editor.fg_dark },
            ["@string.special.path"] = { fg = colors.syntax.string },

            -- Characters
            ["@character"] = { fg = colors.main.green },
            ["@character.special"] = { fg = colors.main.red },

            -- Numbers
            ["@number"] = { fg = colors.syntax.value },
            ["@float"] = { fg = colors.syntax.value },

            -- Booleans
            ["@boolean"] = { link = "@type.builtin" },

            -- Modules
            ["@module"] = { fg = colors.main.white },

            -- Operators
            ["@operator"] = { fg = colors.syntax.operator },

            -- Markup
            ["@markup.heading"] = { fg = colors.main.cyan, bold = true },
            ["@markup.raw"] = { fg = colors.main.green },
            ["@markup.link"] = { fg = colors.editor.link },
            ["@markup.link.url"] = { fg = colors.editor.link, underline = true },
            ["@markup.list"] = { fg = colors.main.red },
            ["@markup.strong"] = { bold = true },
            ["@markup.italic"] = { italic = true },
            ["@markup.strikethrough"] = { strikethrough = true },

            -- Rust-specific
            ["@field"] = { fg = colors.syntax.field },
            ["@type.qualifier"] = { fg = colors.main.cyan },
            ["@variable.member"] = { fg = colors.syntax.field },
            ["@namespace"] = { fg = colors.main.yellow },

            -- SQL
            ["@keyword.sql"] = { fg = colors.syntax.keyword, italic = true },
            ["@string.sql"] = { fg = colors.syntax.string, italic = true },

            -- LSP Semantic tokens
            ["@lsp.type.parameter"] = { fg = colors.main.orange },
            ["@lsp.type.variable"] = { fg = colors.syntax.variable },
            ["@lsp.typemod.variable.local"] = { fg = colors.main.orange },
            ["@lsp.typemod.variable.parameter"] = { fg = colors.main.orange },

            -- More semantics
            ["Identifier"] = { fg = colors.main.green, italic = true },
            ["@lsp.type.derive.rust"] = { fg = colors.main.blue },
            ["@lsp.type.struct.rust"] = { fg = colors.main.yellow },
            ["@lsp.type.attributeBracket.rust"] = { fg = colors.main.blue },
            ["@lsp.type.enum.rust"] = { fg = colors.main.yellow },
            ["@lsp.type.selfTypeKeyword.rust"] = { fg = colors.syntax.keyword },
            ["@lsp.type.enumMember.rust"] =  { fg = colors.syntax.variable, italic = true },
            ["@lsp.typemod.parameter.mutable.rust"] = { fg = colors.main.orange, underline = true },
            ["@lsp.typemod.variable.mutable.rust"] = { fg = colors.main.white, underline = true },
            ["@lsp.mod.controlFlow.rust"] = { fg = colors.main.purple, italic = true, bold = true },
            ["@lsp.mod.attribute.rust"] = { fg = colors.main.blue },
          }
        end
      })

      vim.cmd 'colorscheme material'
    '';
  };
}
