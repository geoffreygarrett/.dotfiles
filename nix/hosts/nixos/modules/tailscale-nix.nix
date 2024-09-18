{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.nixos-tailscale;

  autoconnectService = pkgs.writeShellScript "tailscale-autoconnect" ''
    set -euo pipefail

    echo "Starting Tailscale autoconnect service"
    sleep 2

    status="$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
    if [ "$status" = "Running" ]; then
      echo "Tailscale is already running"
      exit 0
    fi

    if [ ! -f "${cfg.authKeyFile}" ]; then
      echo "Error: Tailscale auth key file not found"
      exit 1
    fi

    ${pkgs.tailscale}/bin/tailscale up -authkey "$(cat ${cfg.authKeyFile})"
    echo "Tailscale authentication completed"
  '';
in
{
  options.services.nixos-tailscale = {
    enable = mkEnableOption "Enable Tailscale with custom configurations";

    authKeyFile = mkOption {
      type = types.str;
      description = "Path to the file containing the Tailscale auth key";
    };

    autoconnect = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic connection to Tailscale";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional packages to install with Tailscale";
    };

    firewall = mkOption {
      type = types.bool;
      default = true;
      description = "Configure firewall for Tailscale";
    };
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;

    systemd.services.tailscale-autoconnect = mkIf cfg.autoconnect {
      description = "Automatic connection to Tailscale";
      after = [
        "network-pre.target"
        "tailscale.service"
        "sops-nix.service"
      ];
      wants = [
        "network-pre.target"
        "tailscale.service"
        "sops-nix.service"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = autoconnectService;
      };
    };

    environment.systemPackages =
      with pkgs;
      [
        tailscale
      ]
      ++ cfg.extraPackages;

    networking.firewall = mkIf cfg.firewall {
      checkReversePath = "loose";
      allowedUDPPorts = [ config.services.tailscale.port ];
    };

    # Ensure tailscale CLI is available in PATH
    environment.shellInit = ''
      export PATH=$PATH:${pkgs.tailscale}/bin
    '';
  };
}
