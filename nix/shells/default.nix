{ pkgs, home-manager, system }:

{
  default = pkgs.mkShell {
    nativeBuildInputs = with pkgs; [
      home-manager.packages.${system}.home-manager
      neofetch
      zsh
      spaceship-prompt
      coreutils
      inetutils
      findutils
      gnugrep
    ];
    shellHook = ''
      export NIX_PATH="nixpkgs=${pkgs.path}:home-manager=${home-manager}"
      export HOME_MANAGER_CONFIG="$PWD/home/default.nix"

      if [ ! -e "$HOME/.config/nixpkgs/home.nix" ]; then
        mkdir -p "$HOME/.config/nixpkgs"
        ln -sf "$PWD/home/default.nix" "$HOME/.config/nixpkgs/home.nix"
      fi

      # Start Zsh with the configuration from home-manager
      exec ${pkgs.zsh}/bin/zsh -c "
        if [ -f $HOME/.config/zsh/.zshrc ]; then
          source $HOME/.config/zsh/.zshrc
        else
          echo 'Warning: $HOME/.config/zsh/.zshrc not found. Using default Zsh configuration.'
        fi
        ${pkgs.zsh}/bin/zsh --interactive --login
      "
    '';
  };
}