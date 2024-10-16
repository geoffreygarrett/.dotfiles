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
  theme = config.colorScheme.palette;
  material-fox-chrome-original = pkgs.fetchzip {
    url = "https://github.com/edelvarden/material-fox-updated/releases/download/v1.2.8/chrome.zip";
    sha256 = "sha256-8Z1CaYvbf24rqJc/8TDEScRyKkeTSN2Vhb4jERrbxRQ=";
  };

  # Create the custom.css file with our theme
  customCss = pkgs.writeText "custom.css" ''
    .search-one-offs {
       display: flex !important;
    }
    @media (-moz-bool-pref: "userChrome.nixus-base16-theme") {
      :root,
      html,
      body {
        --md-accent-color: #${theme.base0D} !important;
        --md-background-color-0: #${theme.base00} !important;
        --md-background-color-50: #${theme.base01} !important;
        --md-background-color-100: #${theme.base02} !important;
        --md-text-primary: #${theme.base05} !important;
        --md-text-secondary: #${theme.base04} !important;
        --md-menu-background-color: #${theme.base01} !important;
        --md-menu-background-color-hover: #${theme.base02} !important;
        --md-menu-border-color: #${theme.base03} !important;
        --md-icon-color-primary: #${theme.base05} !important;
        --md-icon-color-secondary: #${theme.base04} !important;
        --md-content-separator-color: #${theme.base03} !important;
        --md-selection-text-color: #${theme.base00} !important;
        --md-selection-background-color: #${theme.base05} !important;
      }
    }
  '';

  # Modify the chrome directory
  material-fox-chrome = pkgs.runCommand "material-fox-chrome" { } ''
    cp -r ${material-fox-chrome-original}/* .
    cp ${customCss} custom.css
    chmod -R +w .
    mkdir $out
    cp -r * $out/
  '';
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
      # bookmarks = bookmarksYaml;
      bookmarks = import ./firefox/bookmarks.nix {
        inherit
          pkgs
          lib
          inputs
          config
          bookmarksYaml
          ;
      };
      settings = {
        "dom.security.https_only_mode" = true;
        "browser.download.panel.shown" = true;
        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
        "layout.css.color-mix.enabled" = true;
        "browser.tabs.inTitlebar" = 1;
        "browser.compactmode.show" = true;
        "devtools.chrome.enabled" = true;
        "userChrome.ui-chrome-refresh" = true;
        "userChrome.nixus-base16-theme" = true;
      };
      userChrome = ''
        @import url("${material-fox-chrome}/userChrome.css");
      '';
      userContent = ''
        @import url("${material-fox-chrome}/userContent.css");
      '';
      extensions = import ./firefox/extensions.nix { inherit inputs pkgs; };
    };
  };
}
