{
  lib,
  stdenv,
  fetchFromGitHub,
  swift,
  xcbuild,
  swift-format,
  swiftlint,
  ruby,
  bundler,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "aerospace";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "nikitabobko";
    repo = "AeroSpace";
    rev = "664f5704a77a9410e902d9be35d20436664a420a";
    sha256 = "1qmv7w369byg2nfz5ybs50mlf81k9xwv5ji6w1n96y4pbd40wbmr";
  };

  nativeBuildInputs = [
    swift
    xcbuild
    swift-format
    swiftlint
    ruby
    bundler
    makeWrapper
  ];

  buildPhase = ''
    export HOME=$TMPDIR
    bundle config set --local path 'vendor/bundle'
    bundle install
    ./build-release.sh
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp .build/release/aerospace $out/bin/
    wrapProgram $out/bin/aerospace \
      --prefix PATH : ${
        lib.makeBinPath [
          swift
          xcbuild
        ]
      }
  '';

  meta = with lib; {
    description = "AeroSpace: Tiling window manager for macOS";
    homepage = "https://github.com/nikitabobko/AeroSpace";
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ "geoffreygarrett" ];
  };
}
