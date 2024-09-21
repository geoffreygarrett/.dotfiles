{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.hardware.focusrite-scarlett-solo-gen3;
in
{
  options.hardware.focusrite-scarlett-solo-gen3 = {
    enable = mkEnableOption "Focusrite Scarlett Solo Gen 3 support";
    defaultSampleRate = mkOption {
      type = types.int;
      default = 44100;
      description = "Default sample rate for the audio interface";
    };
    useAlsa = mkEnableOption "ALSA support" // {
      default = true;
    };
    usePulseAudio = mkEnableOption "PulseAudio support" // {
      default = true;
    };
    usePipeWire = mkEnableOption "PipeWire support" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # Common packages
    environment.systemPackages = with pkgs; [
      alsa-scarlett-gui
      pavucontrol
    ];

    # USB audio driver configuration
    boot.extraModprobeConfig = ''
      options snd_usb_audio vid=0x1235 pid=0x8210 device_setup=1
    '';

    # ALSA configuration
    #sound.enable = cfg.useAlsa;

    # PulseAudio configuration
    hardware.pulseaudio = mkIf (cfg.usePulseAudio && !cfg.usePipeWire) {
      enable = true;
      daemon.config = {
        default-sample-rate = cfg.defaultSampleRate;
        alternate-sample-rate = 48000;
      };
    };

    # PipeWire configuration
    services.pipewire = mkIf cfg.usePipeWire {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      # WirePlumber configuration
      wireplumber.enable = true;
      wireplumber.configPackages = [
        (pkgs.writeTextDir "share/wireplumber/main.lua.d/51-scarlett-solo-gen3.lua" ''
          table.insert(alsa_monitor.rules, {
            matches = {
              {
                { "device.name", "matches", "alsa_card.usb-Focusrite*" },
              },
            },
            apply_properties = {
              ["api.acp.probe-rate"] = ${toString cfg.defaultSampleRate},
            },
          })
        '')
      ];
    };

    # ALSA UCM configuration for better device support
    environment.etc."alsa/ucm2/USB-Audio/USB-Audio.conf".text = ''
      Syntax 2

      SectionUseCase."HiFi" {
        File "HiFi.conf"
        Comment "Default HiFi"
      }
    '';

    environment.etc."alsa/ucm2/USB-Audio/HiFi.conf".text = ''
      Syntax 2

      SectionVerb {
        EnableSequence [
          cset "name='Line Out Playback Switch' on"
          cset "name='Line Out Playback Volume' 100%"
          cset "name='Mic Capture Switch' on"
          cset "name='Mic Capture Volume' 50%"
        ]
      }

      SectionDevice."Line Out" {
        Comment "Line Out"

        EnableSequence [
          cset "name='Line Out Playback Switch' on"
        ]

        DisableSequence [
          cset "name='Line Out Playback Switch' off"
        ]

        Value {
          PlaybackPriority 100
          PlaybackPCM "hw:CARD=USB,DEV=0"
        }
      }

      SectionDevice."Mic" {
        Comment "Microphone"

        EnableSequence [
          cset "name='Mic Capture Switch' on"
        ]

        DisableSequence [
          cset "name='Mic Capture Switch' off"
        ]

        Value {
          CapturePriority 100
          CapturePCM "hw:CARD=USB,DEV=0"
        }
      }
    '';
  };
}
