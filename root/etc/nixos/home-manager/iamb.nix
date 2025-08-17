with import <nixpkgs> {};
with pkgs;
{ stdenv, lib }:

let
  rustNightly = pkgs.callPackage ./rust_nightly.nix {};
in
(rustNightly "2023-01-24").buildRustPackage rec {
  pname = "iamb";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "benjajaja";
    repo = "iamb";
    rev = "0ae55bc6c6c1613c75741e3c7bfb5ac4830bfe1e";
    sha256 = "sha256-uPi3gYwCFvgLyy5S1dizTFkZbOcCkHQfUUr7jWNZ3Tk=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-NaV3cSGFdMEmV0X5b81Z0HMRnaw44B8AwEZgatBYi9o=";

  nativeBuildInputs = [ pkgs.openssl pkgs.pkg-config ];
  
  buildInputs = [ pkgs.openssl ];

  doCheck = true;
}

