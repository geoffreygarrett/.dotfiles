{ lib, pkgs }:
{
  base16theme,
  colorAssignments ? {
    background = "base00";
    logoOutline = "base01";
    logoBackground = "base00";
    logoMiddle1 = "base0D";
    logoMiddle2 = "base0E";
  },
}:
let
  template = builtins.readFile ./nixos-wallpaper-template.svg;
  getColor = colorName: "#${base16theme.${colorAssignments.${colorName}}}";
  replacements = builtins.mapAttrs (name: value: getColor name) colorAssignments;
  replaceColors =
    str:
    lib.foldl' (acc: color: lib.replaceStrings [ "@${color}@" ] [ replacements.${color} ] acc) str (
      builtins.attrNames replacements
    );
  finalSvg = replaceColors template;
in
pkgs.writeText "nixos-wallpaper.svg" finalSvg
