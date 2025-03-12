final: prev: 
let
  # Import nixpkgs-unstable
  nixpkgsUnstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    # Inherit system and config from your current nixpkgs
    inherit (prev) system;
    config = prev.config;
  };
  # goBootstrap = final.callPackage "${toString nixpkgsUnstable.path}/pkgs/development/compilers/go/bootstrap122.nix" {};
in {
  # TODO: remove once go 1.24 is in unstable.
  # go = prev.go.overrideAttrs (oldAttrs: {
    # version = "1.24.0";
    # src = final.fetchurl {
      # url = "https://go.dev/dl/go1.24.0.src.tar.gz";
      # pragma: allowlist nextline secret
      # hash = "sha256-0UEgYUrLKdEryrcr1onyV+tL6eC2+IqPt+Qaxl+FVuU=";
    # };
    # GOROOT_BOOTSTRAP = "${goBootstrap}/share/go";
  # });
  # delve = prev.delve.overrideAttrs (oldAttrs: rec {
    # version = "1.24.0";
    # src = final.fetchFromGitHub {
      # owner = "go-delve";
      # repo = "delve";
      # rev = "v${version}";
      # hash = "sha256-R1MTMRAIceHv9apKTV+k4d8KoBaRJSZCflxqhgfQWu4=";
    # };
    # nativeBuildInputs = [ final.go final.git final.cacert final.makeWrapper ];
    # vendorHash = "sha256-/z3T1qccG4tUKq4UGHEXd+55woV7RDcMtAeokjrLXYQ=";
    # deleteVendor = true;
    # proxyVendor = true;
    # doCheck = false;
    # checkPhase = ''
      # go version
      # false
    # '';
    # GOTOOLCHAIN="go1.24.0";
  # });
}
