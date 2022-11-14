with import <nixpkgs> {};
with pkgs;

self: super: {
  mictray = super.mictray.overrideAttrs (oldAttrs: {
    version = "0.2.5";
    src = super.fetchFromGitHub {
      owner = "benjajaja";
      repo = oldAttrs.pname;
      rev = "15de891e48da9f8f9f1b8d4a3615a0d40117dca6";
      sha256 = "sha256-3QsWqi6KOPHX62RxvAn5C0P9Sx2R8imzXawUn+ELYxI=";
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
      libpulseaudio
      keybinder3
    ];
  });
}
