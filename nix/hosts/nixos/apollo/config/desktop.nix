{
  pkgs,
  lib,
  user,
  config,
  ...
}:
{
  environment = {
    sessionVariables.GTK_THEME = "Adwaita:dark";
    systemPackages = with pkgs; [
      bspwm
      sxhkd
      rofi
      polybar
      feh
      # alacritty
      dunst
      libnotify
      maim
      papirus-icon-theme # Icons for rofi
      xclip
      picom
      playerctl
      wireplumber # For PulseWire
      bc # For brightnessctl
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };

  services.displayManager.defaultSession = "none+bspwm";
  services.redshift.enable = false;

  # Enable graphics driver in NixOS unstable/NixOS 24.11
  hardware.graphics.enable = true;
  # The same as above but for NixOS 23.11
  #hardware.opengl = {
  #  enable = true;
  #  driSupport = true;
  #};

  # Load "nvidia" driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = false;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently "beta quality", so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Better support for general peripherals
  services.libinput.enable = true;
  services.xserver = {
    enable = true;
    dpi = 96;
    # Key repeat settings
    # xset r rate 200 35
    # chefs kiss:  xset r rate 200 45
    autoRepeatDelay = 200; # Delay before key repeat starts (in milliseconds)
    autoRepeatInterval = 45; # Interval between key repeats (in milliseconds)
    displayManager = {
      # gdm.enable = true;
      lightdm = {
        enable = true;
        greeters.slick.enable = true;
        # defaultSession = "none+bspwm";
        background = ../../../../modules/shared/assets/wallpaper/login-wallpaper.png;
        # background = ../../../modules/shared/assets/wallpaper/login-wall
      };
    };
    windowManager.bspwm.enable = true;

    # This helps fix tearing of windows for Nvidia cards
    # screenSection = ''
    #   Option       "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
    #   Option       "AllowIndirectGLXProtocol" "off"
    #   Option       "TripleBuffer" "on"
    # '';
  };
  services.acpid.enable = true;
  home-manager.users.${user} =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {

      # Keyboard settings for X11 and some Wayland compositors
      home.keyboard = {
        layout = "us";
        #   repeat = {
        #     delay = 200;
        #     rate = 40;
        #   };
        # };

      };
    };
}
