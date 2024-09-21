{
  config,
  lib,
  pkgs,
  ...
}:

{
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

  # SSH Server
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

}
