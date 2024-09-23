{
  config,
  user,
  self,
  pkgs,
  inputs,
  ...
}:
let
  hostname = "apollo";
  mainInterface = "eno2";
  displays = [
    {
      # (VG27A): 2560x1440 @ 144 Hz in 27″ [External]
      output = "DP-1";
      mode = "2560x1440";
      rate = "144";
      primary = true;
      position = {
        x = 0;
        y = 0;
      };
      scale = 1.0;
      rotation = "normal";
    }
    {
      # (Dell Inc. 32"): 3840x2160 @ 60 Hz in 32″ [External]
      output = "HDMI-2";
      mode = "3840x2160";
      rate = "60";
      primary = false;
      position = {
        x = 2560;
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
    ../../../modules/nixos/openrgb.nix
    ../../../modules/nixos/tailscale.nix
    ../../../modules/nixos/samba.nix
  ];

  hardware.nvidia.open = false; # Disable open source

  # All custom options originate from the shared options
  custom.openrgb.enable = true;

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
