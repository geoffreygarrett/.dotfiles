{ pkgs }:
with pkgs;
let
  shared-packages = import ../shared/packages { inherit pkgs; };
in
shared-packages
++ [
  git
  openssh
  # procps
  # killall
  # diffutils
  # findutils
  # utillinux
  # tzdata
  # hostname
  # man
  # gnugrep
  # gnupg
  # gnused
  # gnutar
  # bzip2
  # gzip
  # xz
  # zip
  # unzip
]
