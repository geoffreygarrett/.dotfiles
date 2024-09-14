{ }

#{
#  disko.devices = {
#    nvme0n1 = {
#      device = "/dev/nvme0n1";
#      type = "disk";
#      content = {
#        type = "gpt";
#        partitions = {
#          # Reference existing ESP without formatting it
#          ESP = {
#            number = 1; # Assuming partition 1 is the ESP
#            type = "ef00";
#            content = {
#              type = "filesystem";
#              format = "vfat";
#              mountpoint = "/boot";
#              reformat = false; # Do not format the existing ESP
#            };
#          };
#
#          # NixOS Root Partition
#          nixos-root = {
#            # Let the system decide the start; it will use available unallocated space
#            size = "50G"; # Adjust based on your needs
#            type = "8304"; # Linux x86-64 root partition
#            content = {
#              type = "filesystem";
#              format = "ext4"; # Or btrfs, zfs
#              mountpoint = "/";
#            };
#          };
#
#          # NixOS Home Partition (Optional)
#          nixos-home = {
#            size = "100G"; # Adjust as needed
#            type = "8302"; # Linux /home partition
#            content = {
#              type = "filesystem";
#              format = "ext4"; # Or preferred filesystem
#              mountpoint = "/home";
#            };
#          };
#
#          # Swap Partition (Optional)
#          swap = {
#            size = "8G"; # Adjust based on your RAM and hibernation needs
#            type = "8200"; # Swap partition type
#            content = {
#              type = "swap";
#            };
#          };
#
#          # Shared Data Partition (Optional)
#          shared-data = {
#            size = "100G"; # Adjust as needed
#            type = "0700"; # Microsoft basic data partition
#            content = {
#              type = "filesystem";
#              format = "ntfs"; # Or exfat
#              mountpoint = "/mnt/shared"; # Or another mount point
#            };
#          };
#        };
#      };
#    };
#  };
#}
