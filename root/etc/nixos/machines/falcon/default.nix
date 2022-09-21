{ stdenv, lib, pkgs, dpkg,
openssl, libnl, zlib,
fetchurl, autoPatchelfHook, buildFHSUserEnv, writeScript, ... }:
let
  pname = "falcon-sensor";
  version = "6.44.0-14107";
  arch = "amd64";
  src = /home/gipsy/Downloads + "/${pname}_${version}_${arch}.deb";
  falcon-sensor = stdenv.mkDerivation {
    inherit version arch src;
    name = pname;

    buildInputs = [ dpkg zlib autoPatchelfHook ];

    sourceRoot = ".";

    unpackPhase = ''
        dpkg-deb -x $src .
    '';

    installPhase = ''
        cp -r . $out
    '';

    meta = with lib; {
      description = "Crowdstrike Falcon Sensor";
      homepage    = "https://www.crowdstrike.com/";
      license     = licenses.unfree;
      platforms   = platforms.linux;
      maintainers = with maintainers; [ klden ];
    };
  };
in buildFHSUserEnv {
  name = "fs-bash";
  targetPkgs = pkgs: [ libnl openssl zlib ];

  extraInstallCommands = ''
    ln -s ${falcon-sensor}/* $out/
  '';

  runScript = "bash";
}
