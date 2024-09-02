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

      # Use Zsh as the default shell
      if [ -f $HOME/.config/zsh/.zshrc ]; then
        ${pkgs.zsh}/bin/zsh --rcfile $HOME/.config/zsh/.zshrc
      else
        echo 'Warning: $HOME/.config/zsh/.zshrc not found. Using default Zsh configuration.'
        ${pkgs.zsh}/bin/zsh --login
      fi
    '';
  };
}
