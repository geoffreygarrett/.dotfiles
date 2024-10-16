{
  self,
  config,
  lib,
  pkgs,
  inputs,
  services,
  user,
  ...
}:
{
  home.stateVersion = "24.05";
  # system.os = "android";
  imports = [
    # ../shared/programs/git.nix
    # ../shared/programs/gh.nix
    # ../shared/programs/htop.nix
    # ../shared/programs/nushell.nix
    # ../shared/programs/nixvim
    # #../shared/programs/nvim.nix
    # ../shared/programs/starship.nix
    # # ../shared/programs/zellij.nix
    # ../shared/programs/tmux.nix
    # ../shared/programs/zsh.nix
    # ../shared/programs/bash.nix
    ../shared/secrets.nix
    # ../shared/aliases.nix
    ../shared/aliases.nix
    ../../packages/shared/shell-aliases
    ../../users/geoffrey/home-manager/shared.nix
  ];
  programs.bash = {
    enable = true;
    shellAliases =
      let
        # sshAliases = if services.openssh.enable then services.openssh.aliases else { };

        sshAliases = { };
      in
      {
        ll = "ls -l";
        hw = "echo 'Hello, World!'";
        switch = "nix-on-droid switch --flake ~/.dotfiles";
        cdf = "cd ~/.dotfiles";
      }
      // sshAliases;
  };
  home.packages = with pkgs; [
    fortune
    lolcat
  ];
}
