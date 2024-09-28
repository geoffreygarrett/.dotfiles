{
  lib,
  pkgs,
  user,
  ...
}:
let
  nixConfig = (import ../../modules/shared/cachix { inherit pkgs lib; }).nix.settings;
in
# Transformation function to convert the DNS settings to networking.extraHosts format
{
  imports = [
    ../../modules/nix-on-droid
  ];

  # User Configuration
  user.shell = "${pkgs.zsh}/bin/zsh";

  # TODO: XREMAP!

  time.timeZone = "Africa/Johannesburg";
  # Nix Configuration
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    # package = pkgs.nix;
    # nixPath = [ ];
    # registry = { };
    substituters = nixConfig.substituters;
    trustedPublicKeys = nixConfig.trusted-public-keys;
  };

  # Environment Configuration
  environment = {
    packages = pkgs.callPackage ./../../modules/nix-on-droid/packages.nix { inherit pkgs; };
    etcBackupExtension = ".bak";
    sessionVariables = {
      EDITOR = "nvim";
      LANG = "en_US.UTF-8";
      PATH = "$HOME/.local/bin:$PATH";
      USER = "${user}";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_RUNTIME_DIR = "$HOME/.run";
      XDG_RUNTIME_DIR_FALLBACK = "$HOME/.run";
    };

    motd = ''
      \033[1;32mWelcome to Nix-on-Droid!\033[0m
      https://github.com/geoffreygarrett/.dotfiles
      Happy hacking!
    '';
  };

}
