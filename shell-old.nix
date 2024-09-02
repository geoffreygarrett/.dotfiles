
let
  # Import the unstable channel
  unstable = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixpkgs-unstable.tar.gz";
    sha256 = "12228ff1"; # Update with the correct SHA256 if necessary
  }) {};

in
  unstable.mkShell {
    buildInputs = with unstable; [
      neovim
      python310Full
      nodejs
      ripgrep
      fzf
      git
    ];

    shellHook = ''
      export PATH=$HOME/.local/bin:$PATH
      export NVIM_APPNAME=nvim
    '';
  }
