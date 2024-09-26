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
          name = "wikipedia";
          tags = [ "wiki" ];
          keyword = "wiki";
          url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
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
