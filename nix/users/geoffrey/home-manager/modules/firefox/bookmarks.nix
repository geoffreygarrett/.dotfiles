{ pkgs, ... }:

[
  {
    name = "NixOS";
    bookmarks = [
      {
        name = "Learning";
        bookmarks = [
          {
            name = "Install NixOS with Flake Configuration on Git";
            tags = [
              "nixos"
              "flakes"
              "installation"
            ];
            keyword = "nixos-flakes";
            url = "https://nixos.asia/en/nixos-install-flake";
          }
          {
            name = "NixOS on Raspberry Pi 3B - myme.no Guide";
            tags = [
              "nixos"
              "raspberry-pi"
              "setup"
            ];
            keyword = "nixos-rpi3";
            url = "https://myme.no/posts/2022-12-01-nixos-on-raspberrypi.html";
          }
        ];
      }
      {
        name = "Security & Configuration";
        bookmarks = [
          {
            name = "Secrets Management";
            bookmarks = [
              {
                name = "Unmoved Centre - Secrets Management Guide";
                tags = [
                  "nixos"
                  "secrets-management"
                  "sops"
                ];
                keyword = "nixos-secrets";
                url = "https://unmovedcentre.com/posts/secrets-management/";
              }
              {
                name = "Yubikey Integration";
                bookmarks = [
                  {
                    name = "Reddit - Yubikey + GPG Key + sops-nix Setup";
                    tags = [
                      "nixos"
                      "secrets"
                      "sops"
                      "yubikey"
                      "gpg"
                    ];
                    keyword = "nixos-yubikey-sops";
                    url = "https://www.reddit.com/r/NixOS/comments/1dbalru/yubikey_gpg_key_sopsnix/";
                  }
                  {
                    name = "Reddit - Sops-nix and Yubikey Integration";
                    tags = [
                      "nixos"
                      "secrets"
                      "sops"
                      "yubikey"
                    ];
                    keyword = "nixos-sops-yubikey";
                    url = "https://www.reddit.com/r/NixOS/comments/1bqwbsj/sopsnix_and_yubikey/";
                  }
                ];
              }
            ];
          }
        ];
      }
      {
        name = "Setup Guides";
        bookmarks = [
          {
            name = "A GPU Passthrough Setup for NixOS (With VR passthrough too)";
            tags = [
              "nixos"
              "gpu"
              "passthrough"
              "vfio"
              "virtualization"
            ];
            keyword = "nixos-gpu-passthrough";
            url = "https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/";
          }
          {
            name = "NixOS on Raspberry Pi 4 with SSD Boot";
            tags = [
              "nixos"
              "raspberry-pi"
              "ssd"
              "boot"
            ];
            keyword = "nixos-rpi4-ssd";
            url = "https://discourse.nixos.org/t/install-nixos-on-raspberry-pi-4-ssd/22788/8";
          }
          {
            name = "NixOS Config (RPi4+UEFI+SSD Boot)";
            tags = [
              "nixos"
              "raspberry-pi"
              "ssd"
              "uefi"
              "boot"
            ];
            keyword = "nixos-rpi4-uefi-ssd";
            url = "https://codeberg.org/kotatsuyaki/rpi4-usb-uefi-nixos-config";
          }
          {
            name = "NixOS on Raspberry Pi 4 with Encrypted Filesystem";
            tags = [
              "nixos"
              "raspberry-pi"
              "luks"
              "encryption"
            ];
            keyword = "nixos-rpi4-luks";
            url = "https://thenegation.hashnode.dev/nixos-rpi4-luks";
          }
        ];
      }
      {
        name = "Resources";
        bookmarks = [
          {
            name = "Awesome Nix - Curated List of Nix Resources";
            tags = [
              "nix"
              "nixos"
              "package-manager"
              "linux"
              "open-source"
              "devops"
              "system-administration"
            ];
            keyword = "awesome-nix";
            url = "https://github.com/nix-community/awesome-nix";
          }
          {
            name = "Home Manager Options";
            tags = [
              "nixos"
              "home-manager"
              "configuration"
            ];
            keyword = "home-manager-options";
            url = "https://nix-community.github.io/home-manager/options.xhtml";
          }
        ];
      }
      {
        name = "Projects";
        bookmarks = [
          {
            name = "NixOS Raspberry Pi Cluster";
            bookmarks = [
              {
                name = "Setup Raspberry Pi Cluster with K3s and NixOS";
                tags = [
                  "nixos"
                  "raspberry-pi"
                  "k3s"
                  "cluster"
                ];
                keyword = "nixos-rpi-k3s-cluster";
                url = "https://haseebmajid.dev/series/setup-raspberry-pi-cluster-with-k3s-and-nixos/";
              }
            ];
          }
        ];
      }
    ];
  }
  {
    name = "Other Interests";
    bookmarks = [
      {
        name = "Academic";
        bookmarks = [
          {
            name = "Systems Engineering";
            bookmarks = [
              {
                name = "Fundamentals of Systems Engineering";
                tags = [
                  "systems"
                  "engineering"
                ];
                keyword = "systems-engineering";
                url = "https://ocw.mit.edu/courses/16-842-fundamentals-of-systems-engineering-fall-2015/";
              }
            ];
          }
        ];
      }
      {
        name = "Blogs";
        bookmarks = [
          {
            name = "astrid dot tech";
            tags = [
              "nixos"
              "newsletter"
            ];
            keyword = "astrid-dot-tech";
            url = "https://astrid.tech/";
          }
        ];
      }
      {
        name = "Podcasts & Interviews";
        bookmarks = [
          {
            name = "Full Time Nix - Interview with Jonathan Ringer";
            tags = [
              "nix"
              "nixos"
              "development"
            ];
            keyword = "fulltime-nix-jonathan";
            url = "https://fulltimenix.com/episodes/jonathan-ringer";
          }
        ];
      }
    ];
  }
]
