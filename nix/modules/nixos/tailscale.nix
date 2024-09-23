{ config, pkgs, ... }:
{
  # networking = {
  #   trustedInterfaces = [
  #     "tailscale0"
  #   ];
  #   # allowedUDPPorts = [
  #   #   53 # DNS
  #   #   41641 # Tailscale
  #   # ];
  # };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
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
    serviceConfig.Type = "oneshot";
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

  environment.systemPackages = with pkgs; [
    tailscale
    linuxPackages.v4l2loopback
    v4l-utils
    inetutils
  ];

  /*
    Network Configuration:
    - Hostname: ${hostName}
    - Main interface: ${mainInterface} (WoL enabled, DHCP)
    - Firewall: TCP (22, 80, 443), UDP (53, ${toString tailscalePort})
    - Tailscale: Enabled with routing features
    - Trusted interfaces: tailscale0, ${mainInterface}

    Adjust let variables for different setups.
  */
}
