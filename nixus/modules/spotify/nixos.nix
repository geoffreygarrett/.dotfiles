{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.nixus.spotify;
  sharedModule = import ./shared.nix { inherit lib pkgs; };

  icons =
    if cfg.useNerdFonts then
      {
        header = "===";
        warning = " ";
        info = " ";
        success = " ";
      }
    else
      {
        header = "===";
        warning = "⚠️ ";
        info = "ℹ️ ";
        success = "✅";
      };

  formatHeader = text: ''
    echo ""
    echo "${icons.header} ${text} ${icons.header}"
    echo ""
  '';

  formatWarning = text: ''
    echo "${icons.warning} ${text}" >&2
  '';

  formatInfo = text: ''
    echo "${icons.info} ${text}"
  '';

  formatSuccess = text: ''
    echo "${icons.success} ${text}"
  '';

in
{
  imports = [ sharedModule ];

  options.nixus.spotify = {
    useNerdFonts = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Use Nerd Fonts icons instead of emojis for formatting output.";
    };
    firewall = {
      enableLocalDiscovery = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Open firewall for local device discovery (mDNS). Opens UDP port 5353.";
      };
      enableLocalSync = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Open firewall for syncing local files with mobile devices. Opens TCP port 57621.";
      };
      enableSpotifyConnect = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Open firewall for Spotify Connect features. Opens TCP port 4070.";
      };
      acknowledgeFirewallRisks = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Acknowledge understanding of the firewall risks and silence warnings.";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      environment.systemPackages = [ cfg.package ];

      assertions = [
        {
          assertion =
            cfg.firewall.enableLocalDiscovery
            || cfg.firewall.enableLocalSync
            || cfg.firewall.enableSpotifyConnect;
          message = "At least one firewall option should be enabled for Spotify to function properly.";
        }
      ];

      networking.firewall = {
        allowedUDPPorts = mkIf cfg.firewall.enableLocalDiscovery [ 5353 ];
        allowedTCPPorts =
          (optional cfg.firewall.enableLocalSync 57621) ++ (optional cfg.firewall.enableSpotifyConnect 4070);
      };

      warnings = mkIf (!cfg.firewall.acknowledgeFirewallRisks) [
        (mkIf cfg.firewall.enableLocalDiscovery ''
          Spotify: UDP port 5353 (mDNS) has been opened for local device discovery.
          This allows Spotify to discover Google Cast and Spotify Connect devices on your local network.
          Note: This port is also used by other services for local discovery and may increase your attack surface.
          If this was unintentional, please disable this feature by setting nixus.spotify.firewall.enableLocalDiscovery = false;
          Otherwise, ensure your local network is secure and trusted.
        '')
        (mkIf cfg.firewall.enableLocalSync ''
          Spotify: TCP port 57621 has been opened for syncing local files with mobile devices.
          This allows Spotify to sync local tracks from your filesystem with mobile devices on the same network.
          If this was unintentional, please disable this feature by setting nixus.spotify.firewall.enableLocalSync = false;
          Otherwise, ensure that you trust all devices on your local network, as this opens a direct connection to your system.
        '')
        (mkIf cfg.firewall.enableSpotifyConnect ''
          Spotify: TCP port 4070 has been opened for Spotify Connect features.
          This allows for remote control of your Spotify playback and enables Spotify Connect functionality.
          If this was unintentional, please disable this feature by setting nixus.spotify.firewall.enableSpotifyConnect = false;
          Otherwise, be aware that this could potentially allow other devices on your network to control your Spotify playback.
        '')
      ];

      system.activationScripts.spotifyFirewallInfo = ''
        ${formatHeader "Spotify Firewall Configuration"}

        ${formatInfo "Enabled Features:"}
        ${optionalString cfg.firewall.enableLocalDiscovery (
          formatInfo "  • Local Discovery (mDNS): UDP port 5353 is open"
        )}
        ${optionalString cfg.firewall.enableLocalSync (formatInfo "  • Local Sync: TCP port 57621 is open")}
        ${optionalString cfg.firewall.enableSpotifyConnect (
          formatInfo "  • Spotify Connect: TCP port 4070 is open"
        )}

        ${
          if cfg.firewall.acknowledgeFirewallRisks then
            ''
              ${formatSuccess "Firewall risks have been acknowledged. Warnings are silenced."}
            ''
          else
            ''
              ${formatWarning "Security Notices:"}
              ${formatWarning "  • Ensure these ports are only accessible on trusted networks."}
              ${formatWarning "  • If any of these features were enabled unintentionally, please disable them in your configuration."}
              ${formatWarning "  • To acknowledge these risks and silence warnings, set nixus.spotify.firewall.acknowledgeFirewallRisks = true;"}
            ''
        }

        ${formatHeader "End of Spotify Firewall Configuration"}
      '';
    })

    (mkIf (cfg.enable && cfg.enableSpotifyd) {
      services.spotifyd = {
        enable = true;
        settings = cfg.spotifydSettings;
      };
    })
  ];
}
