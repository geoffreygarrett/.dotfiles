# nixos.nix
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

  mkSystemdService =
    mount:
    let
      mountName = builtins.replaceStrings [ "/" ] [ "-" ] mount.mountPoint;
    in
    nameValuePair "mount-network-share-${mountName}" {
      description = "Mount network share ${mount.share}";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.bash}/bin/bash -c 'mkdir -p ${mount.mountPoint} && ${getMountCommand mount}'";
      };
    };

in
{
  imports = [ common ];

  config = mkIf cfg.enable {
    systemd.services = listToAttrs (map mkSystemdService cfg.mounts);
  };
}
