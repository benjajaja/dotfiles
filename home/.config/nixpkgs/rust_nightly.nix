{ callPackage, fetchFromGitHub, makeRustPlatform }:

# The date of the nighly version to use.
date:

let
  mozillaOverlay = fetchFromGitHub {
    owner = "mozilla";
    repo = "nixpkgs-mozilla";
    rev = "85eb0ba7d8e5d6d4b79e5b0180aadbdd25d76404";
    sha256 = "sha256-ZAJGIZ7TjOCU7302lSUabNDz+rxM4If0l8/ZbE/7R5U=";
  };
  mozilla = callPackage "${mozillaOverlay.out}/package-set.nix" {};
  rustNightly = (mozilla.rustChannelOf { inherit date; channel = "nightly"; }).rust;
in makeRustPlatform {
  cargo = rustNightly;
  rustc = rustNightly;
}
