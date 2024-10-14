{
  config,
  pkgs,
  lib,
  ...
}:
# Attribution
# https://blog.tcharles.fr/ddc-ci-screen-control-on-linux/

let
  name = "geoffrey";
  ddc-setbrightness = pkgs.writeShellScriptBin "ddc-setbrightness" ''
    #!/bin/bash
    # Usage: ddc-setbrightness 50
    ${pkgs.ddcutil}/bin/ddcutil --bus=0 setvcp 10 "$1" &
    ${pkgs.ddcutil}/bin/ddcutil --bus=1 setvcp 10 "$1" &
    wait
  '';

  ddc-switch-inputs = pkgs.writeShellScriptBin "ddc-switch-inputs" ''
    # Usage: ddc-switch-inputs 1
    case "$1" in
       1 )
          # Config 1: Main PC
          OUT=("0x0f" "0x20")
          ;;
       2 )
          # Config 2: Virtual machine
          OUT=("0x11" "0x21")
          ;;
       * )
          echo "Unknown input '$1'"
          exit 1
          ;;
    esac

    ${pkgs.ddcutil}/bin/ddcutil --bus=0 setvcp 60 ''${OUT[0]} &
    ${pkgs.ddcutil}/bin/ddcutil --bus=1 setvcp 60 ''${OUT[1]} &
    wait
  '';

  ddc-daylight = pkgs.writeShellScriptBin "ddc-daylight" ''
    # Usage: ddc-daylight night
    case "$1" in
       "day" )
          BRIGHTNESS=100
          TEMPERATURE=0x09
          ;;
       "evening" | "morning" )
          BRIGHTNESS=60
          TEMPERATURE=0x06
          ;;
       "night" )
          BRIGHTNESS=30
          TEMPERATURE=0x04
          ;;
       "dark" )
          BRIGHTNESS=0
          TEMPERATURE=0x04
          ;;
       * )
          echo "Unknown time of day '$1'"
          exit 1
          ;;
    esac

    ${pkgs.ddcutil}/bin/ddcutil --bus=0 setvcp 10 $BRIGHTNESS &
    ${pkgs.ddcutil}/bin/ddcutil --bus=1 setvcp 10 $BRIGHTNESS &
    ${pkgs.ddcutil}/bin/ddcutil --bus=0 setvcp 14 $TEMPERATURE &
    ${pkgs.ddcutil}/bin/ddcutil --bus=1 setvcp 14 $TEMPERATURE &
    wait
  '';

in
{
  # Enable i2c for DDC/CI
  hardware.i2c.enable = true;

  # Install ddcutil and our custom scripts
  environment.systemPackages = with pkgs; [
    ddcutil
    ddc-setbrightness
    ddc-switch-inputs
    ddc-daylight
  ];

  # Create a group for DDC control
  users.groups.ddc = { };

  # Add user to ddc group to allow monitor control without sudo
  users.users.${name}.extraGroups = [ "ddc" ];

  # Load i2c-dev kernel module on boot
  boot.kernelModules = [ "i2c-dev" ];

  # Add udev rule for DDC control
  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", GROUP="ddc", MODE="0660", PROGRAM="${pkgs.ddcutil}/bin/ddcutil --bus=%n getvcp 0x10"
  '';

  # Optionally, you can add a systemd service to set monitor configuration on boot
  systemd.services.monitor-config = {
    description = "Set monitor configuration on boot";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${ddc-daylight}/bin/ddc-daylight day";
      User = "${name}";
    };
  };

  # You might want to add options for autorandr, xrandr, or wlr-randr here as well
  # For example:
  # environment.systemPackages = with pkgs; [
  #   autorandr
  #   xorg.xrandr
  #   wlr-randr
  # ];
}
