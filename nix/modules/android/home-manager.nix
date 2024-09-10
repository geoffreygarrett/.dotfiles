{
  self,
  config,
  lib,
  pkgs,
  inputs,
  services,
  ...
}:

{
  home.stateVersion = "24.05";
  system.os = "android";
  imports = [
    ../shared/home-manager/programs/git.nix
    ../shared/home-manager/programs/gh.nix
    ../shared/home-manager/programs/htop.nix
    ../shared/home-manager/programs/nushell.nix
    ../shared/home-manager/programs/nvim.nix
    ../shared/home-manager/programs/starship.nix
    ../shared/home-manager/programs/zellij.nix
    ../shared/home-manager/programs/zsh.nix
    ../shared/secrets.nix
  ];

  programs.bash = {
    enable = true;
    shellAliases =
      let
        sshAliases = if services.ssh.enable then services.ssh.aliases else { };
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
