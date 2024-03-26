{ pkgs, ... }:
with import <nixpkgs> {};
let
  compiledLayout = pkgs.runCommand "keyboard-layout" {} ''
    ${pkgs.xorg.xkbcomp}/bin/xkbcomp ${./xkb/layout.xkb} $out
  '';
  pista = pkgs.callPackage ./pista.nix {};
  dmitri = pkgs.callPackage ./dmitri.nix {};
  git-recent = pkgs.callPackage ./git-recent.nix {};
  # iamb = pkgs.callPackage ./iamb.nix {};
  iamb = (builtins.getFlake "github:benjajaja/iamb/nix").packages.x86_64-linux.default;
  # pandas = pkgs.callPackage ./pandas.nix {};
  # gtk-demos = pkgs.callPackage ./gtk-demos.nix {};
in
{
  imports = [
    ./vim.nix
  ];
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "gipsy";
  home.homeDirectory = "/home/gipsy";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    htop
    docker-compose
    oxker
    xclip
    xbindkeys

    # wayland
    sway
    swaylock
    swayidle
    swaybg
    dmenu
    foot
    cagebreak

    # wm session
    hsetroot
    trayer
    networkmanagerapplet
    pa_applet
    pasystray
    cbatticon
    mictray
    flameshot
    xfce.xfce4-clipman-plugin
    dunst
    pavucontrol
    udiskie
    mate.mate-applets
    brightnessctl
    gvfs
    samba
    rubik

    # terminals
    alacritty
    contour
    ctx
    wezterm
    ueberzugpp
    tmux

    # programs
    qutebrowser
    pista
    dmitri
    neovide
    tig
    tdesktop
    chromium
    libreoffice
    inkscape
    transmission-gtk
    gnome_mplayer
    gnomecast
    nheko
    fractal
    gomuks
    iamb
    ncdu
    gnupg
    awscli
    file # joshuto file preview mimetype
    exiftool # joshuto file preview

    # dev
    nodejs_18
    nodePackages.pnpm
    nodePackages.yarn
    nodePackages.typescript-language-server
    go
    gopls
    gotestsum
    #pre-commit
    terraform
    cypress
    tree-sitter
    bat
    nodePackages.prettier
    nodePackages.eslint
    vscode
    nodePackages.serverless
    git-recent
    ripgrep
    sd
    fd
    #python311
    #python311Packages.pip
    #python311Packages.pip-tools
    #python311Packages.setuptools
    #python311Packages.virtualenv
    #python311Packages.nodeenv
    # pandas
    #python311Packages.numpy
    #python312
    python312
    #python312Packages.pip
    #(python312.withPackages (ps: with ps; [
      #pip
      #pip-tools
      #setuptools
      #virtualenv
      #nodeenv
      #numpy
      #pandas
    #]))
    google-cloud-sdk
    dbeaver
    nil
    postgresql
    ruff

    # apps
    slack-term
    unzip
    zip
    unar
    losslesscut-bin
    vlc
    signal-desktop
    quaternion
    mirage-im
    libsForQt5.neochat
    gtk3
    lmms
    menyoki
    blender

    # hobby dev
    rustc
    cargo
    cargo-deny
    cargo-watch
    rust-analyzer
    clippy
    rustfmt
    cargo-watch
    cargo-readme
    cargo-make
    cmake
    pkg-config
    elmPackages.elm-language-server
    elmPackages.elm-test
    elmPackages.elm-format
    # wine
    wine64

    # debug / unusual
    glxinfo
    vulkan-tools
    xorg.xkbcomp
    xorg.xev
    xorg.xwd
    imagemagick
    xvfb-run
    xdummy
    binutils # a bunch of helper bins, a lot of build tools need some

    # games
    dolphin-emu
    python39Packages.ds4drv
    ryujinx
  ];

  home.file = {
    xbindkeysrc = {
      enable = true;
      target = ".xbindkeysrc";
      text = ''
        "dbus-send --dest=app.junker.mictray --type=method_call /app/junker/mictray app.junker.mictray.ToggleMute"
           XF86AudioMicMute
      '';
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };

  programs = {
    bash = {
      enable = true;
      bashrcExtra = ''
        PATH="$HOME/venvs/default/bin:$HOME/.local/bin:$PATH:/home/$USER/go/bin:/home/$USER/.cargo/bin"
        function find_and_replace() {
          set -e
          find . -type f -name @1 -exec sed -i @2 {} \;
        }
      '';
      sessionVariables = {
        EDITOR = "nvim";
      };
      shellAliases = {
        ne = "neovide --multigrid -- --cmd 'cd ~/p/core' --cmd 'set mouse=a'";
        xc = "xclip -selection clipboard";
        gow = "gotestsum --watch";
      };
      initExtra = ''
        export PROMPT_CHAR=">"
        export HIDE_HOME_CWD=1
        export PROMPT_CHAR_COLOR="green"
        export PROMPT_CHAR_ROOT_COLOR="green"
        export SHORTEN_CWD=1
        export CWD_COLOR="yellow"
        export PS1='$(pista -m)'
        set -o vi
        set show-mode-in-prompt on
        set vi-cmd-mode-string "\1\e[2 q\2"
        set vi-ins-mode-string "\1\e[6 q\2"
        # eval "$(direnv hook bash)"
      '';
    };
    readline = {
      enable = true;
      extraConfig = ''
        set show-mode-in-prompt on
        set vi-cmd-mode-string "\1\e[2 q\2"
        set vi-ins-mode-string "\1\e[3 q\2"
        set keyseq-timeout 50
      '';
    };
    alacritty = {
      enable = true;
      settings = {
        font = {
          normal.family = "ProFontWindows Nerd Font Mono";
          size = 16.0;
          bold.style = "normal";
        };
        draw_bold_text_with_bright_colors = true;
        env = {
          WINIT_X11_SCALE_FACTOR = "1.2";
        };
        keyboard.bindings = [
          { key = "K"; mods = "Control|Shift"; action = "ScrollPageUp"; }
          { key = "J"; mods = "Control|Shift"; action = "ScrollPageDown"; }
        ];
      };
    };
    kitty = {
      enable = true;
      font = {
        name = "ProFontWindows Nerd Font Mono";
        size = 19.2;
      };
      # theme = "Tokyo Night";
      # theme = "Cyberpunk";
    };
    wezterm = {
      enable = true;
      extraConfig = ''
return {
  font = wezterm.font("ProFontWindows Nerd Font Mono"),
  font_size = 19.2,
  bold_brightens_ansi_colors = "BrightOnly",
  color_scheme = "Tokyo Night",
  window_padding = {
    left = 4,
    right = 4,
    top = 0,
    bottom = 4,
  },
  enable_tab_bar = false,
  cursor_blink_rate = 400,
  cursor_thickness = 2,
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "EaseOut",
}
      '';
    };
    git = {
      enable = true;
      userName = "Benjamin Große";
      userEmail = "ste3ls@gmail.com";
      aliases = {
          pff = "pull --ff-only";
          psu = "push -u origin HEAD";
      };
      includes = [{
        contents = {
# [gpg]
	# format = ssh
# [user]
	# signingKey = /home/gipsy/.ssh/id_ed25519.pub
# [commit]
	# gpgsign = true
          gpg = {
            format = "ssh";
          };
          user = {
            signingkey = "/home/gipsy/.ssh/id_ed25519.pub";
          };
          commit = {
            gpgSign = true;
          };
        };
      }];
    };
    direnv = {
      enable = true;
      # enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };
  };

  xsession = {
    enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = ./xmonad.hs;
    };
    initExtra = ''
      hsetroot -extend $HOME/.config/wallpaper.png -gamma 0.5 &
      xsetroot -cursor_name left_ptr
      trayer --edge top --align right --SetPartialStrut true --transparent true --tint 0x000000 -l --height 32 --iconspacing 4 --expand false &
      dunst &
      nm-applet &
      pasystray &
      mictray &
      xfce4-clipman &
      cbatticon &
      flameshot &
      udiskie -t -a -n -f thunar &
      blueman-applet &
      light-locker --lock-after-screensaver=30 &
      xset s 1800
      { echo "XIDeviceEnabled XISlaveKeyboard" ; inputplug -d -c echo ; } |
      while read event
      do
          case $event in
          XIDeviceEnabled*XISlaveKeyboard*)
              ${pkgs.xorg.xkbcomp}/bin/xkbcomp ${compiledLayout} $DISPLAY
              ${pkgs.xorg.xset}/bin/xset r rate 200 40
                  ;;
          esac
      done &
      xbindkeys
      export QT_AUTO_SCREEN_SCALE_FACTOR=1
    '';
  };
  wayland.windowManager.sway = {
    enable = false;
    config = {
      modifier = "Mod4";
      terminal = "alacritty";
      startup = [{command = "firefox";}];
    };
  };

  nixpkgs.config.allowUnfree = true;
}
