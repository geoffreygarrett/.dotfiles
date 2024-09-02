{ pkgs, home-manager, system }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
#    neofetch
#    zsh
#    coreutils
#    inetutils
#    findutils
#    gnugrep
  ];

  shellHook = ''

  '';
}
