# with import <nixpkgs> {};
with import <nixpkgs> { overlays = [ (import <overlays/rust-overlay>) ]; };
with pkgs;

{ stdenv, lib }:

# let
  # rustPlatform = callPackage ./rust-platform-nightly.nix {};
# in (rustPlatform "2023-01-24").buildRustPackage rec {
# let
  # rustPkgs = import <nixpkgs> {
    # inherit system;
    # overlays = [ (import rust-overlay) ];
  # };
#
  # rustVersion = "1.61.0";
#
  # wasmTarget = "wasm32-unknown-unknown";
#
  # rustWithWasmTarget = rustPkgs.rust-bin.stable.${rustVersion}.default.override {
    # targets = [ wasmTarget ];
  # };
#
  # rustPlatformNightly = makeRustPlatform {
    # cargo = rustPkgs.rust-bin.stable.${rustVersion};
    # rustc = rustPkgs.rust-bin.stable.${rustVersion};
  # };
# in
rustPlatform.buildRustPackage rec {
  pname = "iamb";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "ulyssa";
    repo = "iamb";
    rev = "4f2261e66f41580d2add92234fc9f3d68eb669be";
    sha256 = "sha256-/lS7K3/OfBbgOlFlC4DKjN3zm1lXDxZN9bwgxXafLmE=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-bgUyJUZ+XzX+rUHVMy/qH6IlVP6xzHqcYZEvAwXOwM4=";

  nativeBuildInputs = [ openssl pkgconfig ];
  
  buildInputs = [ openssl ];

  doCheck = true;
}

