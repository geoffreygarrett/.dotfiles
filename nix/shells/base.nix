{ pkgs, home-manager, system }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    neofetch
    zsh
    coreutils
    inetutils
    findutils
    gnugrep
  ];

  shellHook = ''
    export NIX_PATH="nixpkgs=${pkgs.path}:home-manager=${home-manager}"

    # Initialize Zsh
    if [ -f $HOME/.config/zsh/.zshrc ]; then
      exec ${pkgs.zsh}/bin/zsh --rcfile $HOME/.config/zsh/.zshrc
    else
      echo 'Warning: $HOME/.config/zsh/.zshrc not found. Using default Zsh configuration.'
      exec ${pkgs.zsh}/bin/zsh
    fi
  '';
}
