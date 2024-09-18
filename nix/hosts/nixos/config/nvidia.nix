{
  config,
  lib,
  pkgs,
  ...
}:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
{
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    # driSupport = true; # deprecated
    extraPackages = with pkgs; [
      vaapiVdpau
      nvidia-vaapi-driver
      intel-media-driver
    ];
  };

  hardware.opengl.driSupport32Bit = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, but may help with sleep issues.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    powerManagement.finegrained = false;

    # Open-source kernel module (not needed for 1080 Ti)
    open = false;

    # Enable the Nvidia settings menu, accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Prime is not typically needed for desktop GPUs, but included for completeness
    # Laptop Configuration: Hybrid Graphics
    # prime = {
    #   sync.enable = false;
    #   offload = {
    #     enable = true;
    #     enableOffloadCmd = true;
    #   };
    # Make sure to use the correct Bus ID values for your system!
    # intelBusId = "PCI:0:2:0";
    # nvidiaBusId = "PCI:14:0:0";
    # };
  };

  # Force full composition pipeline to reduce tearing
  hardware.nvidia.forceFullCompositionPipeline = true;

  # Add nvidia_drm.modeset=1 to your kernel parameters
  boot.kernelParams = [ "nvidia_drm.modeset=1" ];

  # Disable nouveau driver to avoid conflicts
  boot.blacklistedKernelModules = [ "nouveau" ];

  # Load nvidia driver on boot
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
}
