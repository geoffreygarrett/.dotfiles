{ pkgs, home-manager, system }:

pkgs.mkShell {
  nativeBuildInputs = [
    home-manager.packages.${system}.home-manager
    pkgs.neofetch
    pkgs.zsh
    pkgs.starship
    pkgs.coreutils
    pkgs.inetutils
    pkgs.findutils
    pkgs.gnugrep
    pkgs.git
    pkgs.zellij
  ];

  shellHook = let
    homeManager = "${home-manager.packages.${system}.home-manager}/bin/home-manager";
    starshipInit = "${pkgs.starship}/bin/starship init zsh";
    user = builtins.getEnv "USER";
    hostname = builtins.getEnv "HOSTNAME";
  in ''
    export NIX_PATH="nixpkgs=${pkgs.path}:home-manager=${home-manager}"
    export HOME_MANAGER_CONFIG="$PWD/home/default.nix"

    # Run home-manager switch with the appropriate flake
    if [ -f "$PWD/flake.nix" ]; then
      echo "Running home-manager switch --flake .#${user}@${hostname}"
      ${homeManager} switch --flake .#${user}@${hostname}
    else
      echo "Warning: flake.nix not found. Running default configuration."
    fi

    # Initialize Starship
    eval "$(${starshipInit})"

    # Use Zsh as the default shell
    if [ -f $HOME/.config/zsh/.zshrc ]; then
      exec ${pkgs.zsh}/bin/zsh --rcfile $HOME/.config/zsh/.zshrc
    else
      echo 'Warning: $HOME/.config/zsh/.zshrc not found. Using default Zsh configuration.'
      exec ${pkgs.zsh}/bin/zsh
    fi
  '';
}
