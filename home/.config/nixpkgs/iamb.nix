with import <nixpkgs> {};
with pkgs;

{ stdenv, lib }:
with import "${src.out}/rust-overlay.nix" pkgs pkgs;
rustPlatform.buildRustPackage rec {
  pname = "iamb";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "ulyssa";
    repo = "iamb";
    rev = "69125e3fc433122700deec698e318a4152af0099";
    sha256 = "sha256-AeYZDjg1u5wTS3L7w+zFRw/xPlrWt8ZO4HKcBkPAtaQ=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-+D4+oH9AysUpzLA/nZAbvyUco3fyyBDi3weSZWt7qsA=";

  nativeBuildInputs = [ ];
  
  buildInputs = [
    latest.rustChannels.nightly.rust
  ];

  doCheck = true;
}


