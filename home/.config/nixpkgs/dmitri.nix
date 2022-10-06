with import <nixpkgs> {};
with pkgs;

{ stdenv, lib }:

rustPlatform.buildRustPackage rec {
  pname = "dmitry";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "benjajaja";
    repo = "dmitri";
    rev = "328adba851be38767857e11c0e829c78ecd4c587";
    sha256 = "sha256-QmyAU0Ukz6uhxaxVx9ZUweWiAOhJv7tWRMIU//SJrs4=";
  };

  cargoHash = "sha256-bCqRPluRsdObiPvQ9lEwlwE1KaVmWqLhd27VDJhIlQk=";

  nativeBuildInputs = [ freetype pkgconfig expat ];
  
  buildInputs = [ freetype expat fontconfig ];

  doCheck = true;
}


