{ config, pkgs, ... }:

let
  keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITvBraRmM6IvQFt8VUHRx9hZ5DZVkPX3ORlfVqGa05z" ];
in
{
  users.users = {
    geoffrey = {
      isNormalUser = true;
      description = "Geoffrey Garrett";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
        "tailscale"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = keys;
      packages = with pkgs; [
        # thunderbird
      ];
    };
    root.openssh.authorizedKeys.keys = keys;
  };
}
