{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.nix-on-droid.terminal.font;
in
{
  options.nix-on-droid.terminal.font = {
    enable = mkEnableOption "Custom font for Nix-on-Droid terminal";

    path = mkOption {
      type = types.path;
      example = "/path/to/your/custom-font.ttf";
      description = ''
        Path to the custom TTF font file.
        This should be a single TTF file containing all required glyphs.
      '';
    };
  };

  config = mkIf cfg.enable {
    build.activation.setupCustomFont = ''
      # Docstring: Custom Font Setup for Nix-on-Droid
      #
      # Font facts:
      # * In normal nix-on-droid usage (just running the terminal), none of the
      #   Linux/home-manager font configuration facilities matter, fontconfig is ignored.
      # * The only thing that renders fonts is the fork of the Termux app used by Nix-on-Droid.
      # * The fork has the styling addon baked in, so it looks for a `~/.termux/font.ttf`.
      # * The font file must be a regular file and not a symlink to `/nix/store`.
      # * Termux terminal emulator has limited font-rendering capabilities,
      #   even doing obliques instead of italics.
      # * There's no family detection or fallback chain. One TTF file rules all.

      $VERBOSE_ECHO "Setting up custom font..."
      $DRY_RUN_CMD mkdir -p "${config.user.home}/.termux"
      $DRY_RUN_CMD cp ${cfg.path} "${config.user.home}/.termux/font.ttf"
      $DRY_RUN_CMD chmod 644 "${config.user.home}/.termux/font.ttf"
    '';

    #    environment.shellAliases = {
    #      update-font = "nix-on-droid switch --flake '.#'";
    #    };

    environment.motd = mkIf cfg.enable ''
      echo "Custom font is enabled. To update the font, modify your configuration and run 'update-font'."
    '';
  };
}
