{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  programs.firefox = {
    enable = lib.mkIf (!pkgs.stdenv.isDarwin) true;
    profiles.geoffrey = {
      # Search settings
      search = import ./firefox/search.nix {
        inherit
          pkgs
          lib
          inputs
          config
          ;
      };
      bookmarks = import ./firefox/bookmarks.nix {
        inherit
          pkgs
          lib
          inputs
          config
          ;
      };

      # Browser settings
      settings = {
        "dom.security.https_only_mode" = true;
        "browser.download.panel.shown" = true;
        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;
      };

      # Custom CSS
      userChrome = (import ./firefox/user-chrome.nix { inherit pkgs config lib; });
      userContent = (import ./firefox/user-content.nix { inherit pkgs config lib; });

      # Extensions
      extensions = import ./firefox/extensions.nix { inherit inputs; };
    };
  };
}
