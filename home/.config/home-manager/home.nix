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
  swaymonad = (builtins.getFlake "github:nicolasavru/swaymonad").packages.x86_64-linux.swaymonad;
  # pandas = pkgs.callPackage ./pandas.nix {};
  # gtk-demos = pkgs.callPackage ./gtk-demos.nix {};

  # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts  
  # some user services to make sure they have the correct environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      export QT_QPA_PLATFORM=wayland
      # dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE NIXOS_OZONE_WL MOZ_ENABLE_WAYLAND SDL_VIDEODRIVER _JAVA_AWT_WM_NONREPARENTING XDG_SESSION_DESKTOP; systemctl --user start sway-session.target
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY QT_QPA_PLATFORM=wayland XDG_CURRENT_DESKTOP=sway DISPLAY SWAYSOCK
      # systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      # systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };
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
    swaymonad
    dbus-sway-environment
    configure-gtk

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
    tmux

    # programs
    pista
    dmitri
    tig
    chromium
    libreoffice
    inkscape
    transmission-gtk
    gnome_mplayer
    gnomecast
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
    delve
    #pre-commit
    terraform
    cypress
    nodePackages.prettier
    nodePackages.eslint
    vscode
    nodePackages.serverless
    git-recent
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
    nil
    ruff
    uv

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
    cargo-fuzz
    cmake
    pkg-config
    elmPackages.elm-language-server
    elmPackages.elm-test
    elmPackages.elm-format
    # wine
    wine64

    pista
    dmitri
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
        export GRIT_INSTALL="$HOME/.grit"
        PATH="$HOME/venvs/default/bin:$HOME/.local/bin:$PATH:/home/$USER/go/bin:/home/$USER/.cargo/bin:$GRIT_INSTALL/bin"
        export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
        function find_and_replace() {
          set -e
          find . -type f -name @1 -exec sed -i @2 {} \;
        }
      '';
      sessionVariables = {
        EDITOR = "nvim";
        MOZ_ENABLE_WAYLAND=1;
        SDL_VIDEODRIVER=wayland;
        _JAVA_AWT_WM_NONREPARENTING=1;
        QT_QPA_PLATFORM=wayland;
        XDG_CURRENT_DESKTOP=sway;
        XDG_SESSION_DESKTOP=sway;
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
          size = 12.0;
          bold.style = "normal";
        };
        colors = {
          draw_bold_text_with_bright_colors = true;
        };
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
  font_size = 12,
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
    enable = true;
    # wrapperFeatures.gtk = true;
    # config = {
      # modifier = "Mod4";
      # terminal = "alacritty";
      # startup = [{command = "firefox";}];
    # };
  };

  nixpkgs.config.allowUnfree = true;
  xdg.configFile."sway/config".source = lib.mkForce ./sway/config;
}
