# darwin.nix
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
    environment.systemPackages = [ pkgs.k3s ];

    launchd.user.agents.k3s = {
      serviceConfig = {
        ProgramArguments = [
          "${pkgs.k3s}/bin/k3s"
          cfg.nodeType
          "--server"
          "https://${cfg.serverAddress}:6443"
          "--token-file"
          cfg.tokenFile
        ] ++ cfg.extraFlags;
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/tmp/k3s.log";
        StandardErrorPath = "/tmp/k3s.error.log";
      };
    };

    system.activationScripts.postActivation.text = ''
      echo "Note: K3s on macOS is for development purposes only and may not function fully."
    '';
  };
}
