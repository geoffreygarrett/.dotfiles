{ pkgs, config, lib, ... }:
let
  shellAliasesConfig = import ./shell-aliases.nix { inherit pkgs lib; };
in
{
  programs.nushell = {
    enable = true;
  };

  programs.nushell.shellAliases = shellAliasesConfig.shellAliases.nu;

  # Install additional tools that were used in the Zsh config
  home.packages = with pkgs; [
    fzf
    bat
    fd
    direnv
    starship
  ];

  # Configure Starship prompt for Nushell
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
  };
}