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

  cargoHash = "sha256-SgpttAL1/hSpApVCVZvlGpgotbYxN43YtH0yAtYehu4=";

  nativeBuildInputs = [ openssl pkgconfig ];
  
  buildInputs = [ openssl ];

  doCheck = true;
}

