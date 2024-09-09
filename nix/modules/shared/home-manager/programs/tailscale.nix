{ config, pkgs, ... }: {

  # Install Tailscale for the user
  home.packages = with pkgs; [ tailscale ];

  # Set up a systemd user service for automatic Tailscale connection
  systemd.user.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart =
        "${pkgs.tailscale}/bin/tailscale up --authkey tskey-examplekeyhere";
      Restart = "on-failure";
      RestartSec = "10s";
    };

    # Script to run for Tailscale connection
    script = with pkgs; ''
      # Wait for tailscaled to settle
      sleep 2

      # Check if already authenticated to Tailscale
      status="$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then
        exit 0
      fi

      # Authenticate with Tailscale using auth key
      ${pkgs.tailscale}/bin/tailscale up --authkey tskey-examplekeyhere
    '';
  };

  #      networking.nat.enable = true;
  #      networking.nat.externalInterface = "eth0";
  #      networking.nat.internalInterfaces = [ "wg0" ];
  #      networking.firewall = {
  #        allowedUDPPorts = [ 51820 ];
  #      };

  #      services.tailscale.enable = true;
  #
  #      # create a oneshot job to authenticate to Tailscale
  #      systemd.services.tailscale-autoconnect = {
  #        description = "Automatic connection to Tailscale";
  #
  #        # make sure tailscale is running before trying to connect to tailscale
  #        after = [ "network-pre.target" "tailscale.service" ];
  #        wants = [ "network-pre.target" "tailscale.service" ];
  #        wantedBy = [ "multi-user.target" ];
  #
  #        # set this service as a oneshot job
  #        serviceConfig.Type = "oneshot";
  #
  #            # have the job run this shell script
  #            script = with pkgs; ''
  #              # wait for tailscaled to settle
  #              sleep 2
  #
  #              # check if we are already authenticated to tailscale
  #              status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
  #              if [ $status = "Running" ]; then # if so, then do nothing
  #                exit 0
  #              fi
  #
  #              # otherwise authenticate with tailscale
  #              ${tailscale}/bin/tailscale up -authkey tskey-examplekeyhere
  #            '';
  #
  #      };
}
# Enable NAT
#  networking.nat = {
#    enable = true;
#    externalInterface = "eth0";
#    internalInterfaces = [ "wg0" ];
#  };
#
#  # Configure firewall
#  networking.firewall = {
#    enable = true;
#    allowedUDPPorts = [ 51820 ]; # Port for WireGuard
#  };
#
#  # Tailscale configuration
#  environment.systemPackages = [ pkgs.tailscale ];

#  # Tailscale autoconnect service
#  systemd.services.tailscale-autoconnect = {
#    description = "Automatic connection to Tailscale";
#    after = [ "network-pre.target" "tailscale.service" ];
#    wants = [ "network-pre.target" "tailscale.service" ];
#    wantedBy = [ "multi-user.target" ];
#    serviceConfig.Type = "oneshot";
#    script = ''
#      # Wait for tailscaled to settle
#      sleep 2
#
#      # Check if we are already authenticated to Tailscale
#      status="$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
#      if [ $status = "Running" ]; then
#        # If so, then do nothing
#        exit 0
#      fi
#
#      # Otherwise, authenticate with Tailscale
#      # Replace 'tskey-examplekeyhere' with your actual Tailscale auth key
#      ${pkgs.tailscale}/bin/tailscale up -authkey tskey-examplekeyhere
#    '';
#  };
#}
