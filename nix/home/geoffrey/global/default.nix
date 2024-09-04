# Reference
# - [1]
{ inputs
, lib
, pkgs
, config
, outputs
, ...
}: {
  imports =
    [

      inputs.sops-nix.homeManagerModules.sops
      #      inputs.impermanence.nixosModules.home-manager.impermanence
      #      ../features/cli
      #      ../features/nvim
      ../modules
    ];
  #    ++ (builtins.attrValues outputs.homeManagerModules);



  #  nix = {
  #    package = lib.mkDefault pkgs.nix;
  #    settings = {
  #      experimental-features = [
  #        "nix-command"
  #        "flakes"
  #        "ca-derivations"
  #      ];
  #      warn-dirty = false;
  #    };
  #  };

  #  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };
  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.keyFile = "/home/geoffrey/.config/sops/age/keys.txt";
  sops.defaultSymlinkPath = "/run/user/1000/secrets";
  sops.defaultSecretsMountPoint = "/run/user/1000/secrets.d";
  sops.secrets.github_token = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets.openai_api_key = {
    sopsFile = ./secrets.yaml;
  };

  #  # Declare the secrets that are going to be used.
  #  sops.secrets.hello = { };
  #  systemd.user.services.test = {
  #    Unit = {
  #      Description = "A test service that reads secrets";
  #      After = [ "sops-nix.service" ];
  #    };
  #
  #    Service = {
  #      Type = "oneshot";
  #      ExecStart = pkgs.writeShellScript "test-script" ''
  #        echo "Hello, world!" > /var/tmp/test.txt
  #        echo "This is a test of reading the secrets from config.sops.secrets," >> /var/tmp/test.txt
  #        echo "inside there, theres hello, example_key, example_array, etc:" >> /var/tmp/test.txt
  #
  #        # Assuming you have these secrets defined in your sops configuration
  #        echo "Hello secret: $(cat ${config.sops.secrets.hello.path})" >> /var/tmp/test.txt
  #      '';
  #    };
  #
  #    Install = {
  #      WantedBy = [ "default.target" ];
  #    };
  #  };


  #  # Create a service to set environment variables
  #  systemd.user.services.set-env-vars = {
  #    Unit = {
  #      Description = "Set environment variables from secrets";
  #      After = [ "sops-nix.service" ];
  #    };
  #
  #    Service = {
  #      Type = "oneshot";
  #      RemainAfterExit = true;
  #      ExecStart = pkgs.writeShellScript "set-env-vars" ''
  #        # Create a temporary file to store environment variables
  #        ENV_FILE=$(mktemp)
  #
  #        # Set permissions to make the file readable only by the user
  #        chmod 600 $ENV_FILE
  #
  #        # Write variables to the temporary file
  #        echo "GITHUB_TOKEN=$(cat ${config.sops.secrets.github_token.path})" >> $ENV_FILE
  #        echo "API_KEY=$(cat ${config.sops.secrets.api_key.path})" >> $ENV_FILE
  #
  #        # Set the environment file path in the systemd user environment
  #        systemctl --user set-environment ENV_FILE=$ENV_FILE
  #
  #        # Notify services that need these variables
  #        ${lib.concatMapStrings (service: "
  #          systemctl --user try-reload-or-restart ${service}
  #        ") servicesNeedingEnv}
  #      '';
  #      ExecStop = pkgs.writeShellScript "unset-env-vars" ''
  #        # Remove the temporary file
  #        if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
  #          rm -f $ENV_FILE
  #        fi
  #
  #        # Unset the environment variable
  #        systemctl --user unset-environment ENV_FILE
  #
  #        # Notify services that variables are no longer available
  #        ${lib.concatMapStrings (service: "
  #          systemctl --user try-reload-or-restart ${service}
  #        ") servicesNeedingEnv}
  #      '';
  #    };
  #
  #    Install = {
  #      WantedBy = [ "default.target" ];
  #    };
  #  };


  home = {
    username = lib.mkDefault "geoffrey";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.05";
    sessionPath = [ "$HOME/.local/bin" ];
    shellAliases = {
      hw = "echo Hello, world!";
    };
    sessionVariables = {
      FLAKE = "$HOME/.dotfiles";
      EDITOR = "neovim";
      # BROWSER = "firefox";
    };


    #    persistence = {
    #      "/persist/${config.home.homeDirectory}" = {
    #        defaultDirectoryMethod = "symlink";
    #        directories = [
    #          "Documents"
    #          "Downloads"
    #          "Pictures"
    #          "Videos"
    #          ".local/bin"
    #          ".local/share/nix" # trusted settings and repl history
    #        ];
    #        allowOther = true;
    #      };
    #    };
  };

  #  colorscheme.mode = lib.mkOverride 1499 "dark";
  #  specialisation = {
  #    dark.configuration.colorscheme.mode = lib.mkOverride 1498 "dark";
  #    light.configuration.colorscheme.mode = lib.mkOverride 1498 "light";
  #  };
  #  home.file = {
  #    ".colorscheme.json".text = builtins.toJSON config.colorscheme;
  #  };

  #  home.packages = let
  #    specialisation = pkgs.writeShellScriptBin "specialisation" ''
  #      profiles="$HOME/.local/state/nix/profiles"
  #      current="$profiles/home-manager"
  #      base="$profiles/home-manager-base"
  #
  #      # If current contains specialisations, link it as base
  #      if [ -d "$current/specialisation" ]; then
  #        echo >&2 "Using current profile as base"
  #        ln -sfT "$(readlink "$current")" "$base"
  #      # Check that $base contains specialisations before proceeding
  #      elif [ -d "$base/specialisation" ]; then
  #        echo >&2 "Using previously linked base profile"
  #      else
  #        echo >&2 "No suitable base config found. Try 'home-manager switch' again."
  #        exit 1
  #      fi
  #
  #      if [ -z "$1" ] || [ "$1" = "list" ] || [ "$1" = "-l" ] || [ "$1" = "--list" ]; then
  #        find "$base/specialisation" -type l -printf "%f\n"
  #        exit 0
  #      fi
  #
  #      echo >&2 "Switching to ''${1} specialisation"
  #      if [ "$1" == "base"  ]; then
  #        "$base/activate"
  #      else
  #        "$base/specialisation/$1/activate"
  #      fi
  #    '';
  #    toggle-theme = pkgs.writeShellScriptBin "toggle-theme" ''
  #      if [ -n "$1" ]; then
  #        theme="$1"
  #      else
  #        current="$(${lib.getExe pkgs.jq} -re '.mode' "$HOME/.colorscheme.json")"
  #        if [ "$current" = "light" ]; then
  #          theme="dark"
  #        else
  #          theme="light"
  #        fi
  #      fi
  #      ${lib.getExe specialisation} "$theme"
  #    '';
  #  in [
  #    specialisation
  #    toggle-theme
  #  ];
}
