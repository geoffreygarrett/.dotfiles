{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "gptcommit";
  version = "0.1.0"; # Update this to the latest version

  src = fetchFromGitHub {
    owner = "zurawiki";
    repo = "gptcommit";
    rev = "v${version}";
    sha256 = ""; # Replace with the actual SHA256 after fetching
  };

  cargoSha256 = ""; # Replace with the actual Cargo.lock SHA256

  nativeBuildInputs = [ pkg-config ];
  buildInputs =
    [ openssl ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
    ];

  meta = with lib; {
    description = "A git prepare-commit-msg hook for authoring commit messages with GPT";
    homepage = "https://github.com/zurawiki/gptcommit";
    license = licenses.mit;
    maintainers = with maintainers; [
      # Add your name here
    ];
  };
}
