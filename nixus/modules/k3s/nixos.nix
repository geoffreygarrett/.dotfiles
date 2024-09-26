# nixos.nix
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.nixus.k3s;
  sharedModule = import ./shared.nix { inherit lib; };
in
{
  imports = [ sharedModule ];

  config = mkIf cfg.enable {
    services.k3s = {
      enable = true;
      role = cfg.nodeType;
      serverAddr = "https://${cfg.serverAddress}:6443";
      token = cfg.tokenFile;
      extraFlags = cfg.extraFlags;
    };

    networking.firewall.allowedTCPPorts = [ 6443 ];

    environment.systemPackages = [ pkgs.k3s ];

    systemd.services.k3s = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
