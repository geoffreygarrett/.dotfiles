{
  pkgs,
  lib,
  config,
  ...
}:

let
  base16 = config.colorScheme.palette;
  modules = import ./config/modules {
    inherit
      pkgs
      lib
      config
      base16
      ;
  };
in
{
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      alsaSupport = true;
      pulseSupport = true;
      i3Support = true;
    };
    script = ''
      polybar main-left &
      polybar main-right &
    '';
    config = lib.mkMerge [
      (import ./config/bars.nix {
        inherit
          pkgs
          lib
          config
          base16
          ;
      })
      modules
    ];
  };
}
