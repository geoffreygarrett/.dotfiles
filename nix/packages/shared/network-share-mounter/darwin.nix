# darwin.nix
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.networkShareMounter;
  common = import ./common.nix { inherit lib; };

  getMountCommand =
    mount:
    let
      protocolPrefix =
        if mount.protocol == "smb" then
          "//"
        else if mount.protocol == "afp" then
          "afp://"
        else
          "";
      authPart = if mount.username != null then "${mount.username}:$(cat ${mount.passwordFile})@" else "";
      optionsPart = if mount.options != null then "-o ${mount.options}" else "";
      nfsMount = "${mount.host}:${mount.share} ${mount.mountPoint}";
      otherMount = "${protocolPrefix}${authPart}${mount.host}/${mount.share} ${mount.mountPoint}";
    in
    if mount.protocol == "nfs" then
      "mount -t nfs ${optionsPart} ${nfsMount}"
    else
      "mount -t ${mount.protocol} ${optionsPart} ${otherMount}";

  mkLaunchdAgent =
    mount:
    let
      mountName = builtins.replaceStrings [ "/" ] [ "-" ] mount.mountPoint;
    in
    nameValuePair "mountNetworkShare-${mountName}" {
      serviceConfig = {
        ProgramArguments = [
          "${pkgs.bash}/bin/bash"
          "-c"
          "mkdir -p ${mount.mountPoint} && ${getMountCommand mount}"
        ];
        RunAtLoad = true;
        KeepAlive = false;
      };
    };
in
{
  imports = [ common ];
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.osxfuse ];
    launchd.user.agents = listToAttrs (map mkLaunchdAgent cfg.mounts);
  };
}
