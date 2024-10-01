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
    inputs.nixvim.hom
    ../../../modules/shared/programs/git.nix
    ../../../modules/shared/programs/gh.nix
    ../../../modules/shared/programs/htop.nix
    ../../../modules/shared/programs/nushell.nix
    # #../../../modules/shared/programs/nvim.nix
    ../../../modules/shared/programs/starship.nix
    # # ../../../modules/shared/programs/zellij.nix
    ../../../modules/shared/programs/tmux.nix
    ../../../modules/shared/programs/zsh.nix
    ../../../modules/shared/programs/bash.nix
    ../../../modules/shared/secrets.nix
    # ../../../modules/shared/aliases.nix
    ../../../modules/shared/aliases.nix
    ../../../packages/shared/shell-aliases
  ];
  programs.neovim = {
    enable = true;
    package = pkgs.nixvim;
  };
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
