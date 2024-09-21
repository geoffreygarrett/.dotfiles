# OepnRGB
# - https://nixos.wiki/wiki/OpenRGB
# - https://discourse.nixos.org/t/guide-to-setup-openrgb-on-nixos/9093/3
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.openrgb;
in
{
  options.custom.openrgb = {
    enable = lib.mkEnableOption "Enable OpenRGB";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [
      "i2c-dev"
      "i2c-piix4"
    ];
    hardware.i2c.enable = true;
    environment.systemPackages = with pkgs; [ openrgb-with-all-plugin ];
    services.udev.packages = with pkgs; [ openrgb-with-all-plugin ];
    services.hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb;
      server.port = 6742;
      motherboard = lib.mkDefault (
        if config.hardware.cpu.intel.updateMicrocode then
          "intel"
        else if config.hardware.cpu.amd.updateMicrocode then
          "amd"
        else
          null
      );
    };
  };
}
