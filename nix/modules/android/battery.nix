{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.battery;
in
{
  options.services.battery = {
    enable = mkEnableOption "Battery information";
    showInfoOnStartup = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to show battery information on startup.";
    };
    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        battery-info = "battery-info";
        battery-saver = "am start -a android.settings.BATTERY_SAVER_SETTINGS";
      };
      description = "Aliases for battery-related commands.";
    };
  };

  config = mkIf cfg.enable {
    environment.packages = with pkgs; [
      (writeScriptBin "battery-info" ''
        #!${runtimeShell}
        echo "Battery Information:"
        echo "--------------------"
        if command -v termux-battery-status >/dev/null 2>&1; then
          termux-battery-status
        else
          echo "termux-battery-status not available."
          echo "Install Termux:API add-on for battery information:"
          echo "1. Install the Termux:API app from the Google Play Store or F-Droid."
          echo "2. In Termux, run: pkg install termux-api"
        fi
      '')
    ];

    build.activation.batteryInfo = mkIf cfg.showInfoOnStartup ''
      ${config.environment.battery-info}/bin/battery-info
    '';

    environment.motd = ''
      echo "Type '${cfg.aliases.battery-info}' to see battery status."
      echo "Type '${cfg.aliases.battery-saver}' to open Android's battery saver settings."
    '';

    environment.shellAliases = cfg.aliases;
  };
}
