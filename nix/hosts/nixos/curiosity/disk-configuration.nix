{ ... }:
{
  disko = {
    devices.disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          boot = {
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
            };
            label = "BOOT";
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
            };
            label = "ROOT";
          };
          swap = {
            name = "swap";
            size = "2G";
            content = {
              type = "swap";
              randomEncryption = false;
            };
            label = "SWAP";
          };
        };
      };
    };
  };
}
