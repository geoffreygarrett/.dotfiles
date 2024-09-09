{
  self,
  inputs,
  config,
  lib,
  pkgs,
  home-manager,
  ...
}:

let
  user = "geoffreygarrett";
  home-manager-config = import ../../modules/darwin/home-manager.nix {
    inherit
      config
      pkgs
      home-manager
      lib
      inputs
      ;
    inherit user;
  };

in
{

  imports = [
    ../../modules/shared/cachix
  ];

  #    imports = [

  #    #    ../../modules/darwin/secrets.nix
  #    ../../modules/darwin/home-manager.nix
  #    #    ../../modules/shared
  #    #    ../../modules/shared/cachix
  #    #     agenix.darwinModules.default
  #  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  #  home-manager.users.${user}.imports = [
  #    ../../home/modules/darwin/home-manager.nix
  #  ];

  homebrew = {
    # This is a module from nix-darwin
    # Homebrew is *installed* via the flake input nix-homebrew
    enable = true;
    casks = pkgs.callPackage ./casks.nix { };

    #    brews = pkgs.callPackage ./brews.nix { };

    brews = [ "nushell" ];

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      #      "1password" = 1333542190;
      #      "canva" = 897446215;
      #      "drafts" = 1435957248;
      #      "hidden-bar" = 1452453066;
      #      "wireguard" = 1451685025;
      #      "yoink" = 457622435;
      #      "deco" = 1186159417;
      "tailscale" = 1475387142;
    };

    # Marked broken Oct 20, 2022 check later to remove this
    # https://github.com/nix-community/home-manager/issues/3344
    #      manual.manpages.enable = false;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user} =
      {
        config,
        lib,
        pkgs,
        inputs,
        self,
        ...
      }:
      {
        imports = [
          ../../modules/darwin/secrets.nix
          ../../modules/shared/home-manager/programs
        ];

        home = {
          enableNixpkgsReleaseCheck = false;
          packages =
            pkgs.callPackage ../../modules/darwin/packages.nix {
              inherit pkgs;
            }
            ++ [
              pkgs.nushell
            ];

          stateVersion = "23.11";
        };

        #      programs = {
        #        nushell = {
        #          enable = true;
        #          extraConfig = ''
        #            $env.config = {
        #              show_banner: false,
        #            };
        #          '';
        #        };
        #      };

        #  home-manager = {
        #    useGlobalPkgs = true;
        #    useUserPackages = true;
        #    #    programs = { };
        #    users.${user} = {
        #      imports = [
        ##        ../../home/modules/shared/home-manager/programs
        #        ../../home/modules/darwin/secrets.nix
        #      ];
        ##      programs = import ../../home/modules/shared/home-manager/programs {
        ##        inherit config lib pkgs inputs;
        ##      };
        #
        #
        #    config =
        #      { config, lib, pkgs, inputs, ... }:
        #      {
        #
        #      home = home-manager-config.home // {
        #        enableNixpkgsReleaseCheck = false;
        #        packages = pkgs.callPackage ../../home/modules/darwin/packages.nix
        #          {
        #            inherit pkgs;
        #          } ++ [
        #                    pkgs.nushell
        #        ];
        #
        #        stateVersion = "23.11";
        #      };
        #
        #        programs = {
        #          nushell = {
        #            enable = true;
        #            extraConfig = ''
        #              $env.config = {
        #                show_banner: false,
        #              };
        #            '';
        #          };
        #          #  home.packages = with pkgs; [
        #          #   cargo
        #          #  ];
        #         # programs.nushell.shellAliases = shellAliasesConfig.shellAliases.nu;
        #};
        #      };

        #      programs = {
        #
        #        nushell = {
        #          enable = true;
        #        };
        #
        #      };
        #            programs = { }
        #              // import ../../home/modules/shared/home-manager/programs { inherit config inputs user pkgs lib; };

        #      programs = {} // {
        #        nushell = {
        #          enable = true;
        #        };
        #      };
        #      programs = home-manager-config.programs // {
        #        # Ensure 'programs.firefox' is included correctly
        #        programs.firefox = {
        #          enable = true;
        #          # Add more Firefox-specific options here...
        #        };
        #        };
      };
    extraSpecialArgs = {
      inherit inputs user self;
    };
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Setup user, packages, programs
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

    # Turn this on to make command line easier
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Turn off NIX_PATH warnings now that we're using flakes
  system.checks.verifyNixPath = false;

  # Load configuration that is shared across systems
  environment.systemPackages =
    with pkgs;
    [
      pkgs.nushell
      #    emacs-unstable
      #    agenix.packages."${pkgs.system}".default
    ]
    ++ (import ../../modules/shared/packages.nix { inherit pkgs; });

  #  launchd.user.agents.emacs.path = [ config.environment.systemPath ];
  #  launchd.user.agents.emacs.serviceConfig = {
  #    KeepAlive = true;
  #    ProgramArguments = [
  #      "/bin/sh"
  #      "-c"
  #      "{ osascript -e 'display notification \"Attempting to start Emacs...\" with title \"Emacs Launch\"'; /bin/wait4path ${pkgs.emacs}/bin/emacs && { ${pkgs.emacs}/bin/emacs --fg-daemon; if [ $? -eq 0 ]; then osascript -e 'display notification \"Emacs has started.\" with title \"Emacs Launch\"'; else osascript -e 'display notification \"Failed to start Emacs.\" with title \"Emacs Launch\"' >&2; fi; } } &> /tmp/emacs_launch.log"
  #    ];
  #    StandardErrorPath = "/tmp/emacs.err.log";
  #    StandardOutPath = "/tmp/emacs.out.log";
  #  };

  system = {
    stateVersion = 4;

    defaults = {
      LaunchServices = {
        LSQuarantine = false;
      };

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      dock = {
        autohide = false;
        show-recents = false;
        launchanim = true;
        mouse-over-hilite-stack = true;
        orientation = "bottom";
        tilesize = 48;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

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
}

#{ agenix, inputs, config, lib, pkgs, home-manager, ... }:
#
#let
#  user = "geoffreygarrett";
#  home-manager-config = import ../../home/modules/darwin/home-manager.nix {
#    inherit config pkgs home-manager lib inputs;
#    inherit user;
#  };
#
#in
#{
#
#  #    imports = [
#
#
#  #    #    ../../modules/darwin/secrets.nix
#  #    ../../home/modules/darwin/home-manager.nix
#  #    #    ../../modules/shared
#  #    #    ../../modules/shared/cachix
#  #    #     agenix.darwinModules.default
#  #  ];
#
#  # It me
#  users.users.${user} = {
#    name = "${user}";
#    home = "/Users/${user}";
#    isHidden = false;
#    shell = pkgs.zsh;
#  };
#
#  home-manager = {
#    users.${user} = {
##      imports = [
###        ../../home/modules/darwin/home-manager.nix
###        ../../home/modules/darwin/secrets.nix
##      ];
#      home = {
##        enableNixpkgsReleaseCheck = false;
##        packages = pkgs.callPackage ../../home/modules/darwin/packages.nix { inherit pkgs; };
##        file = lib.mkMerge [
##          #          ../../home/modules/shared/files.nix
##          #          ../../home/modules/darwin/files.nix
##        ];
#        stateVersion = "23.11";
##        programs = {};
#            # Ensure 'programs.firefox' is included correctly
#              programs.firefox = {
#                enable = true;
#                # Add more Firefox-specific options here...
#              };
#      };
#
#    };
#    extraSpecialArgs = { inherit config inputs user; };
#  };
#  # Auto upgrade nix package and the daemon service.
#  services.nix-daemon.enable = true;
#
#  # Setup user, packages, programs
#  nix = {
#    package = pkgs.nix;
#    settings.trusted-users = [ "@admin" "${user}" ];
#
#    gc = {
#      user = "root";
#      automatic = true;
#      interval = { Weekday = 0; Hour = 2; Minute = 0; };
#      options = "--delete-older-than 30d";
#    };
#
#    # Turn this on to make command line easier
#    extraOptions = ''
#      experimental-features = nix-command flakes
#    '';
#  };
#
#  # Turn off NIX_PATH warnings now that we're using flakes
#  system.checks.verifyNixPath = false;
#
#  # Load configuration that is shared across systems
#  environment.systemPackages = with pkgs; [
#    #    emacs-unstable
#    #    agenix.packages."${pkgs.system}".default
#  ] ++ (import ../../home/modules/shared/packages.nix { inherit pkgs; });
#
#  #  launchd.user.agents.emacs.path = [ config.environment.systemPath ];
#  #  launchd.user.agents.emacs.serviceConfig = {
#  #    KeepAlive = true;
#  #    ProgramArguments = [
#  #      "/bin/sh"
#  #      "-c"
#  #      "{ osascript -e 'display notification \"Attempting to start Emacs...\" with title \"Emacs Launch\"'; /bin/wait4path ${pkgs.emacs}/bin/emacs && { ${pkgs.emacs}/bin/emacs --fg-daemon; if [ $? -eq 0 ]; then osascript -e 'display notification \"Emacs has started.\" with title \"Emacs Launch\"'; else osascript -e 'display notification \"Failed to start Emacs.\" with title \"Emacs Launch\"' >&2; fi; } } &> /tmp/emacs_launch.log"
#  #    ];
#  #    StandardErrorPath = "/tmp/emacs.err.log";
#  #    StandardOutPath = "/tmp/emacs.out.log";
#  #  };
#
#  system = {
#    stateVersion = 4;
#
#    defaults = {
#      LaunchServices = {
#        LSQuarantine = false;
#      };
#
#      NSGlobalDomain = {
#        AppleShowAllExtensions = true;
#        ApplePressAndHoldEnabled = false;
#
#        # 120, 90, 60, 30, 12, 6, 2
#        KeyRepeat = 2;
#
#        # 120, 94, 68, 35, 25, 15
#        InitialKeyRepeat = 15;
#
#        "com.apple.mouse.tapBehavior" = 1;
#        "com.apple.sound.beep.volume" = 0.0;
#        "com.apple.sound.beep.feedback" = 0;
#      };
#
#      dock = {
#        autohide = false;
#        show-recents = false;
#        launchanim = true;
#        mouse-over-hilite-stack = true;
#        orientation = "bottom";
#        tilesize = 48;
#      };
#
#      finder = {
#        _FXShowPosixPathInTitle = false;
#      };
#
#      trackpad = {
#        Clicking = true;
#        TrackpadThreeFingerDrag = true;
#      };
#    };
#
#    keyboard = {
#      enableKeyMapping = true;
#      remapCapsLockToControl = true;
#    };
#  };
#}
