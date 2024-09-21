{
  config,
  lib,
  pkgs,
  user,
  ...
}:
{

  services = {
    syncthing = {
      enable = true;
      user = "${user}";
      dataDir = "${config.home.homeDirectory}/Documents";
      configDir = "${config.home.homeDirectory}/Documents/.config/syncthing";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      settings = {
        devices = {
          "device1" = {
            id = "DEVICE-ID-GOES-HERE";
          };
          "device2" = {
            id = "DEVICE-ID-GOES-HERE";
          };
        };
        listenAddresses = [
          # listenAddress in the syncthing documentation
          "relay://replay-server/?id=<device-id>"
        ];
        globalAnnounceServers = [
          # globalAnnounceServer in the syncthing documentation
          "https://relay-server/?id=<device-id>"
        ];
        folders = {
          "Documents" = {
            # Folder ID in Syncthing, also the name of folder (label) by default
            path = "${config.home.homeDirectory}/Documents"; # Which folder to add to Syncthing
            devices = [
              "device1"
              "device2"
            ]; # Which devices to share the folder with
          };
          "Example" = {
            label = "Private"; # Optional label for the folder
            path = "/home/myusername/Example";
            devices = [ "device1" ];
            ignorePerms = false; # By default, Syncthing doesn't sync file permissions. This line enables it for this folder.
          };
        };
      };
    };
  };

  # 22000 TCP and/or UDP for sync traffic
  # 21027/UDP for discovery
  # source: https://docs.syncthing.net/users/firewall.html
  networking.firewall.allowedTCPPorts = [ 22000 ];
  networking.firewall.allowedUDPPorts = [
    22000
    21027
  ];

  # services.syncthing.settings.gui = {
  #   user = "username";
  #   password = "password";
  # };
  # Alternatively, you can leave the GUI inaccessible from the web and forward it using SSH:
  #
  # $ ssh -L 9998:localhost:8384 user@syncthing-host
  #
  # Then open up 127.0.0.1:9998 to administer the node. 

  # Declarative node IDs
  #
  # If you set up Syncthing with the above configuration, you will still need to manually accept the connection from your other devices. If you want to make this automatic, you must also set the key.pem and cert.pem options:
  #
  # services = {
  #   syncthing = {
  #     key = "${</path/to/key.pem>}";
  #     cert = "${</path/to/cert.pem>}";
  #     ...
  # };
  #

  #   You can optionally include the key.pem and cert.pem files in the NixOS configuration using a tool like sops-nix. See Comparison of secret managing schemes.
  #
  # To generate a new key.cert and key.pem for a deployment, you can use the -generate argument:
  #
  # $ nix-shell -p syncthing --run "syncthing -generate=myconfig"
  # 2024/04/23 11:41:17 INFO: Generating ECDSA key and certificate for syncthing...
  # 2024/04/23 11:41:17 INFO: Device ID: DMWVMM6-MKEQVB4-I4UZTRH-5A6E24O-XHQTL3K-AAI5R5L-MXNMUGX-QTGRHQ2
  # 2024/04/23 11:41:17 INFO: Default folder created and/or linked to new config
  # $ ls myconfig/
  # cert.pem  config.xml  key.pem
  #

  # Disable default sync folder
  #
  # Syncthing creates a 'Sync' folder in your home directory every time it regenerates a configuration, even if your declarative configuration does not have this folder. You can disable that by setting the STNODEFAULTFOLDER environment variable:
  #
  # systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder
  #
  #

  #   Home-manager service
  #
  # https://github.com/nix-community/home-manager/blob/master/modules/services/syncthing.nix
}
