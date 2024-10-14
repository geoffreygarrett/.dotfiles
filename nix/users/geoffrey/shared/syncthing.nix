{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.my-syncthing;
  username = config.users.users.geoffrey.name;
  homeDir = config.users.users.geoffrey.home;
in
{
  options.services.my-syncthing = {
    enable = mkEnableOption "Enable custom Syncthing service";

    devices = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            id = mkOption {
              type = types.str;
              description = "The device ID";
            };
            name = mkOption {
              type = types.str;
              description = "The device name";
            };
          };
        }
      );
      default = { };
      description = "Syncthing devices to connect to";
    };

    folders = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            path = mkOption {
              type = types.str;
              description = "The path to the folder";
            };
            devices = mkOption {
              type = types.listOf types.str;
              description = "List of devices to share this folder with";
            };
            ignorePerms = mkOption {
              type = types.bool;
              default = true;
              description = "Whether to ignore permissions for this folder";
            };
          };
        }
      );
      default = { };
      description = "Syncthing folders to sync";
    };

    guiUser = mkOption {
      type = types.str;
      default = username;
      description = "Username for Syncthing GUI";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "syncthing/key" = {
        owner = username;
      };
      "syncthing/cert" = {
        owner = username;
      };
      "syncthing/gui-password" = {
        owner = username;
      };
    };

    services.syncthing = {
      enable = true;
      user = username;
      dataDir = "${homeDir}/Sync";
      configDir = "${homeDir}/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      key = config.sops.secrets."syncthing/key".path;
      cert = config.sops.secrets."syncthing/cert".path;
      settings = {
        devices = mapAttrs (name: device: {
          id = device.id;
          name = device.name;
        }) cfg.devices;
        folders = mapAttrs (name: folder: {
          path = folder.path;
          devices = folder.devices;
          ignorePerms = folder.ignorePerms;
        }) cfg.folders;
        gui = {
          user = cfg.guiUser;
          password = "#secret:syncthing/gui-password";
        };
        options = {
          globalAnnounceEnabled = false;
          localAnnounceEnabled = true;
          urAccepted = -1;
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 22000 ];
    networking.firewall.allowedUDPPorts = [
      22000
      21027
    ];

    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  };
}
