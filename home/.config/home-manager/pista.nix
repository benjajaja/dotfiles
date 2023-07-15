with import <nixpkgs> {};
with pkgs;

{ stdenv, lib }:

rustPlatform.buildRustPackage rec {
  pname = "pista";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "benjajaja";
    repo = "pista";
    rev = "68d5f434f5b7c5625719a9fe6c2e82edfe376f50";
    sha256 = "sha256-FlWDKz5B/sC+VCtJNmtCJTkxzeOJOMT9gZlG6UVGzKU=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-16nmnhDWXxYcKbklDxMA7mlqlrzvaYBFekfLHad7qt8=";

  nativeBuildInputs = [ pkgconfig ];
  
  buildInputs = [ openssl openssl.dev perl ];
  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

  doCheck = false;
}

