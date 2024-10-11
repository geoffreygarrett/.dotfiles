{
  pkgs,
  lib,
  inputs,
  config,
  runCommand,
  remarshal,
  ...
}:
let
  readYaml =
    path:
    let
      jsonOutputDrv =
        pkgs.runCommand "yaml-to-json"
          {
            nativeBuildInputs = [ pkgs.remarshal ];
            preferLocalBuild = true;
            allowSubstitutes = false;
          }
          ''
            remarshal -if yaml -i ${path} -of json -o $out || {
              echo "Error: Failed to parse YAML file ${path}" >&2
              exit 1
            }
          '';
    in
    builtins.fromJSON (builtins.readFile jsonOutputDrv);

  bookmarksYaml = readYaml ./firefox/bookmarks.yaml;
in

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
      bookmarks = bookmarksYaml;
      # bookmarks = import ./firefox/bookmarks.nix {
      #   inherit
      #     pkgs
      #     lib
      #     inputs
      #     config
      #     ;
      # };

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
      extensions = import ./firefox/extensions.nix { inherit inputs pkgs; };
    };
  };
}
