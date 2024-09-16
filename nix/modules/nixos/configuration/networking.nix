{ config, pkgs, ... }:

{
  networking = {
    # Set the hostname of the system
    hostName = "apollo";

    # Enable NetworkManager for network connection management
    networkmanager.enable = true;

    # Configure the firewall
    firewall = {
      # Enable the firewall
      enable = true;

      # Allow incoming connections on these TCP ports
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
      ];

      # Allow incoming connections on these UDP ports
      allowedUDPPorts = [
        53 # DNS
        41641 # Tailscale
      ];

      # Trust all traffic coming from the Tailscale interface
      trustedInterfaces = [ "tailscale0" ];

      # Allow a specific range of UDP ports (for Tailscale)
      allowedUDPPortRanges = [
        {
          from = 41641;
          to = 41641;
        }
      ];
    };
  };
}
