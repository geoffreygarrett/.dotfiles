{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.hardware.video.nvidia.gtx1080ti;
in
{
  options.hardware.video.nvidia.gtx1080ti = {
    enable = mkEnableOption "Enable support for NVIDIA GeForce GTX 1080 Ti";

    enableCuda = mkOption {
      type = types.bool;
      default = false;
      description = "Enable CUDA support";
    };

    enableVulkan = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Vulkan support";
    };

    enable32bit = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 32-bit support for compatibility with Steam and Wine";
    };

    forceFullCompositionPipeline = mkOption {
      type = types.bool;
      default = true;
      description = "Force full composition pipeline for better performance";
    };

    powerManagement = mkOption {
      type = types.bool;
      default = false;
      description = "Enable NVIDIA power management (not typically needed for desktop GPUs)";
    };
  };

  config = mkIf cfg.enable {
    hardware.opengl = {
      enable = true;
      driSupport32Bit = cfg.enable32bit;
      extraPackages =
        with pkgs;
        [
          vaapiVdpau
          libvdpau-va-gl
        ]
        ++ optionals cfg.enableVulkan [
          vulkan-loader
          vulkan-validation-layers
        ];
      extraPackages32 = mkIf cfg.enable32bit (
        with pkgs.pkgsi686Linux;
        [
          libva
          vaapiVdpau
          libvdpau-va-gl
        ]
      );
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = cfg.powerManagement;
        finegrained = cfg.powerManagement;
      };
      open = false;
      nvidiaSettings = true;
      package = mkIf cfg.enableCuda (
        let
          nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.stable;
        in
        nvidiaPackage.overrideAttrs (oldAttrs: {
          cudaSupport = true;
        })
      );
      forceFullCompositionPipeline = cfg.forceFullCompositionPipeline;
    };

    boot = {
      kernelParams = [ "nvidia-drm.modeset=1" ];
      blacklistedKernelModules = [ "nouveau" ];
      kernelModules = [ "nvidia" ];
      extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
    };

    environment.systemPackages = with pkgs; [
      nvtop
      glxinfo
    ];
  };
}
