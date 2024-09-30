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
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [
                "-f"
                "-L"
                "ROOT"
              ];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
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
        };
      };
    };
  };
}
