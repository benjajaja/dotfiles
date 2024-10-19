{ lib, pkgs, fetchFromGitHub, fetchgit, buildGoModule }:

let
  go123 = pkgs.go.overrideAttrs (oldAttrs: rec {
    version = "1.23.0";

    src = pkgs.fetchurl {
      url = "https://go.dev/dl/go${version}.src.tar.gz";
      sha256 = "sha256-Qreo6A2AXaoDAi7T/eQyHUw78smQoUQWXQHu7Nb2mcY=";
    };

  });
in
{
  go = go123;

  #gopls = pkgs.gopls.overrideAttrs (oldAttrs: rec {
    #version = "0.16.2-pre.1";
    #src = fetchFromGitHub {
      #owner = "golang";
      #repo = "tools";
      #rev = "gopls/v${version}";
      #hash = "sha256-imGIzpoQ8mOkVTaT+ajf05zj84vco8V02u/Ln4nEh3A=";
    #};
    #nativeBuildInputs = [ go123 pkgs.git pkgs.cacert ];
    #vendorHash = "xxx";
    #deleteVendor = true;
    #proxyVendor = true;
    #doCheck = true;
    #checkPhase = ''
      #go version
      #false
    #'';
    #GOTOOLCHAIN="go1.23.0";
  #});
  delve = pkgs.delve.overrideAttrs (oldAttrs: rec {
    version = "1.23.0";
    src = fetchFromGitHub {
      owner = "go-delve";
      repo = "delve";
      rev = "v${version}";
      hash = "sha256-LtrPcYyuobHq6O3/vBKLTOMZfpYL7P3mtGfVqCMV9iM=";
    };
    #src = fetchFromGitHub {
      #owner = "golang";
      #repo = "tools";
      #rev = "gopls/v${version}";
      #hash = "sha256-imGIzpoQ8mOkVTaT+ajf05zj84vco8V02u/Ln4nEh3A=";
    #};
    #nativeBuildInputs = [ go123 pkgs.git pkgs.cacert ];
    #vendorHash = "xxx";
    #deleteVendor = true;
    #proxyVendor = true;
    #doCheck = true;
    #checkPhase = ''
      #go version
      #false
    #'';
    #GOTOOLCHAIN="go1.23.0";
  });
}
