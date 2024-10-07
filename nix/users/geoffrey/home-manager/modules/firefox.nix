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
          "Rust Docs" = {
            urls = [
              {
                template = "https://doc.rust-lang.org/std/?search={searchTerms}";
              }
            ];
            iconUpdateURL = "https://www.rust-lang.org/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@rust" ];
          };
          "GitHub Code" = {
            urls = [
              {
                template = "https://github.com/search?q={searchTerms}&type=code";
              }
            ];
            iconUpdateURL = "https://github.com/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@ghc" ];
          };
          "Stack Overflow" = {
            urls = [
              {
                template = "https://stackoverflow.com/search?q={searchTerms}";
              }
            ];
            iconUpdateURL = "https://cdn.sstatic.net/Sites/stackoverflow/Img/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@so" ];
          };
          "arXiv" = {
            urls = [
              {
                template = "https://arxiv.org/search/?query={searchTerms}&searchtype=all";
              }
            ];
            iconUpdateURL = "https://static.arxiv.org/static/browse/0.3.2.8/images/icons/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@arx" ];
          };
          "Google Scholar" = {
            urls = [
              {
                template = "https://scholar.google.com/scholar?q={searchTerms}";
              }
            ];
            iconUpdateURL = "https://scholar.google.com/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@gs" ];
          };
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
      bookmarks = [
        {
          name = "NixOS Resources";
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
              keyword = "nix";
              url = "https://github.com/nix-community/awesome-nix";
            }
            {
              name = "Home Manager Options";
              tags = [
                "nixos"
                "home-manager"
                "configuration"
              ];
              keyword = "home-manager";
              url = "https://nix-community.github.io/home-manager/options.xhtml";
            }
          ];
        }
        {
          name = "Academic Interests";
          bookmarks = [
            {
              name = "Fundamentals of Systems Engineering";
              tags = [
                "systems"
                "engineering"
              ];
              keyword = "systems";
              url = "https://ocw.mit.edu/courses/16-842-fundamentals-of-systems-engineering-fall-2015/";
            }
          ];
        }
        {
          name = "NixOS Learning";
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
              url = "https://haseebmajid.dev/series/setup-raspberry-pi-cluster-with-k3s-and-nixos/";
              # url = "https://haseebmajid.dev/posts/2023-11-30-til-how-to-use-sops-nix-with-colmena/";
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
              url = "https://fulltimenix.com/episodes/jonathan-ringer";
            }
          ];
        }
        {
          name = "NixOS Security & Configuration";
          bookmarks = [
            {
              name = "Secrets Management";
              bookmarks = [
                {
                  name = "Unmoved Centre - Secrets Management Guide";
                  tags = [
                    "nixos"
                    "nixos"
                    "secrets management"
                    "sops"
                  ];
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
                      url = "https://www.reddit.com/r/NixOS/comments/1bqwbsj/sopsnix_and_yubikey/";
                    }
                  ];
                }
              ];
            }
          ];
        }
        {
          name = "NixOS Setup Guides";
          toolbar = true;
          bookmarks = [
            {
              name = "Raspberry Pi Setups";
              bookmarks = [
                {
                  name = "NixOS on Raspberry Pi 3B - myme.no Guide";
                  tags = [
                    "nixos"
                    "raspberry-pi"
                    "setup"
                  ];
                  url = "https://myme.no/posts/2022-12-01-nixos-on-raspberrypi.html";
                }
                {
                  name = "NixOS on Raspberry Pi 4 with Encrypted Filesystem";
                  url = "https://thenegation.hashnode.dev/nixos-rpi4-luks";
                  tags = [
                    "nixos"
                    "raspberry-pi"
                    "luks"
                    "encryption"
                  ];
                }
                {
                  name = "NixOS on Raspberry Pi 4 with SSD Boot";
                  url = "https://discourse.nixos.org/t/install-nixos-on-raspberry-pi-4-ssd/22788/8";
                  tags = [
                    "nixos"
                    "raspberry-pi"
                    "ssd"
                    "boot"
                  ];
                }
                {
                  name = "NixOS on Raspberry Pi 4 with UEFI and SSD Boot";
                  tags = [
                    "nixos"
                    "raspberry-pi"
                    "ssd"
                    "uefi"
                    "boot"
                  ];
                  url = "https://codeberg.org/kotatsuyaki/rpi4-usb-uefi-nixos-config";
                }
              ];
            }
            {
              name = "NixOS with Flakes";
              tags = [
                "nixos"
                "flakes"
                "installation"
              ];
              url = "https://nixos.asia/en/nixos-install-flake";
            }
          ];
        }
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
