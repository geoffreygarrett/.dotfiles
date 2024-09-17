{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, gum
}:

stdenv.mkDerivation rec {
  pname = "mdt";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "basilioss";
    repo = "mdt";
    rev = version;
    sha256 = "sha256-TUGRNfmYDtUm3tXI28v9EjM43RLhJLrtucXu0htbSOU=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp mdt $out/bin/mdt
    chmod +x $out/bin/mdt
    wrapProgram $out/bin/mdt --prefix PATH : ${lib.makeBinPath [ gum ]}
  '';

  meta = with lib; {
    description = "Minimal set of functionality designed to finish tasks instead of organizing them";
    homepage = "https://github.com/basilioss/mdt";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
