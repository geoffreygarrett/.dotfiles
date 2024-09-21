{
  config,
  pkgs,
  ...
}:
{
  # Install Tailscale for the user
  home.packages = with pkgs; [ tailscale ];

  # Set up a systemd user service for automatic Tailscale connection
  systemd.user.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    after = [
      "network-pre.target"
      "tailscale.service"
    ];
    wants = [
      "network-pre.target"
      "tailscale.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.tailscale}/bin/tailscale up --authkey tskey-examplekeyhere";
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
}

