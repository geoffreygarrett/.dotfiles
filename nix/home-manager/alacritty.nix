{ config, pkgs, lib, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      # We delegate entirely to the standard config, even
      # though we could define it here in nix, so as to
      # keep as thin a layer as possible, making us less
      # nix dependent.
      import = [ "${config.alacritty.configContent}" ];
    };
  };
}
