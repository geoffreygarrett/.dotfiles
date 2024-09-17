{ config, pkgs, ... }:
let

  hyperfluent-theme = pkgs.fetchFromGitHub {
    owner = "Coopydood";
    repo = "HyperFluent-GRUB-Theme";
    rev = "v1.0.1";
    sha256 = "0gyvms5s10j24j9gj480cp2cqw5ahqp56ddgay385ycyzfr91g6f";
  };

in
{
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

  fileSystems."/boot/efi" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
    options = [ "defaults" "noatime" "nofail" ];
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];
}
