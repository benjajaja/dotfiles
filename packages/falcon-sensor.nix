# CrowdStrike Falcon Sensor package
# You need to get the binary from IT and place it at /opt/CrowdStrikeDistro/
{ stdenv
, lib
, pkgs
, dpkg
, openssl
, libnl
, zlib
, fetchurl
, autoPatchelfHook
, buildFHSUserEnv
, writeScript
, ...
}:

let
  pname = "falcon-sensor";
  arch = "amd64";
  # You need to get the binary from #it guys
  # mkdir -p /opt/CrowdStrikeDistro/
  # mv /tmp/falcon*.deb /opt/CrowdStrikeDistro/
  src = /opt/CrowdStrikeDistro/falcon-sensor_6.44.0-14107_amd64.deb;

  falcon-sensor = stdenv.mkDerivation {
    inherit arch src;
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
      homepage = "https://www.crowdstrike.com/";
      license = licenses.unfree;
      platforms = platforms.linux;
    };
  };
in

buildFHSUserEnv {
  name = "fs-bash";
  targetPkgs = pkgs: [ libnl openssl zlib ];

  extraInstallCommands = ''
    ln -s ${falcon-sensor}/* $out/
  '';

  runScript = "bash";
}
