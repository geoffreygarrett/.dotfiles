{
  pkgs,
  config,
  lib,
  ...
}:
let
  shellAliasesConfig = import ./shell-aliases.nix { inherit pkgs lib; };
in
{
  programs.nushell = {
    enable = true;
    extraConfig = ''
      $env.config = {
             show_banner: false,
      };
    '';
  };
  #  programs.nushell.shellAliases = shellAliasesConfig.shellAliases.nu;
}
