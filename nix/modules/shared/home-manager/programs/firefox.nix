{ pkgs, inputs, ... }:
{
  programs.firefox = {
    enable = true;
    profiles.geoffrey = {
      # Search settings
      search = {
        force = true;
        engines = {
          "Anaconda Packages" = {
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
            icon = "data:image/png;base64,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";
            definedAliases = [ "@ap" ];
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
      ];

      # Browser settings
      settings = {
        "dom.security.https_only_mode" = true;
        "browser.download.panel.shown" = true;
        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;
      };

      # Custom CSS
      userChrome = ''
        /* some css */
      '';

      # Extensions
      extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
        bitwarden
        ublock-origin
        sponsorblock
        darkreader
        tridactyl
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
