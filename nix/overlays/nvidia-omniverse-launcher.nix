final: prev:

let
  pname = "nvidia-omniverse-launcher";
  version = "1.0.1";
  name = "${pname}-${version}";
  lib = prev.lib;

  src = prev.fetchurl {
    url = "https://install.launcher.omniverse.nvidia.com/installers/omniverse-launcher-linux.AppImage";
    sha256 = "0h86yizk2n6kifhs08d089n3rrqz47avpbgm0880qb7wqqbhwkgg";
  };

  logoSrc = prev.fetchurl {
    url = "https://enterprise.launcher.omniverse.nvidia.com/a402db04407df6af8553201e4457fd24.png";
    sha256 = "158nh4fqx3fcvy8ia7h3p7arc4lcnrxd8g3zq6c07grd2lsh4lbv";
  };

  mkOmniverseLauncher =
    {
      home ? "$HOME",
      settings ? { },
    }:
    let
      # Extract settings
      firewallWarning = settings.firewallWarning or true;
      requiredPorts = [
        4070
        57621
        5353
      ];
      warningMessage = lib.optionalString firewallWarning ''
        echo "Warning: NVIDIA Omniverse Launcher requires the following ports to be open for proper functionality: ${lib.concatStringsSep ", " (map toString requiredPorts)}."
        echo "Please ensure these ports are open in your firewall configuration or set 'firewallWarning' to false to disable this warning."
      '';
    in
    prev.appimageTools.wrapType2 {
      inherit name src;

      extraInstallCommands = ''
        mv $out/bin/${name} $out/bin/${pname}

        # Create wrapper script
        cat > $out/bin/${pname}-wrapper << EOF
        #!/usr/bin/env bash
        export LD_LIBRARY_PATH=${
          prev.lib.makeLibraryPath [
            prev.libglvnd
            prev.xorg.libxcb
          ]
        }:$LD_LIBRARY_PATH

        exec $out/bin/${pname} "\$@"
        EOF
        chmod +x $out/bin/${pname}-wrapper

        # Create desktop file with URL scheme handler
        mkdir -p $out/share/applications
        cat > $out/share/applications/${pname}.desktop << EOF
        [Desktop Entry]
        Name=NVIDIA Omniverse Launcher
        Exec=$out/bin/${pname}-wrapper %u
        Icon=$out/share/icons/hicolor/512x512/apps/${pname}.png
        Type=Application
        Categories=Graphics;3DGraphics;
        MimeType=x-scheme-handler/omniverse-launcher;x-scheme-handler/omniverse;
        EOF

        # Use the fetched logo as the icon
        mkdir -p $out/share/icons/hicolor/512x512/apps
        cp ${logoSrc} $out/share/icons/hicolor/512x512/apps/${pname}.png
      '';

      postBuild = ''
        ${warningMessage}
      '';

      extraPkgs =
        pkgs: with pkgs; [
          glib
          libsecret
          libGL
          libdrm
          mesa
          mesa.drivers
          xorg.libxcb
          xorg.libX11
          xorg.libXcomposite
          xorg.libXcursor
          xorg.libXdamage
          xorg.libXext
          xorg.libXfixes
          xorg.libXi
          xorg.libXrandr
          xorg.libXrender
          xorg.libXtst
          xorg.libXScrnSaver
          zlib
          dbus
          libnotify
          fuse
          xdg-utils
          lshw
        ];

      meta = with prev.lib; {
        description = "NVIDIA Omniverse Launcher";
        homepage = "https://www.nvidia.com/en-us/omniverse/";
        license = licenses.unfree;
        maintainers = with maintainers; [ geoffreygarrett ];
        platforms = [ "x86_64-linux" ];
      };
    };

in
{
  nvidia-omniverse-launcher = mkOmniverseLauncher { };

  # Home Manager module
  homeManagerModules.nvidia-omniverse-launcher =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    with lib;
    let
      cfg = config.programs.nvidia-omniverse-launcher;
    in
    {
      options.programs.nvidia-omniverse-launcher = {
        enable = mkEnableOption "NVIDIA Omniverse Launcher";

        package = mkOption {
          type = types.package;
          default = pkgs.nvidia-omniverse-launcher;
          description = "The NVIDIA Omniverse Launcher package to use.";
        };

        settings = mkOption {
          type = types.attrs;
          default = {
            firewallWarning = true;
            libraryPath = "${config.home.homeDirectory}/.local/share/ov/pkg";
            dataPath = "${config.home.homeDirectory}/.local/share/ov/data";
            cachePath = "${config.home.homeDirectory}/.cache/ov";
            contentPath = "${config.home.homeDirectory}/Downloads";
            logsPath = "${config.home.homeDirectory}/.nvidia-omniverse/logs";
          };
          description = ''
            Configuration settings for NVIDIA Omniverse Launcher.
            Includes paths for various data and cache directories and an option to enable/disable firewall warnings.
          '';
        };
      };

      config = mkIf cfg.enable {
        home.packages = [ cfg.package ];

        xdg.configFile."nvidia-omniverse/omniverse.toml".text = ''
          [paths]
          library_root = "${cfg.settings.libraryPath}"
          data_root = "${cfg.settings.dataPath}"
          cache_root = "${cfg.settings.cachePath}"
          content_root = "${cfg.settings.contentPath}"
          logs_root = "${cfg.settings.logsPath}"
        '';

        home.sessionVariables = {
          OMNIVERSE_LIBRARY_PATH = cfg.settings.libraryPath;
          OMNIVERSE_DATA_PATH = cfg.settings.dataPath;
          OMNIVERSE_CACHE_PATH = cfg.settings.cachePath;
          OMNIVERSE_CONTENT_PATH = cfg.settings.contentPath;
        };

        home.activation.registerOmniverseURLHandler = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          $DRY_RUN_CMD ${pkgs.xdg-utils}/bin/xdg-mime default nvidia-omniverse-launcher.desktop x-scheme-handler/omniverse-launcher
          $DRY_RUN_CMD ${pkgs.xdg-utils}/bin/xdg-mime default nvidia-omniverse-launcher.desktop x-scheme-handler/omniverse
        '';
      };
    };
}
