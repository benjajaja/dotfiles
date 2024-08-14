with import <nixpkgs> {};
with pkgs;

{ stdenv, lib }:

rustPlatform.buildRustPackage rec {
  pname = "pista";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "benjajaja";
    repo = "pista";
    rev = "27353d287548774a13bfd0064f39dedf79c2ca34";
    sha256 = "sha256-A2y30kEJVMVEvYrAG0B9Frlk9qOe4p1359exeeKwNG8=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-16nmnhDWXxYcKbklDxMA7mlqlrzvaYBFekfLHad7qt8=";

  nativeBuildInputs = [ pkg-config ];
  
  buildInputs = [ openssl openssl.dev perl ];
  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkg-config";

  doCheck = false;
}

