{ pkgs, ... }:
with import <nixpkgs> {};
let
  compiledLayout = pkgs.runCommand "keyboard-layout" {} ''
    ${pkgs.xorg.xkbcomp}/bin/xkbcomp ${./xkb/layout.xkb} $out
  '';
  git-recent = pkgs.callPackage ./git-recent.nix {};

  iamb = (builtins.getFlake "github:benjajaja/iamb/nix").packages.x86_64-linux.default;

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

  mdfried = builtins.getFlake "github:benjajaja/mdfried/v0.12.0";
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
    mate.mate-applets
    brightnessctl
    gvfs
    samba
    rubik
    obs-studio
    emote
    swayidle
    swaylock-effects
    wl-clipboard

    # terminals
    alacritty
    contour
    ctx
    wezterm
    kdePackages.konsole
    tmux
    ghostty
    enlightenment.terminology

    # programs
    starship
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
    nodejs_24
    nodePackages.pnpm
    nodePackages.yarn
    nodePackages.typescript-language-server
    go
    gopls
    delve
    pre-commit
    terraform
    # nodePackages.prettier
    # nodePackages.eslint
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
    uv
    devenv
    gh
    niv

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

    mdfried.packages.${pkgs.system}.default
    glow
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
        nv = "nvim";
        ne = "neovide --multigrid -- --cmd 'cd ~/p/core' --cmd 'set mouse=a'";
        xc = "xclip -selection clipboard";
        gow = "gotestsum --watch";
        k = "fc -s";
      };
      initExtra = ''
        #export PROMPT_CHAR=">"
        #export HIDE_HOME_CWD=1
        #export PROMPT_CHAR_COLOR="green"
        #export PROMPT_CHAR_ROOT_COLOR="green"
        #export SHORTEN_CWD=1
        #export CWD_COLOR="yellow"
        export PS1='\[\033[33m\]~\[\033[32m\] >\[\033[0m\] '
        eval "$(starship init bash)"
        set -o vi
        set show-mode-in-prompt on
        set vi-cmd-mode-string "\1\e[2 q\2"
        set vi-ins-mode-string "\1\e[6 q\2"
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
    # starship = {
      # enable = true;
      # settings = {
        # add_newline = false;
        # directory = {
          # truncation_length = 3;
          # truncation_symbol = "";
          # truncate_to_repo = false;
          # style = "yellow";
          # read_only = " 🔒";
          # read_only_style = "red";
          # home_symbol = "~";
          # format = "[$path]($style)[$read_only]($read_only_style) ";
        # };
        # git_branch = {
          # format = "\\[[$branch]($style)";
          # style = "bright-black";
        # };
        # git_status = {
          # format = "[$conflicted$deleted$renamed$modified$typechanged$staged$untracked]($style)\\]";
          # style = "red";
          # ahead = "⇡";
          # behind = "⇣";
          # diverged = "⇕";
          # untracked = "?";
          # stashed = "^";
          # modified = "!";
          # staged = "+";
          # renamed = "»";
          # deleted = "✘";
        # };
        # character = {
          # success_symbol = " [>](green)";
          # error_symbol = " [>](red)";
          # vimcmd_symbol = " [<](green)";
        # };
        # cmd_duration = {
          # min_time = 500;
          # format = "took [$duration](yellow) ";
        # };
        # aws.disabled = true;
        # azure.disabled = true;
        # buf.disabled = true;
        # c.disabled = true;
        # cmake.disabled = true;
        # cobol.disabled = true;
        # conda.disabled = true;
        # container.disabled = true;
        # dart.disabled = true;
        # deno.disabled = true;
        # docker_context.disabled = true;
        # dotnet.disabled = true;
        # elixir.disabled = true;
        # elm.disabled = true;
        # erlang.disabled = true;
        # gcloud.disabled = true;
        # git_commit.disabled = true;
        # git_state.disabled = true;
        # golang.disabled = true;
        # guix_shell.disabled = true;
        # haskell.disabled = true;
        # haxe.disabled = true;
        # helm.disabled = true;
        # hg_branch.disabled = true;
        # hostname.disabled = true;
        # java.disabled = true;
        # jobs.disabled = true;
        # julia.disabled = true;
        # kotlin.disabled = true;
        # kubernetes.disabled = true;
        # line_break.disabled = true;
        # lua.disabled = true;
        # memory_usage.disabled = true;
        # meson.disabled = true;
        # nim.disabled = true;
        # nix_shell.disabled = true;
        # nodejs.disabled = true;
        # ocaml.disabled = true;
        # openstack.disabled = true;
        # package.disabled = true;
        # perl.disabled = true;
        # php.disabled = true;
        # pulumi.disabled = true;
        # purescript.disabled = true;
        # python.disabled = true;
        # raku.disabled = true;
        # ruby.disabled = true;
        # rust.disabled = true;
        # scala.disabled = true;
        # shell.disabled = true;
        # shlvl.disabled = true;
        # singularity.disabled = true;
        # spack.disabled = true;
        # status.disabled = true;
        # sudo.disabled = true;
        # swift.disabled = true;
        # terraform.disabled = true;
        # time.disabled = true;
        # username.disabled = true;
        # vagrant.disabled = true;
        # vcsh.disabled = true;
        # vlang.disabled = true;
        # zig.disabled = true;
      # };
    # };
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
      # font = {
        # name = "ProFontWindows Nerd Font Mono";
        # size = 12;
        # bold_font = "Mononoki Nerd Font Mono Bold";
        # italic_font = "Mononoki Nerd Font Mono Italic";
        # bold_italic_font = "Mononoki Nerd Font Mono Bold Italic";
      # };
      settings = {
        # shell_integration = "no-cursor";
        cursor_shape = "block";
        cursor_shape_unfocused = "hollow";
        scrollback_lines = 10000;
        # bold_text_in_bright_colors = true;
        # italic_text = true;
        # background = "#282c34";
        background = "#1c1a23";
        # font_family = "ProFontWindows Nerd Font Mono";
        font_family = "EnvyCodeR Nerd Font Mono";
        font_size = 12;
        # bold_font = "Hurmit Nerd Font Mono";
        # italic_font = "Hurmit Nerd Font Mono";
        # bold_italic_font = "Hurmit Nerd Font Mono";
      };
      shellIntegration = {
        enableBashIntegration = true;
        mode = "no-cursor";
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

  services = {
    udiskie.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
}
