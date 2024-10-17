{
  inputs,
  pkgs,
  lib,
  ...
}:

let
  username = "geoffrey";
in
{
  imports = [
    # Don't change
    inputs.nix-colors.homeManagerModules.default

    # Add after this comment
    ./modules/gh.nix
    ./modules/git.nix
    ./modules/tms.nix
    ./modules/starship.nix
    ./modules/nushell.nix
    ./modules/zsh.nix
    ./modules/tmux.nix
    ./modules/htop.nix
  ];

  # colorScheme = {
  #   slug = "darcula";
  #   name = "Darcula";
  #   author = "JetBrains";
  #   palette = {
  #     base00 = "2B2B2B"; # Background
  #     base01 = "323232"; # Second Background
  #     base02 = "3A3A3A"; # Highlight
  #     base03 = "4A4A4A"; # Text
  #     base04 = "B8B8B8"; # Foreground
  #     base05 = "D8D8D8"; # White/Black Color
  #     base06 = "E8E8E8"; # Gray Color
  #     base07 = "F8F8F8"; # Selection Foreground
  #     base08 = "79ABFF"; # Red Color
  #     base09 = "9876AA"; # Orange Color
  #     base0A = "A9B7C6"; # Yellow Color
  #     base0B = "A5C25C"; # Green Color
  #     base0C = "1990B8"; # Cyan Color
  #     base0D = "9876AA"; # Blue Color
  #     base0E = "A9B7C6"; # Purple Color
  #     base0F = "79ABFF"; # Error Color
  #   };
  # };

  colorScheme = {
    slug = "deep-ocean-material";
    name = "Deep Ocean Material";
    author = "Material Theme";
    palette = {
      base00 = "0F111A"; # Default Background
      base01 = "181A1F"; # Lighter Background (Used for status bars, line number and folding marks)
      base02 = "1F2233"; # Selection Background
      base03 = "4B526D"; # Comments, Invisibles, Line Highlighting
      base04 = "8F93A2"; # Dark Foreground (Used for status bars)
      base05 = "EEFFFF"; # Default Foreground, Caret, Delimiters, Operators
      base06 = "717CB4"; # Light Foreground (Not often used)
      base07 = "FFFFFF"; # Light Background (Not often used)
      base08 = "F07178"; # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
      base09 = "F78C6C"; # Integers, Boolean, Constants, XML Attributes, Markup Link Url
      base0A = "FFCB6B"; # Classes, Markup Bold, Search Text Background
      base0B = "C3E88D"; # Strings, Inherited Class, Markup Code, Diff Inserted
      base0C = "89DDFF"; # Support, Regular Expressions, Escape Characters, Markup Quotes
      base0D = "82AAFF"; # Functions, Methods, Attribute IDs, Headings
      base0E = "C792EA"; # Keywords, Storage, Selector, Markup Italic, Diff Changed
      base0F = "FF5370"; # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
    };
  };

  home = {
    username = lib.mkDefault username;
    homeDirectory = lib.mkDefault (
      if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}"
    );
    stateVersion = lib.mkDefault "24.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = lib.mkDefault true;
}
