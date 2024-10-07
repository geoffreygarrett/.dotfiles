{
  config,
  pkgs,
  inputs,
  ...
}:
let
  username = "geoffrey";
  description = "Geoffrey Garrett";
in
{
  sops.secrets."users/${username}/password" = {
    neededForUsers = true;
  };
  users.mutableUsers = false;
  users.users.geoffrey = {
    inherit description;
    name = "${username}";
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = [
      "wheel"
      "networkmanager"
      # "docker"
      # "video"
      # "audio"
      # "input"
      # "disk"
    ];
    hashedPasswordFile = config.sops.secrets."users/${username}/password".path;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = import ../authorized-keys.nix;
    packages = with pkgs; [
      git
    ];
  };
  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;
}
