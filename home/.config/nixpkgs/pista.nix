with import <nixpkgs> {};
with pkgs;

{ stdenv, lib }:

rustPlatform.buildRustPackage rec {
  pname = "pista";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "nerdypepper";
    repo = "pista";
    rev = "e426ee675844c90bea285b4bc8ec9a2cc5c3b4ef";
    sha256 = "pGK5OWw6u1zx0Qm1n1azm5lDraQEy5ULJca5ZA5eIs8=";
    fetchSubmodules = true;
  };

  cargoSha256 = "2uZXmH0Gw6cwBegS0n4r6NYOJWYFp+ndg618I8Og37k=";

  nativeBuildInputs = [
    openssl
    pkgconfig
  ];

  doCheck = true;
}

