{ pkgs, config, ... }:
let
  user = "geoffreygarrett";
in
{
  imports = [ ./global ];
  sops.age.keyFile = "/home/${user}/.config/sops/age/keys.txt";
  home.packages = with pkgs; [ syncthing ];
  services.syncthing = {
    enable = true;
    tray.enable = true;
    tray.command = "syncthingtray";
    extraOptions = [ ];
    #      user = config.home.username;
    #      dataDir = config.home.homeDirectory;
    #      configDir = "${config.home.homeDirectory}/.config/syncthing";
    #      overrideDevices = true;
    #      overrideFolders = true;
    #      devices = {
    #        "laptop" = {
    #          id = "DEVICE-ID-GOES-HERE";
    #        };
    #        "desktop" = {
    #          id = "DEVICE-ID-GOES-HERE";
    #        };
    #      };
    #      folders = {
    #        "documents" = {
    #          path = "${config.home.homeDirectory}/Documents";
    #          devices = [ "laptop" "desktop" ];
    #          versioning = {
    #            type = "simple";
    #            params = {
    #              keep = "10";
    #            };
    #          };
    #        };
    #        "photos" = {
    #          path = "${config.home.homeDirectory}/Pictures";
    #          devices = [ "laptop" "desktop" ];
    #          versioning = {
    #            type = "staggered";
    #            params = {
    #              cleanInterval = "3600";
    #              maxAge = "15768000";
    #            };
    #          };
    #        };
    #      };
  };
  #    services = {
  #      syncthing = {
  #        enable = true;
  #        user = "myusername";
  #        dataDir = "/home/myusername/Documents";
  #        configDir = "/home/myusername/Documents/.config/syncthing";
  #        overrideDevices = true;     # overrides any devices added or deleted through the WebUI
  #        overrideFolders = true;     # overrides any folders added or deleted through the WebUI
  #        settings = {
  #          devices = {
  #            "device1" = { id = "DEVICE-ID-GOES-HERE"; };
  #            "device2" = { id = "DEVICE-ID-GOES-HERE"; };
  #          };
  #          folders = {
  #            "Documents" = {         # Name of folder in Syncthing, also the folder ID
  #              path = "/home/myusername/Documents";    # Which folder to add to Syncthing
  #              devices = [ "device1" "device2" ];      # Which devices to share the folder with
  #            };
  #            "Example" = {
  #              path = "/home/myusername/Example";
  #              devices = [ "device1" ];
  #              ignorePerms = false;  # By default, Syncthing doesn't sync file permissions. This line enables it for this folder.
  #            };
  #          };
  #        };
  #      };
  #    };
  #
}
