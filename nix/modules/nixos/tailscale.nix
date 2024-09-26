{
  config,
  pkgs,
  lib,
  ...
}:

let
  tailscalePort = 41641;
in
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
    port = tailscalePort;
  };

  systemd.services.tailscale-autoconnect = {
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
      RemainAfterExit = true;
    };
    script = with pkgs; ''
      set -euo pipefail
      echo "Starting Tailscale autoconnect service"
      sleep 2
      echo "Checking Tailscale status"
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ "$status" = "Running" ]; then
        echo "Tailscale is already running"
        exit 0
      fi
      echo "Authenticating to Tailscale"
      if [ ! -f "${config.sops.secrets.tailscale-auth-key.path}" ]; then
        echo "Error: Tailscale auth key file not found"
        exit 1
      fi
      ${tailscale}/bin/tailscale up -authkey "$(cat ${config.sops.secrets.tailscale-auth-key.path})"
      echo "Tailscale authentication completed"
    '';
  };

  networking.firewall = lib.mkIf config.services.tailscale.openFirewall {
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [
      # Port 443: Used for initiating connections to Tailscale's control server
      # and for data connections to DERP relays. Crucial for HTTPS traffic and 
      # general connectivity.
      443
    ];
    allowedUDPPorts = [
      # Port 41641 (or custom tailscalePort): Default port for establishing direct 
      # peer-to-peer connections between devices via WireGuard. Essential for 
      # primary communication between Tailscale nodes.
      tailscalePort
      # Port 3478: Used for STUN (Session Traversal Utilities for NAT) protocol.
      # Helps devices behind NAT discover their public IP addresses and port 
      # mappings. Vital for establishing direct connections.
      3478
    ];
  };

  environment.systemPackages = with pkgs; [
    tailscale
  ];

  /*
    Tailscale Configuration:
    - Service: Enabled with routing features
    - Firewall: Opened for Tailscale (when openFirewall is true)
    - Trusted Interface: tailscale0
    - Ports:
      TCP 443: Control server connections and DERP relay data
      UDP ${toString tailscalePort}: Direct peer-to-peer WireGuard connections
      UDP 3478: STUN protocol for NAT traversal
    - Autoconnect: Configured to automatically authenticate and connect

    Note: Ensure the sops-nix service is properly configured and the
    tailscale-auth-key secret is available for the autoconnect feature to work.
  */
}
