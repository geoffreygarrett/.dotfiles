{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    forceFullCompositionPipeline = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  # Only include necessary screen options
  services.xserver.screenSection = ''
    Option "ForceFullCompositionPipeline" "on"
    Option "AllowIndirectGLXProtocol" "off"
    Option "TripleBuffer" "on"
  '';

  environment.systemPackages = with pkgs; [
    nvidia-vaapi-driver
    glxinfo
  ];
}
