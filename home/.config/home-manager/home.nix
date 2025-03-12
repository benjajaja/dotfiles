{ pkgs, ... }:
with import <nixpkgs> {};
let
  compiledLayout = pkgs.runCommand "keyboard-layout" {} ''
    ${pkgs.xorg.xkbcomp}/bin/xkbcomp ${./xkb/layout.xkb} $out
  '';
  pista = pkgs.callPackage ./pista.nix {};
  git-recent = pkgs.callPackage ./git-recent.nix {};

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
      export QT_QPA_PLATFORM_PLUGIN_PATH="${qt5.qtbase.bin}/lib/qt-${qt5.qtbase.version}/plugins/platforms"
      #export SDL_VIDEODRIVER=wayland
      # dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE NIXOS_OZONE_WL MOZ_ENABLE_WAYLAND SDL_VIDEODRIVER _JAVA_AWT_WM_NONREPARENTING XDG_SESSION_DESKTOP; systemctl --user start sway-session.target
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY QT_QPA_PLATFORM=wayland QT_QPA_PLATFORM_PLUGIN_PATH="${qt5.qtbase.bin}/lib/qt-${qt5.qtbase.version}/plugins/platforms" XDG_CURRENT_DESKTOP=sway DISPLAY SWAYSOCK
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

  mdfried = builtins.getFlake "github:benjajaja/mdfried/v0.9.0";
  ghostty = builtins.getFlake "github:ghostty-org/ghostty/v1.0.0";
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

  nixpkgs.overlays = [
    (import ./overlays.nix)
  ];

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
    swappy
    grim
    slurp
    xfce.xfce4-clipman-plugin
    dunst
    udiskie
    mate.mate-applets
    brightnessctl
    gvfs
    samba
    rubik
    obs-studio

    # terminals
    alacritty
    contour
    ctx
    wezterm
    konsole
    tmux
    ghostty.packages.${pkgs.system}.default
    enlightenment.terminology

    # programs
    pista
    tig
    chromium
    libreoffice
    inkscape
    transmission_3-gtk # transmission_4-gtk
    transmission-remote-gtk
    jackett
    celluloid
    gnomecast
    fractal
    iamb
    ncdu
    gnupg
    awscli
    _1password-cli
    jq
    file # joshuto file preview mimetype
    exiftool # joshuto file preview
    postgresql # for pg_dump
    dbeaver-bin
    eza
    parquet-tools
    zed-editor

    # dev
    nodejs_18
    nodePackages.pnpm
    nodePackages.yarn
    nodePackages.typescript-language-server
    go
    gopls
    delve
    #pre-commit
    terraform
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
    python313
    #python312Packages.virtualenv
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
    #uv
    devenv
    gh

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
    pyright
    # wine
    wine64

    pista
    mdfried.packages.${pkgs.system}.default
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
        export SDL_VIDEODRIVER=wayland # steam?
      '';
      sessionVariables = {
        EDITOR = "nvim";
        MOZ_ENABLE_WAYLAND=1;
        NIXOS_OZONE_WL = "1";
        SDL_VIDEODRIVER=wayland;
        _JAVA_AWT_WM_NONREPARENTING=1;
        QT_QPA_PLATFORM=wayland;
        QT_QPA_PLATFORM_PLUGIN_PATH="${qt5.qtbase.bin}/lib/qt-${qt5.qtbase.version}/plugins/platforms";
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
        size = 12;
      };
      settings = {
        shell_integration = "no-cursor";
        cursor_shape = "block";
        cursor_shape_unfocused = "hollow";
        scrollback_lines = 10000;
        bold_text_in_bright_colors = true;
        italic_text = true;
        # background = "#282c34";
        background = "#1c1a23";
      };
      # theme = "Tokyo Night";
      # theme = "Cyberpunk";
    };
    foot = {
      enable = true;
      settings = {
        main = {
          #term = "xterm-256color";
          font = "ProFontWindows Nerd Font Mono:size=12";
          #dpi-aware = "yes";
        };
        mouse = {
          hide-when-typing = "yes";
        };
        cursor = {
          style = "block";
          unfocused-style = "hollow";
        };
      };
    };
    wezterm = {
      enable = true;
      extraConfig = ''
return {
  front_end = "WebGpu",
  font = wezterm.font("ProFontWindows Nerd Font"),
  -- font_size = 14,
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
      extraConfig = {
        sendemail.smtpserver = "smtp.gmail.com";
        sendemail.smtpserverport = "587";
        sendemail.smtpencryption = "tls";
        sendemail.smtpuser = "ste3ls@gmail.com";
        rerere.enabled = true;
      };
    };

    direnv = {
      enable = true;
      # enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };

    firefox = {
      enable = false;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayMenuBar = "never"; # alternatives: "always", "never" or "default-on"
        SearchBar = "unified";
        PasswordManagerEnabled = true;
      };
      profiles.default = {
        #userChrome = builtins.readFile ./userChrome.css;
        settings = {
          #"apz.overscroll.enabled" = true;
          "browser.aboutConfig.showWarning" = false;
          #"general.autoScroll" = true;
          #"toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        #bookmarks = [
          #{
            #name = "wikipedia";
            #tags = ["wiki"];
            #keyword = "wiki";
            #url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&amp;go=Go";
          #}
          #{
            #name = "Samwise PRs";
            #keyword = "sam";
            #url = "https://github.com/monasticventures/samwise/pulls";
          #}
          #{
            #name = "Hacker News Search";
            #tags = ["news" "tech"];
            #keyword = "hn";
            #url = "https://hn.algolia.com/?q=%s";
          #}
        #];
      };
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

  nixpkgs.config.allowUnfree = true;
  #xdg.configFile."sway/config".source = lib.mkForce ./sway/config;
}
