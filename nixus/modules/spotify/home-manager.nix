{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.nixus.spotify;
  sharedModule = import ./shared.nix { inherit lib pkgs; };
in
{
  imports = [ sharedModule ];

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ] ++ optional cfg.enableSpotifyd cfg.spotifydPackage;

    systemd.user.services = mkIf cfg.enableSpotifyd {
      spotifyd = {
        Unit = {
          Description = "Spotify playing daemon";
          After = [ "network-online.target" ];
          Wants = [ "sound.target" ];
        };
        Service = {
          ExecStart = "${cfg.spotifydPackage}/bin/spotifyd --no-daemon";
          Restart = "always";
          RestartSec = 12;
        };
        Install.WantedBy = [ "default.target" ];
      };
    };

    xdg.configFile = mkIf cfg.enableSpotifyd {
      "spotifyd/spotifyd.conf".text = generators.toINI { } cfg.spotifydSettings;
    };
  };
}
