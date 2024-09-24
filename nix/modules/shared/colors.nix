{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.theme;
in
{
  options.theme = {
    enable = mkEnableOption "Deep Ocean theme";

    slug = mkOption {
      type = types.str;
      default = "deep-ocean";
      description = "Slug for the Deep Ocean theme";
    };

    name = mkOption {
      type = types.str;
      default = "Deep Ocean";
      description = "Name of the Deep Ocean theme";
    };

    author = mkOption {
      type = types.str;
      default = "";
      description = "Author of the Deep Ocean theme";
    };

    palette = mkOption {
      type = types.attrsOf types.str;
      default = {
        base00 = "0F111A"; # Background
        base01 = "181A1F"; # Second Background
        base02 = "1F2233"; # Highlight
        base03 = "4B526D"; # Text
        base04 = "8F93A2"; # Foreground
        base05 = "EEFFFF"; # White/Black Color
        base06 = "FFFFFF"; # Selection Foreground
        base07 = "84FFFF"; # Accent Color
        base08 = "F07178"; # Red Color
        base09 = "F78C6C"; # Orange Color
        base0A = "FFCB6B"; # Yellow Color
        base0B = "C3E88D"; # Green Color
        base0C = "89DDFF"; # Cyan Color
        base0D = "82AAFF"; # Blue Color
        base0E = "C792EA"; # Purple Color
        base0F = "FF5370"; # Error Color
      };
      description = "Color palette for the Deep Ocean theme";
    };

    extra = mkOption {
      type = types.attrsOf types.str;
      default = {
        background = "0F111A";
        foreground = "8F93A2";
        text = "4B526D";
        selection_background = "717CB480";
        selection_foreground = "FFFFFF";
        buttons = "191A21";
        second_background = "181A1F";
        disabled = "464B5D";
        contrast = "090B10";
        active = "1A1C25";
        border = "0F111A";
        highlight = "1F2233";
        tree = "717CB430";
        notifications = "090B10";
        accent_color = "84FFFF";
        excluded_files = "292D3E";
        green = "C3E88D";
        yellow = "FFCB6B";
        blue = "82AAFF";
        red = "F07178";
        purple = "C792EA";
        orange = "F78C6C";
        cyan = "89DDFF";
        gray = "717CB4";
        white_black = "EEFFFF";
        error = "FF5370";
        comments = "717CB4";
        variables = "EEFFFF";
        links = "80CBC4";
        functions = "82AAFF";
        keywords = "C792EA";
        tags = "F07178";
        strings = "C3E88D";
        operators = "89DDFF";
        attributes = "FFCB6B";
        numbers = "F78C6C";
        parameters = "F78C6C";
      };
      description = "Extended colors for the Deep Ocean theme";
    };
  };

  config = mkIf cfg.enable {
    # You can add any theme-related configurations here
    # For example, you might want to set some global variables or configure other programs
    # based on the theme colors
  };
}
