{
  disks ? [ "/dev/sda" ],
  ...
}:
{
  disk = {
    ssd = {
      type = "disk";
      device = builtins.elemAt disks 0;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            name = "boot";
            type = "EF00";
            size = "512M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
                "noatime"
              ];
              extraArgs = [
                "-n"
                "BOOT"
              ];
            };
          };
          swap = {
            name = "swap";
            size = "2048M";
            content = {
              type = "swap";
              randomEncryption = false;
              extraArgs = [
                "--label"
                "SWAP"
              ];
            };
          };
          nix = {
            name = "nix";
            size = "20G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
              mountOptions = [
                "defaults"
                "noatime"
              ];
              extraArgs = [
                "-L"
                "NIX"
              ];
            };
          };
          home = {
            name = "home";
            size = "20G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
              mountOptions = [
                "defaults"
                "noatime"
              ];
              extraArgs = [
                "-L"
                "HOME"
              ];
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
                "noatime"
              ];
              extraArgs = [
                "-L"
                "ROOT"
              ];
            };
          };
        };
      };
    };
  };
}
