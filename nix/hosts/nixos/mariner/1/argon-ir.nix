{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.argonIR;
in
{
  imports = [ ./irexec.nix ];
  options.services.argonIR = {
    enable = mkEnableOption "Argon case IR remote functionality";

    gpioPin = mkOption {
      type = types.int;
      default = 23;
      description = "GPIO pin number for IR receiver";
    };

    user = mkOption {
      type = types.str;
      default = "1000";
      description = "User ID for running PulseAudio commands";
    };
  };

  config = mkIf cfg.enable {
    # LIRC configuration
    services.lirc = {
      enable = true;
      options = ''
        [lircd]
        nodaemon        = False
        driver          = default
        device          = /dev/lirc0
        output          = /var/run/lirc/lircd
        pidfile         = /var/run/lirc/lircd.pid
        plugindir       = ${pkgs.lirc}/lib/lirc/plugins
        permission      = 666
        allow-simulate  = No
        repeat-max      = 600
      '';
      configs = [
        ''
          begin remote
            name  argon
            driver devinput
            bits           56
            eps            30
            aeps          100
            one             0     0
            zero            0     0
            pre_data_bits   72
            pre_data       0x23
            gap          107949
            toggle_bit_mask 0x0
            frequency    38000

            begin codes
              KEY_UP                   0x3F010000001197
              KEY_RIGHT                0x5B01000000118C
              KEY_DOWN                 0x59010000001193
              KEY_LEFT                 0x5701000000119C
              KEY_OK                   0x51010000001198
              KEY_INFO                 0x57010000001196
              KEY_HOME                 0x56010000001181
              KEY_BACK                 0x57010000001197
              KEY_VOLUMEUP             0x5A010000001194
              KEY_VOLUMEDOWN           0x50010000001198
              KEY_POWER                0x55010000001197
            end codes
          end remote
        ''
      ];
    };

    # irexec configuration
    services.irexec = {
      enable = true;
      configs = ''
        begin
          prog = irexec
          remote = *
          button = KEY_VOLUMEUP
          config = sudo -u '#${cfg.user}' XDG_RUNTIME_DIR=/run/user/${cfg.user} pactl set-sink-volume @DEFAULT_SINK@ +1%
          repeat = 1
          delay = 0
        end

        begin
          prog = irexec
          remote = *
          button = KEY_VOLUMEDOWN
          config = sudo -u '#${cfg.user}' XDG_RUNTIME_DIR=/run/user/${cfg.user} pactl set-sink-volume @DEFAULT_SINK@ -1%
          repeat = 1
          delay = 0
        end
      '';
    };

    # Kernel modules
    boot.kernelModules = [ "gpio-ir" ];

    # Raspberry Pi specific configurations
    # boot.loader.raspberryPi = {
    #   enable = mkDefault true;
    #   version = mkDefault 4;
    #   firmwareConfig = ''
    #     dtoverlay=gpio-ir,gpio_pin=${toString cfg.gpioPin}
    #   '';
    # };

    # Kernel parameters
    boot.kernelParams = [
      "8250.nr_uarts=1"
      "console=tty1"
      "cma=256M"
    ];

    # Additional required kernel modules
    boot.initrd.availableKernelModules = [
      "bcm2835_dma"
      "i2c_bcm2835"
      "vc4"
    ];

    # Ensure PulseAudio is enabled for volume control
    hardware.pulseaudio.enable = true;

    # Add user to required groups
    users.users.${cfg.user}.extraGroups = [
      "audio"
      "video"
    ];

    # Ensure the irexec service runs as root to execute sudo commands
    systemd.services.irexec.serviceConfig.User = "root";
  };
}
