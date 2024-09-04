{ pkgs, config, lib, ... }:
let
  shellAliasesConfig = import ./shell-aliases.nix { inherit pkgs lib; };
in
{
  programs.nushell = {
    enable = true;
    extraConfig = ''


    '';
  };

  programs.nushell.shellAliases = shellAliasesConfig.shellAliases.nu;
  xdg.configFile."nushell" = {
    source = ../../dotfiles/nushell;
    recursive = true;
  };

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
