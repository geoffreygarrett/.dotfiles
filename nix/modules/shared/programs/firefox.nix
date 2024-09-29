{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  programs.firefox = {
    enable = lib.mkIf (!pkgs.stdenv.isDarwin) true;
    profiles.geoffrey = {
      # Search settings
      search = {
        force = true;
        engines = {
          "Anaconda Packages" = {
            iconUpdateURL = "https://www.google.com/s2/favicons?domain=anaconda.org";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            urls = [
              {
                template = "https://anaconda.org/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = [ "@ap" ];
          };
          "NixOS Wiki" = {
            urls = [ { template = "https://nixos.wiki/index.php?search={searchTerms}"; } ];
            iconUpdateURL = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
        };
      };

      # Bookmarks
      bookmarks = [
        {
          name = "Plan To Listen";
          bookmarks = [
            {
              name = "[Podcast] FTN interview with Jonathan Ringer";
              tags = [
                "podcast"
                "nixos"
              ];
              url = "https://fulltimenix.com/episodes/jonathan-ringer";
            }
          ];
        }
        {
          name = "NixOS Secrets Management";
          bookmarks = [
            {
              name = "Unmoved Centre - Secrets Management";
              tags = [
                "nixos"
                "secrets"
                "sops"
              ];
              url = "https://unmovedcentre.com/posts/secrets-management/";
            }
            {
              name = "The Negation - NixOS on Raspberry Pi 4 with Encrypted Filesystem";
              url = "https://thenegation.hashnode.dev/nixos-rpi4-luks";
              tags = [
                "nixos"
                "rpi4"
                "luks"
              ];
            }
            {
              name = "Yubikey with SOPS";
              bookmarks = [
                {
                  name = "Reddit - Yubikey + gpg key + sops-nix";
                  tags = [
                    "nixos"
                    "secrets"
                    "sops"
                    "yubikey"
                  ];
                  url = "https://www.reddit.com/r/NixOS/comments/1dbalru/yubikey_gpg_key_sopsnix/";
                }
                {
                  name = "Reddit - Sops-nix and Yubikey";
                  tags = [
                    "nixos"
                    "secrets"
                    "sops"
                    "yubikey"
                  ];
                  url = "https://www.reddit.com/r/NixOS/comments/1bqwbsj/sopsnix_and_yubikey/";
                }
              ];
            }
          ];
        }
        {
          name = "NixOS Configuration";
          bookmarks = [
            {
              name = "Home Manager";
              tags = [
                "nixos"
                "firefox"
              ];
              keyword = "nixos";
              url = "https://nix-community.github.io/home-manager/options.xhtml";
            }
          ];
        }
        {
          name = "NixOS Setup";
          toolbar = true;
          bookmarks = [
            {
              name = "[myme.no] NixOS: On Raspberry Pi 3B";
              tags = [ "nixos" ];
              keyword = "nixos";
              url = "https://myme.no/posts/2022-12-01-nixos-on-raspberrypi.html";
            }
            {
              name = "Install NixOS with Flake configuration on Git";
              tags = [ "nixos" ];
              keyword = "nixos";
              url = "https://nixos.asia/en/nixos-install-flake";
            }
            {
              name = "NixOS Config (RPi4+UEFI+SSD boot)";
              tags = [
                "nixos"
                "ssd"
                "rpi4"
                "uefi"
              ];
              keyword = "nixos";
              url = "https://codeberg.org/kotatsuyaki/rpi4-usb-uefi-nixos-config";
            }
            {
              name = "Install NixOS on Raspberry Pi 4 SSD";
              url = "https://discourse.nixos.org/t/install-nixos-on-raspberry-pi-4-ssd/22788/8";
              keyword = "nixos";
              tags = [
                "nixos"
                "rpi4"
                "ssd"
              ];
            }
          ];
        }
        # {
        #   name = "NixOS Configuration";
        #   folder = true;
        #   bookmarks = [
        #     {
        #       name = "[myme.no] NixOS: On Raspberry Pi 3B";
        #       url = "https://myme.no/posts/2022-12-01-nixos-on-raspberrypi.html";
        #     }
        #     {
        #       name = "Stack Overflow";
        #       url = "https://stackoverflow.com";
        #     }
        #   ];
        # }
      ];

      # Browser settings
      settings = {
        "dom.security.https_only_mode" = true;
        "browser.download.panel.shown" = true;
        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;
      };

      # Custom CSS
      #userChrome = builtins.readFile ./userChrome.css;

      # Extensions
      extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
        bitwarden
        ublock-origin
        sponsorblock
        darkreader
        tridactyl
        metamask
        sidebery
        youtube-shorts-block
      ];
      #  extensions = with inputs.firefox-addons.packages.${system}; [
      #    bitwarden
      #    ublock-origin
      #    sponsorblock
      #    darkreader
      #    tridactyl
      #    youtube-shorts-block
      #  ];
    };
  };
}
