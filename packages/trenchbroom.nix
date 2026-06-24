{ appimageTools, fetchzip }:

appimageTools.wrapType2 rec {
  name = "TrenchBroom";
  pname = name;
  version = "v2025.3";
  src = "${fetchzip {
    url = "https://github.com/TrenchBroom/TrenchBroom/releases/download/${version}/TrenchBroom-Linux-x86_64-${version}-Release.zip";
    hash = "sha256-lv5DPpZhAV/xFxtcl7uqHShgWKRolY6SG8mhrR6955Y=";
  }}/TrenchBroom.AppImage";
  extraBwrapArgs = [ "--setenv" "QT_QPA_PLATFORM" "xcb" ];
}
