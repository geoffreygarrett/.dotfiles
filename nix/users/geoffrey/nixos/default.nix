{
  config,
  lib,
  pkgs,
  ...
}:
{
  users.users.geoffrey = {
    isNormalUser = true;
    home = "/home/geoffrey";
    description = "Geoffrey Garrett";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-dss AAAAB3Nza... alice@foobar"
    ];
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Allow sudo without password for wheel group
  security.sudo.wheelNeedsPassword = false;
}
