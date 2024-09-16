{ config, pkgs, ... }:

{
  services = {
    tailscale = {
      enable = true;
      authKeyFile = "/path/to/your/tailscale/authkey";
      openFirewall = true;
      useRoutingFeatures = "both";
    };

    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    printing.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    hardware.openrgb.enable = true;

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };

  systemd.services.tailscaled = {
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-pre.target"
      "NetworkManager.service"
      "systemd-resolved.service"
    ];
    wants = [
      "network-pre.target"
      "NetworkManager.service"
      "systemd-resolved.service"
    ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
