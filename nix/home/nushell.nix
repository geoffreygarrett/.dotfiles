{ pkgs, config, lib, ... }:
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

    #    configFile.source = ../../dotfiles/nushell/config.nu;
    #    envFile.source = ../../dotfiles/nushell/env.nu;

  };
  #  home.packages = with pkgs; [
  #   cargo
  #  ];
  programs.nushell.shellAliases = shellAliasesConfig.shellAliases.nu;

}
