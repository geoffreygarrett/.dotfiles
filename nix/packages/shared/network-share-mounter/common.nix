# common.nix
{ lib }:

with lib;

{
  options = {
    services.networkShareMounter = {
      enable = mkEnableOption "Automatic network share mounting service";

      mounts = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              protocol = mkOption {
                type = types.enum [
                  "smb"
                  "afp"
                  "nfs"
                ];
                description = "Protocol to use for mounting (smb, afp, or nfs)";
              };
              host = mkOption {
                type = types.str;
                description = "Hostname or IP address of the network share";
              };
              share = mkOption {
                type = types.str;
                description = "Name of the share to mount";
              };
              mountPoint = mkOption {
                type = types.str;
                description = "Local mount point for the share";
              };
              username = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Username for authentication (if required)";
              };
              passwordFile = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "Path to file containing the password (if required)";
              };
              options = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Additional mount options";
              };
            };
          }
        );
        default = [ ];
        description = "List of network shares to mount";
      };
    };
  };

  config = mkIf config.services.networkShareMounter.enable {
    environment.systemPackages = with pkgs; [ coreutils ];
  };
}
