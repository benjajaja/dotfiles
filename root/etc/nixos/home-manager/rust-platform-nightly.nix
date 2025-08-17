{ callPackage, fetchFromGitHub, makeRustPlatform }:

# The date of the nighly version to use.
date:

let
  mozillaOverlay = fetchFromGitHub {
    owner = "mozilla";
    repo = "nixpkgs-mozilla";
    rev = "9f35c4b09fd44a77227e79ff0c1b4b6a69dff533";
    sha256 = "18h0nvh55b5an4gmlgfbvwbyqj91bklf1zymis6lbdh75571qaz0";
  };
  mozilla = callPackage "${mozillaOverlay.out}/package-set.nix" {};
  rustNightly = (mozilla.rustChannelOf { inherit date; channel = "nightly"; }).rust;
in makeRustPlatform {
  cargo = rustNightly;
  rustc = rustNightly;
}
