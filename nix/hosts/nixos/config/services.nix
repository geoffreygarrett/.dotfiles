{ config, pkgs, ... }:

{
  services = {
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

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    after = [ "network-pre.target" "tailscale.service" "sops-nix.service" ];
    wants = [ "network-pre.target" "tailscale.service" "sops-nix.service" ];
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
    openrgb-with-all-plugins
    linuxPackages.v4l2loopback
    v4l-utils
    inetutils
    (writeScriptBin "reboot-to-windows" ''
      #!${pkgs.stdenv.shell}
      windows_menu_entry=$(grep menuentry /boot/grub/grub.cfg | grep -i windows | cut -d "'" -f2)
      sudo grub-reboot "$windows_menu_entry" && sudo reboot
    '')
  ];
}
