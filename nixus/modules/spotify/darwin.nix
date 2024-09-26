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

  config = mkMerge [
    (mkIf cfg.enable {
      homebrew.casks = [ "spotify" ];
      environment.systemPackages = optional cfg.enableSpotifyd cfg.spotifydPackage;
    })

    (mkIf (cfg.enable && cfg.enableSpotifyd) {
      launchd.user.agents.spotifyd = {
        serviceConfig = {
          ProgramArguments = [
            "${cfg.spotifydPackage}/bin/spotifyd"
            "--no-daemon"
          ];
          KeepAlive = true;
          RunAtLoad = true;
          StandardOutPath = "/tmp/spotifyd.log";
          StandardErrorPath = "/tmp/spotifyd.error.log";
        };
      };

      home.file.".config/spotifyd/spotifyd.conf".text = generators.toINI { } cfg.spotifydSettings;
    })
  ];
}
