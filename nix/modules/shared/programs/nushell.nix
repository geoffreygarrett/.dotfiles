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
}
