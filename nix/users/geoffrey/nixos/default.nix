{
  config,
  pkgs,
  lib,
  ...
}:
{
  home-manager = {
    users.geoffrey = import ./home-manager/default.nix;
  };
  sops.secrets."users/geoffrey/password" = { };
  users.mutableUsers = false;
  users.users.geoffrey = {
    name = "geoffrey";
    isNormalUser = true;
    home = "/home/geoffrey";
    description = "Geoffrey Garrett";
    extraGroups = [
      "wheel"
      "networkmanager"
      # "docker"
      # "video"
      # "audio"
      # "input"
      # "disk"
    ];
    hashedPasswordFile = config.sops.secrets."users/geoffrey/password".path;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = import ../authorized-keys.nix;
    packages = with pkgs; [
      nautilus
      baobab
      git
    ];
  };
  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;
}
