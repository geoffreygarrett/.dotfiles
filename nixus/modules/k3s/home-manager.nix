# home-manager.nix
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
    home.packages = [ pkgs.k3s ];

    systemd.user.services.k3s = {
      Unit = {
        Description = "Lightweight Kubernetes";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        ExecStart = "${pkgs.k3s}/bin/k3s ${cfg.nodeType} --server https://${cfg.serverAddress}:6443 --token-file ${cfg.tokenFile} ${toString cfg.extraFlags}";
        Restart = "always";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    home.file.".k3s-token".source = cfg.tokenFile;
  };
}
