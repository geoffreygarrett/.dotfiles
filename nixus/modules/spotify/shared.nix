{ lib, pkgs, ... }:

with lib;

{
  imports = [ ../shared.nix ];
  options.nixus.spotify = {
    enable = mkEnableOption "Nixus Spotify module";

    package = mkOption {
      type = types.package;
      default = pkgs.spotify;
      defaultText = literalExpression "pkgs.spotify";
      description = "The Spotify package to use. Note that Spotify is unfree software.";
    };

    enableSpotifyd = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable Spotifyd service. Spotifyd is an alternative Spotify client that connects to Spotify as a Spotify Connect device.
        It offers no controls of its own but can be controlled via playerctl or spotify-tui.
      '';
    };
    spotifydSettings = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''
        {
          global = {
            username = "your_username";
            password = "your_password";
          };
        }
      '';
      description = ''
        Spotifyd settings. This should be an attribute set containing the configuration for Spotifyd.
        Warning: Storing passwords in the Nix store is insecure. Consider using a more secure method for credential management.
      '';
    };
  };
}
