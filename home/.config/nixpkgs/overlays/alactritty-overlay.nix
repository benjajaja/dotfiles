with import <nixpkgs> {};
with pkgs;

let
  rpathLibs = [
    expat
    fontconfig
    freetype
    libGL
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    xorg.libXxf86vm
    xorg.libxcb
  ] ++ lib.optionals stdenv.isLinux [
    libxkbcommon
    wayland
  ];
in
self: super: {
  alacritty = rustPlatform.buildRustPackage rec {
    pname = "alacritty-sixel";
    version = "0.11.0";

    src = fetchFromGitHub {
      owner = "microo8";
      repo = "alacritty-sixel";
      rev = "53110c6ecfc49d8e9298e90d1779a5d156d191fe";
      sha256 = "sha256-su3ul5LF8CLBy/2/GQ2gpbbP8C+cLziRplGTf714beE=";
    };

    cargoSha256 = "sha256-0aJdsF/nRoNj+mSgeLGi9+apdThZ7EzVUh0oq0UvKQE=";

    nativeBuildInputs = [
      cmake
      installShellFiles
      makeWrapper
      ncurses
      pkg-config
      python3
    ];

    buildInputs = rpathLibs
      ++ lib.optionals stdenv.isDarwin [
      AppKit
      CoreGraphics
      CoreServices
      CoreText
      Foundation
      libiconv
      OpenGL
    ];

    outputs = [ "out" "terminfo" ];

    postPatch = ''
      substituteInPlace alacritty/src/config/ui_config.rs \
        --replace xdg-open ${xdg-utils}/bin/xdg-open
    '';

    checkFlags = [ "--skip=term::test::mock_term" ]; # broken on aarch64

    postInstall = (
      if stdenv.isDarwin then ''
        mkdir $out/Applications
        cp -r extra/osx/Alacritty.app $out/Applications
        ln -s $out/bin $out/Applications/Alacritty.app/Contents/MacOS
      '' else ''
        install -D extra/linux/Alacritty.desktop -t $out/share/applications/
        install -D extra/linux/org.alacritty.Alacritty.appdata.xml -t $out/share/appdata/
        install -D extra/logo/compat/alacritty-term.svg $out/share/icons/hicolor/scalable/apps/Alacritty.svg
        # patchelf generates an ELF that binutils' "strip" doesn't like:
        #    strip: not enough room for program headers, try linking with -N
        # As a workaround, strip manually before running patchelf.
        strip -S $out/bin/alacritty
        patchelf --set-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/alacritty
      ''
    ) + ''
      installShellCompletion --zsh extra/completions/_alacritty
      installShellCompletion --bash extra/completions/alacritty.bash
      installShellCompletion --fish extra/completions/alacritty.fish
      install -dm 755 "$out/share/man/man1"
      gzip -c extra/alacritty.man > "$out/share/man/man1/alacritty.1.gz"
      gzip -c extra/alacritty-msg.man > "$out/share/man/man1/alacritty-msg.1.gz"
      install -Dm 644 alacritty.yml $out/share/doc/alacritty.yml
      install -dm 755 "$terminfo/share/terminfo/a/"
      tic -xe alacritty,alacritty-direct -o "$terminfo/share/terminfo" extra/alacritty.info
      mkdir -p $out/nix-support
      echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
    '';

    dontPatchELF = true;

    passthru.tests.test = nixosTests.terminal-emulators.alacritty;

    meta = with lib; {
      description = "A cross-platform, GPU-accelerated terminal emulator";
      homepage = "https://github.com/alacritty/alacritty";
      license = licenses.asl20;
      maintainers = with maintainers; [ Br1ght0ne mic92 ma27 ];
      platforms = platforms.unix;
      changelog = "https://github.com/alacritty/alacritty/blob/v${version}/CHANGELOG.md";
    };
  };
}

