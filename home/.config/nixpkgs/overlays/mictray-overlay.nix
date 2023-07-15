with import <nixpkgs> {};
with pkgs;

self: super: {
  mictray = super.mictray.overrideAttrs (oldAttrs: {
    version = "0.3.1";
    src = super.fetchFromGitHub {
      owner = "Junker";
      repo = oldAttrs.pname;
      rev = "0.3.1";
      sha256 = "sha256-QudDgaQNH/t8rsdlzHxvn7O2ClT0OSq9lBwWf2D4BvE=";
    };
    nativeBuildInputs = [
      meson
      ninja
      pkg-config
      vala
      wrapGAppsHook
    ];

    buildInputs = [
      gtk3
      libgee
      libnotify
      pulseaudio
    ];
  });
}
