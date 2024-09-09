{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.storage;
in
{
  options.services.storage = {
    enable = mkEnableOption "Storage information and management";
    showInfoOnStartup = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to show storage access information on startup.";
    };
    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        storage-info = "storage-info";
        open-app-settings = "open-app-settings";
        storage-usage = "du -h -d 1 /sdcard | sort -h";
      };
      description = "Aliases for storage-related commands.";
    };
  };

  config = mkIf cfg.enable {
    environment.packages = with pkgs; [
      (writeScriptBin "storage-info" ''
        #!${runtimeShell}
        echo "Storage Access Information:"
        echo "----------------------------"
        echo "Possible storage locations:"
        echo "  - /sdcard"
        echo "  - /data/data/com.termux.nix/files/home"
        echo "  - /mnt/sdcard"
        echo "  - <internal storage> (when accessed via Android)"
        echo ""
        echo "To grant storage access permission:"
        echo "1. Go to Android Settings"
        echo "2. Find and select the Nix-on-Droid app"
        echo "3. Go to Permissions"
        echo "4. Enable Storage permission"
      '')
      (writeScriptBin "open-app-settings" ''
        #!${runtimeShell}
        am start -a android.settings.APPLICATION_DETAILS_SETTINGS -d package:com.termux.nix
      '')
    ];

    build.activation.storageInfo = mkIf cfg.showInfoOnStartup ''
      ${pkgs.cowsay}/bin/cowsay "Welcome to Nix-on-Droid!"
      ${config.environment.storage-info}/bin/storage-info
    '';

    environment.motd = ''
      echo "Type '${cfg.aliases.storage-info}' for information about storage access."
      echo "Type '${cfg.aliases.open-app-settings}' to open the app's permission settings."
      echo "Type '${cfg.aliases.storage-usage}' to see storage usage in /sdcard."
    '';

    #    environment.shellAliases = cfg.aliases;
  };
}
