{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.local.dock;
  inherit (pkgs) stdenv dockutil writeShellScript;

  # Function to escape spaces in paths
  escapePath = path: ''"${lib.escape [ ''"'' ] path}"'';

  # Function to get the app name from the path
  getAppName =
    path:
    let
      basename = builtins.baseNameOf (lib.removeSuffix "/" path);
    in
    lib.removeSuffix ".app" basename;

in
{
  options = {
    local.dock.enable = mkOption {
      description = "Enable dock";
      default = stdenv.isDarwin;
      example = false;
    };

    local.dock.entries = mkOption {
      description = "Entries on the Dock";
      type =
        with types;
        listOf (submodule {
          options = {
            path = lib.mkOption { type = str; };
            section = lib.mkOption {
              type = str;
              default = "apps";
            };
            options = lib.mkOption {
              type = str;
              default = "";
            };
          };
        });
      readOnly = true;
    };
  };

  config = mkIf cfg.enable (
    let
      normalize = path: if hasSuffix ".app" path then path + "/" else path;
      entryURI =
        path:
        "file://"
        + (builtins.replaceStrings
          [
            " "
            "!"
            "\""
            "#"
            "$"
            "%"
            "&"
            "'"
            "("
            ")"
          ]
          [
            "%20"
            "%21"
            "%22"
            "%23"
            "%24"
            "%25"
            "%26"
            "%27"
            "%28"
            "%29"
          ]
          (normalize path)
        );
      wantURIs = concatMapStrings (entry: "${entryURI entry.path}\n") cfg.entries;
      createEntries = concatMapStrings (
        entry:
        let
          escapedPath = escapePath entry.path;
          appName = getAppName entry.path;
        in
        ''
          echo "Processing ${appName}..."
          if ${dockutil}/bin/dockutil --list | grep -q ${escapedPath}; then
            ${dockutil}/bin/dockutil --no-restart --replacing ${escapedPath} ${escapedPath} --section ${entry.section} ${entry.options}
          else
            ${dockutil}/bin/dockutil --no-restart --add ${escapedPath} --section ${entry.section} ${entry.options}
          fi
        ''
      ) cfg.entries;

      dockSetupScript = writeShellScript "dock-setup" ''
        set -euo pipefail

        echo >&2 "Setting up the Dock..."

        current_dock() {
          ${dockutil}/bin/dockutil --list | ${pkgs.coreutils}/bin/cut -f2 | sort
        }

        desired_dock() {
          echo -n '${wantURIs}' | sort
        }

        if ! diff -q <(current_dock) <(desired_dock) >/dev/null 2>&1; then
          echo >&2 "Dock needs updating. Resetting..."
          if ! ${dockutil}/bin/dockutil --no-restart --remove all; then
            echo >&2 "Failed to remove all dock items"
            exit 1
          fi

          ${createEntries}

          if ! killall Dock; then
            echo >&2 "Failed to restart Dock"
            exit 1
          fi
          echo >&2 "Dock setup complete."
        else
          echo >&2 "Dock is already up to date."
        fi
      '';
    in
    {
      system.activationScripts.postUserActivation.text = ''
        ${dockSetupScript}
      '';
    }
  );
}
