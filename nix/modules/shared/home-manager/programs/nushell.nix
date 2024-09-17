{
  pkgs,
  config,
  lib,
  ...
}:
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
