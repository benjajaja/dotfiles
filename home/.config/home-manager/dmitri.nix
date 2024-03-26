with import <nixpkgs> {};
with pkgs;

{ stdenv, lib }:

rustPlatform.buildRustPackage rec {
  pname = "dmitry";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "benjajaja";
    repo = "dmitri";
    rev = "9dce74985ca52154c818f5ddd62aff09d4330d80";
    sha256 = "sha256-uA3yOMW1fh1VH3J/dYpm/d2upRji+OL+y0BzJj5+5yM=";
  };

  cargoHash = "sha256-IPoc3wD0Ar9Ix0bdZG/q3DKZncgzGu8Qe/I5J51GzFg=";

  nativeBuildInputs = [ freetype pkg-config expat ];
  
  buildInputs = [ freetype expat fontconfig ];

  doCheck = true;
}


