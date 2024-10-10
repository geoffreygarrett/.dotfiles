{
  pkgs,
  user,
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    # inputs.nix-homebrew.darwinModules.nix-homebrew
    # inputs.nixvim.nixDarwinModules.nixvim
    ./dock
    ./home-manager.nix
  ];

  # Additional useful configurations
  services = {
    # Enable and configure Yabai (tiling window manager)
    yabai = {
      enable = true;
      package = pkgs.yabai;
      enableScriptingAddition = true;
      config = {
        layout = "bsp";
        auto_balance = "on";
        window_placement = "second_child";
        window_gap = 10;
        top_padding = 10;
        bottom_padding = 10;
        left_padding = 10;
        right_padding = 10;
      };
    };

    # Configure Skhd (hotkey daemon, often used with Yabai)
    skhd = {
      enable = true;
      package = pkgs.skhd;
      skhdConfig = ''
        # Basic controls
        cmd - return : open -a Alacritty
        cmd + shift - space : open -a "Alfred 4"
        cmd + shift - r : launchctl kickstart -k "gui/''${UID}/org.nixos.yabai"
        cmd + shift - q : osascript -e 'tell app "System Events" to log out'
        cmd + shift - w : yabai -m window --close

        # State/flags
        cmd - t : yabai -m window --toggle float
        cmd + shift - t : yabai -m window --toggle sticky
        cmd - f : yabai -m window --toggle zoom-fullscreen

        # Focus/swap
        cmd - h : yabai -m window --focus west
        cmd - j : yabai -m window --focus south
        cmd - k : yabai -m window --focus north
        cmd - l : yabai -m window --focus east
        cmd + shift - h : yabai -m window --swap west
        cmd + shift - j : yabai -m window --swap south
        cmd + shift - k : yabai -m window --swap north
        cmd + shift - l : yabai -m window --swap east

        cmd - 1 : yabai -m space --focus 1
        cmd - 2 : yabai -m space --focus 2
        cmd - 3 : yabai -m space --focus 3
        cmd - 4 : yabai -m space --focus 4
        cmd - 5 : yabai -m space --focus 5
        cmd - 6 : yabai -m space --focus 6

        cmd + shift - 1 : yabai -m window --space 1; yabai -m space --focus 1
        cmd + shift - 2 : yabai -m window --space 2; yabai -m space --focus 2
        cmd + shift - 3 : yabai -m window --space 3; yabai -m space --focus 3
        cmd + shift - 4 : yabai -m window --space 4; yabai -m space --focus 4
        cmd + shift - 5 : yabai -m window --space 5; yabai -m space --focus 5
        cmd + shift - 6 : yabai -m window --space 6; yabai -m space --focus 6

        # Move/resize
        cmd + alt - h : yabai -m window --resize left:-20:0
        cmd + alt - j : yabai -m window --resize bottom:0:20
        cmd + alt - k : yabai -m window --resize top:0:-20
        cmd + alt - l : yabai -m window --resize right:20:0
        cmd + alt + shift - h : yabai -m window --resize right:-20:0
        cmd + alt + shift - j : yabai -m window --resize top:0:20
        cmd + alt + shift - k : yabai -m window --resize bottom:0:-20
        cmd + alt + shift - l : yabai -m window --resize left:20:0

        # Monitor focus and window movement
        cmd - 0x2A : yabai -m display --focus next  # 0x2A is the keycode for backslash
        cmd + shift - 0x2A : yabai -m window --display next; yabai -m display --focus next

        # Advanced window management
        cmd - n : yabai -m window --focus next
        cmd + shift - n : yabai -m window --focus prev
        cmd - m : yabai -m window --toggle zoom-fullscreen
        cmd + shift - m : yabai -m space --rotate 90

        # Application shortcuts
        cmd - e : open ~
        cmd - b : open -a "Firefox"

        # Screenshot (using built-in macOS shortcuts)
        cmd + shift - 3 : screencapture -ic
        cmd + shift - 4 : screencapture -ics

        # Media control (using macOS media keys)
        # These usually work out of the box on macOS

        # Volume control (using macOS media keys)
        # These usually work out of the box on macOS

        # Brightness control
        # You might need to create a custom script for this on macOS
        # 0x6B and 0x71 are the keycodes for F14 and F15, which are often used for brightness on Macs
        # 0x6B : $\{brightness-control}/bin/brightness-control up
        # 0x71 : $\{brightness-control}/bin/brightness-control down
      '';
    };
  };

  # System-wide Darwin configuration.
  system = {
    stateVersion = 4;

    defaults = {
      finder = {
        AppleShowAllExtensions = true;
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
      };

      CustomUserPreferences = {
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "118" = {
              enabled = true;
              value = {
                parameters = [
                  65535
                  18
                  262144
                ];
                type = "standard";
              };
            };
          };
        };
        # Night Shift settings
        "com.apple.CoreBrightness" = {
          CBBlueLightReductionEnabled = true;
          CBBlueLightReductionSchedule = {
            CBBlueLightReductionScheduleType = 1; # 1 for custom schedule, 2 for sunset to sunrise
            CBBlueLightReductionStartHour = 22; # 10 PM
            CBBlueLightReductionStartMinute = 0;
            CBBlueLightReductionEndHour = 7; # 7 AM
            CBBlueLightReductionEndMinute = 0;
          };
          CBBlueLightReductionStrength = 0.95; # 50% strength, adjust as needed (0.0 to 1.0)
        };
      };

      LaunchServices.LSQuarantine = false;

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # SLIDER POSITIONS: 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # SLIDER POSITIONS: 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      dock = {
        autohide = true;
        show-recents = false;
        launchanim = true;
        mouse-over-hilite-stack = true;
        orientation = "bottom";
        tilesize = 48;
        minimize-to-application = true;
        mru-spaces = false;
      };

      finder._FXShowPosixPathInTitle = false;

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  # Nix configuration
  nix = {
    package = pkgs.nix;
    settings.trusted-users = [
      "@admin"
      "${user}"
    ];

    gc = {
      user = "root";
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      sandbox = false
    '';
  };

  # Other system-wide configurations
  system.checks.verifyNixPath = false;
}
