with import <nixpkgs> {};
with pkgs;

{ stdenv, lib }:

rustPlatform.buildRustPackage rec {
  pname = "pista";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "oppiliappan";
    repo = "pista";
    rev = "378535f3e7e138110b6225616e0dc61066a5605a";
    sha256 = "sha256-FlWDKz5B/sC+VCtJNmtCJTkxzeOJOMT9gZlG6UVGzKU=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-xCejCHSUwa1u58b2wKBYbbaotFAQnCdaCii3/uWdlAk=";

  nativeBuildInputs = [ pkg-config ];
  
  buildInputs = [ openssl openssl.dev perl ];
  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkg-config";

  doCheck = false;
}

