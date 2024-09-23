{
  config,
  user,
  self,
  pkgs,
  inputs,
  keys,
  ...
}:
let

  hostname = "apollo";
  mainInterface = "eno2";
  displays = [
    {
      # (Dell Inc. 32"): 3840x2160 @ 60 Hz in 32″ [External]
      output = "HDMI-2";
      mode = "3840x2160";
      rate = "60";
      primary = false;
      position = {
        x = 0;
        y = 0;
      };
      scale = 1.0;
      rotation = "normal";
    }
    {
      # (VG27A): 2560x1440 @ 144 Hz in 27″ [External]
      output = "DP-1";
      mode = "2560x1440";
      rate = "144";
      primary = true;
      position = {
        x = 3840;
        y = 0;
      };
      scale = 1.0;
      rotation = "normal";
    }
  ];
  hyperfluent-theme = pkgs.fetchFromGitHub {
    owner = "Coopydood";
    repo = "HyperFluent-GRUB-Theme";
    rev = "v1.0.1";
    sha256 = "0gyvms5s10j24j9gj480cp2cqw5ahqp56ddgay385ycyzfr91g6f";
  };
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    # Intel(R) Core(TM) i9-9900KS (16) @ 5.00 GHz
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel

    # NVIDIA GeForce GTX 1080 Ti [Discrete]
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime

    # (Dell Inc. 32"): 3840x2160 @ 60 Hz in 32″ [External]
    inputs.nixos-hardware.nixosModules.common-hidpi
    #../../../modules/nixos/openrgb.nix
    ../../../modules/nixos/tailscale.nix
    ../../../modules/nixos/samba.nix
    ../shared.nix
    ./desktop.nix
  ];
  system.stateVersion = "24.11";
  services.automatic-timezoned.enable = true;
  # X11 display configuration (applicable to more than just BSPWM)
  services.xserver.displayManager.setupCommands = ''
    ${builtins.concatStringsSep "\n" (
      map (
        d:
        "${pkgs.xorg.xrandr}/bin/xrandr --output ${d.output} --mode ${d.mode} --rate ${d.rate} ${
          if d.primary then "--primary" else ""
        } --pos ${toString d.position.x}x${toString d.position.y} --scale ${toString d.scale}x${toString d.scale} --rotation ${d.rotation}"
      ) displays
    )}
  ''; # Enable the X11 windowing system.
  programs.zsh.enable = true;

  # It's me, it's you, it's everyone
  users.users = {
    ${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "docker"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = keys;
    };

    root = {
      openssh.authorizedKeys.keys = keys;
    };
  };

  hardware.nvidia.open = false; # Disable open source

  # All custom options originate from the shared options
  #custom.openrgb.enable = true;

  # boot.initrd.kernelModules = [
  #   "nvidia"
  #   "i915"
  #   "nvidia_modeset"
  #   "nvidia_uvm"
  #   "nvidia_drm"
  # ];

  boot.loader = {
    systemd-boot.enable = false;
    efi = {
      canTouchEfiVariables = false;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
      useOSProber = true;
      gfxmodeEfi = "2560x1440";
      theme = "${hyperfluent-theme}/nixos";
      extraConfig = ''
        GRUB_DEFAULT=saved
        GRUB_SAVEDEFAULT=true
      '';
    };
  };

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    interfaces."${mainInterface}".wakeOnLan.enable = true;
    useDHCP = false;
    dhcpcd.wait = "background";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
      ];
    };
  };

}
