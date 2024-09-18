{ config, pkgs, ... }:

let
  mainInterface = "eno2"; # Main network interface name
  tailscalePort = 41641; # Tailscale port
  hostName = "apollo"; # Machine hostname
in
{
  networking = {
    hostName = hostName;
    networkmanager.enable = true;
    interfaces."${mainInterface}".wakeOnLan.enable = true;
    useDHCP = false;
    dhcpcd.wait = "background";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
      ];
      allowedUDPPorts = [
        53 # DNS
        tailscalePort
      ];
      trustedInterfaces = [
        "tailscale0"
        mainInterface
      ];
      allowedUDPPortRanges = [
        {
          from = tailscalePort;
          to = tailscalePort;
        }
      ];
    };
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
  };

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
