{ stdenv, dpkg, fetchurl, openssl, libnl, buildFHSUserEnv,... }:

stdenv.mkDerivation {
  name = "falcon-sensor";
  version = "4.18.0-6402";
  arch = "amd64";
  src = fetchurl {
    url = "https://storage.googleapis.com/company-tools/falcon-sensor/falcon-sensor_4.18.0-6402_amd64.deb";
    sha512 = "dc41cfe0232124480abdcf456df9a3bd6cab62716bc5beea089fbf99ac2e29bf1e1a44676591a71eeb35afe7f25e495b53ede007cfc15dcbf47df7ec0a016098";
  };

  buildInputs = [ dpkg ];

  sourceRoot = ".";

  unpackCmd = ''
      dpkg-deb -x "$src" .
  '';

  installPhase = ''
      cp -r ./ $out/
      realpath $out
  '';

  meta = with stdenv.lib; {
    description = "Crowdstrike Falcon Sensor";
    homepage    = "https://www.crowdstrike.com/";
    license     = licenses.unfree;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ ravloony ];
  };
}
