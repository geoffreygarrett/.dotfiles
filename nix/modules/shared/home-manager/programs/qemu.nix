{ }
#{
#  config,
#  lib,
#  pkgs,
#  ...
#}:
#with lib;
#let
#  cfg = config.programs.qemu;

#  # Common configuration options
#  commonOptions = {
#    enable = mkEnableOption "QEMU";
#
#    package = mkOption {
#      type = types.package;
#      default = pkgs.qemu;
#      defaultText = literalExpression "pkgs.qemu";
#      description = "The QEMU package to use.";
#    };
#
#    hostCpuOnly = mkOption {
#      type = types.bool;
#      default = false;
#      description = "Whether to build QEMU for the host CPU only.";
#    };
#
#    enableKvm = mkOption {
#      type = types.bool;
#      default = true;
#      description = "Whether to enable KVM support.";
#    };
#
#    spiceSupport = mkOption {
#      type = types.bool;
#      default = true;
#      description = "Whether to enable SPICE support for remote desktop.";
#    };
#
#    vncSupport = mkOption {
#      type = types.bool;
#      default = true;
#      description = "Whether to enable VNC support.";
#    };
#
#    gtkSupport = mkOption {
#      type = types.bool;
#      default = false;
#      description = "Whether to enable GTK support for GUI.";
#    };
#
#    sdlSupport = mkOption {
#      type = types.bool;
#      default = false;
#      description = "Whether to enable SDL support for GUI.";
#    };
#
#    openGLSupport = mkOption {
#      type = types.bool;
#      default = true;
#      description = "Whether to enable OpenGL support.";
#    };
#
#    virglSupport = mkOption {
#      type = types.bool;
#      default = true;
#      description = "Whether to enable virgl support for 3D acceleration.";
#    };
#
#    pulseSupport = mkOption {
#      type = types.bool;
#      default = !pkgs.stdenv.isDarwin;
#      description = "Whether to enable PulseAudio support.";
#    };
#
#    smbdSupport = mkOption {
#      type = types.bool;
#      default = false;
#      description = "Whether to enable Samba support for file sharing.";
#    };
#
#    extraPackages = mkOption {
#      type = types.listOf types.package;
#      default = [ ];
#      description = "Extra packages to add to the QEMU environment.";
#    };
#  };
#
#  # Platform-specific options
#  darwinOptions = {
#    enableHvf = mkOption {
#      type = types.bool;
#      default = true;
#      description = "Whether to enable Hypervisor.framework support on macOS.";
#    };
#  };
#
#  linuxOptions = {
#    enableKsm = mkOption {
#      type = types.bool;
#      default = true;
#      description = "Whether to enable Kernel Same-page Merging (KSM) on Linux.";
#    };
#  };
#in
#{
#  options.programs.qemu =
#    commonOptions // (if pkgs.stdenv.isDarwin then darwinOptions else linuxOptions);
#
#  config = mkIf cfg.enable {
#    home.packages = [ cfg.package ] ++ cfg.extraPackages;
#
#    # QEMU configuration
#    home.file.".config/qemu/qemu.conf".text = ''
#      [global]
#      # Common settings
#      vm_memory = 2048
#      smp_cpus = 2
#      ${optionalString cfg.enableKvm "kvm_allowed = 1"}
#      ${optionalString cfg.spiceSupport "spice_port = 5930"}
#      ${optionalString cfg.vncSupport "vnc_port = 5900"}
#      ${optionalString cfg.openGLSupport "gl = on"}
#      ${optionalString cfg.virglSupport "virgl = on"}
#
#      # Platform-specific settings
#      ${optionalString pkgs.stdenv.isDarwin (optionalString cfg.enableHvf "hvf = on")}
#      ${optionalString pkgs.stdenv.isLinux (optionalString cfg.enableKsm "ksm = on")}
#    '';
#
#    # QEMU aliases for convenience
#    home.shellAliases = {
#      "qemu-system" = "${cfg.package}/bin/qemu-system-${pkgs.stdenv.hostPlatform.qemuArch}";
#    };
#  };
#}
