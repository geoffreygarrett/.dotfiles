# nix/overlays/darwin-networking-hosts-overlay.nix
final: prev: {
  darwinModules = prev.darwinModules // {
    networking-hosts = { lib, config, pkgs, ... }: {
      options = {
        networking.hosts = lib.mkOption {
          type = lib.types.attrsOf (lib.types.listOf lib.types.str);
          description = "Locally defined maps of hostnames to IP addresses.";
          default = { };
          example = {
            "127.0.0.1" = [ "foo.local" ];
            "192.168.1.1" = [ "fileserver.local" ];
          };
        };

        networking.extraHosts = lib.mkOption {
          type = lib.types.lines;
          description = "Additional entries to append to /etc/hosts.";
          default = "";
        };

        networking.hostFiles = lib.mkOption {
          type = lib.types.listOf lib.types.path;
          description = "Extra files to append to /etc/hosts.";
          default = [ ];
        };
      };

      config = {
        environment.etc.hosts = {
          text = ''
            ## Host Database
            ##
            127.0.0.1   localhost
            ::1         localhost
            ${lib.concatMapStrings (ip: "${ip} ${lib.concatStringsSep " " config.networking.hosts.${ip}}\n") (lib.attrNames config.networking.hosts)}
            ${config.networking.extraHosts}
          '';
          source = pkgs.concatText "hosts" config.networking.hostFiles;
        };
      };
    };
  };
}
