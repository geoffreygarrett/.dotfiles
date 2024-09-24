{
  user,
  pkgs,
  inputs,
  keys,
  ...
}:
let

  hostname = "apollo";
  mainInterface = "eno2";
  postSwitchHook = pkgs.writeShellScriptBin "autorandr-postswitchhook" ''
    # Reload bspwm
    ${pkgs.bspwm}/bin/bspc wm -r

    # Restart polybar
    ${pkgs.systemd}/bin/systemctl --user restart polybar
  '';

  hyperfluent-theme = pkgs.fetchFromGitHub {
    owner = "Coopydood";
    repo = "HyperFluent-GRUB-Theme";
    rev = "v1.0.1";
    sha256 = "0gyvms5s10j24j9gj480cp2cqw5ahqp56ddgay385ycyzfr91g6f";
  };
in
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  services.autorandr = {
    enable = true;
    defaultTarget = "dual-monitor";
    profiles = {
      "dual-monitor" = {
        fingerprint = {
          "DELL-32" = "00ffffffffffff0010aca3424c3331372120010380462778eabac5a9534ea6250e5054a54b00e1c0d100d1c0b300a94081808100714f4dd000a0f0703e8030203500b9882100001a000000ff004a345157584e330a2020202020000000fc0044454c4c20503332323351450a000000fd00184b1e8c3c000a202020202020014702032ab14e61605f101f0514041312110302016b030c001000383c2000200167d85dc401788003e20f03a36600a0f0703e8030203500b9882100001a565e00a0a0a0295030203500b9882100001a114400a08000255030203600b9882100001a00000000000000000000000000000000000000000000000000000000000000d9"; # Replace with actual EDID
          "ASUS-27" = "00ffffffffffff0006b32227010101010b1f0104b53c22783b9e20a8554ca0260e5054bfef00714f81809500d1c00101010101010101565e00a0a0a029503020350055502100001c000000fd003090e6e63c010a202020202020000000fc0056473237410a20202020202020000000ff004d334c4d51533132353838370a01b8020329f14e90111213040e0f1d1e1f1405403f2309070783010000e305e001e6060701737300e2006a59e7006aa0a067501520350055502100001a6fc200a0a0a055503020350055502100001a5aa000a0a0a046503020350055502100001a000000000000000000000000000000000000000000000000000000000000000032"; # Replace with actual EDID
        };
        config = {
          "DELL-32" = {
            enable = true;
            mode = "3840x2160";
            rate = "60.00";
            primary = false;
            position = "0x0";
            scale = {
              x = 1.0;
              y = 1.0;
            };
            rotate = "normal";
          };
          "ASUS-27" = {
            enable = true;
            mode = "2560x1440";
            rate = "144.00";
            primary = true;
            position = "3840x360";
            scale = {
              x = 1.0;
              y = 1.0;
            };
            rotate = "normal";
          };
        };
      };
    };
    hooks = {
      postswitch = {
        "refresh-wm-and-bar" = "${postSwitchHook}/bin/autorandr-postswitchhook";
      };
    };
  };

  imports = [
    # (Dell Inc. 32"): 3840x2160 @ 60 Hz in 32″ [External]
    # Intel(R) Core(TM) i9-9900KS (16) @ 5.00 GHz
    # NVIDIA GeForce GTX 1080 Ti [Discrete]
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-hidpi
    #../../../modules/nixos/openrgb.nix
    ../../../modules/nixos/tailscale.nix
    ../../../modules/nixos/samba.nix
    ../shared.nix
    ./desktop.nix
  ];
  system.stateVersion = "24.11";

  # FIXME: Just like with Windows, 2 hours early.
  # services.automatic-timezoned.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Johannesburg";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  # X11 display configuration
  # services.xserver.displayManager.setupCommands = ''
  #   ${builtins.concatStringsSep "\n" (
  #     map (
  #       d:
  #       "${pkgs.xorg.xrandr}/bin/xrandr --output ${d.output} --mode ${d.mode} --rate ${d.rate} ${
  #         if d.primary then "--primary" else ""
  #       } --pos ${toString d.position.x}x${toString d.position.y} --scale ${toString d.scale}x${toString d.scale} --rotation ${d.rotation}"
  #     ) displays
  #   )}
  # '';
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
