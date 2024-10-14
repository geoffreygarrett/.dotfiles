{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:

let
  readYaml =
    path:
    let
      jsonFile =
        pkgs.runCommand "yaml-to-json"
          {
            nativeBuildInputs = [ pkgs.remarshal ];
            allowSubstitutes = false;
          }
          ''
            remarshal -if yaml -i ${path} -of json -o $out
          '';
    in
    builtins.fromJSON (builtins.readFile jsonFile);

  bookmarksYaml = readYaml ./firefox/bookmarks.yaml;
in
{
  programs.firefox = {
    enable = lib.mkIf (!pkgs.stdenv.isDarwin) true;
    profiles.geoffrey = {
      search = import ./firefox/search.nix {
        inherit
          pkgs
          lib
          inputs
          config
          ;
      };
      bookmarks = bookmarksYaml;
      settings = {
        "dom.security.https_only_mode" = true;
        "browser.download.panel.shown" = true;
        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;
      };
      userChrome = import ./firefox/user-chrome.nix { inherit pkgs config lib; };
      userContent = import ./firefox/user-content.nix { inherit pkgs config lib; };
      extensions = import ./firefox/extensions.nix { inherit inputs pkgs; };
    };
  };
}
