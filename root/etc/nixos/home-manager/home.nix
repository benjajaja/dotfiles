{ pkgs, ... }:
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
        export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
        export SDL_VIDEODRIVER=wayland # steam?
        alias claude="/home/gipsy/.claude/local/claude"
      '';
      sessionVariables = {
        EDITOR = "nvim";
        MOZ_ENABLE_WAYLAND=1;
        NIXOS_OZONE_WL = "1";
        SDL_VIDEODRIVER=pkgs.wayland;
        _JAVA_AWT_WM_NONREPARENTING=1;
        QT_QPA_PLATFORM=pkgs.wayland;
        QT_QPA_PLATFORM_PLUGIN_PATH="${pkgs.qt5.qtbase.bin}/lib/qt-${pkgs.qt5.qtbase.version}/plugins/platforms";
        XDG_CURRENT_DESKTOP=pkgs.niri;
        XDG_SESSION_DESKTOP=pkgs.niri;
      };
      shellAliases = {
        nv = "nvim";
        ne = "neovide --multigrid -- --cmd 'cd ~/p/core' --cmd 'set mouse=a'";
        xc = "xclip -selection clipboard";
        gow = "gotestsum --watch";
        k = "fc -s";
      };
      initExtra = ''
        eval "$(starship init bash)"
        set -o vi
        set show-mode-in-prompt on
        set vi-cmd-mode-string "\1\e[2 q\2"
        set vi-ins-mode-string "\1\e[6 q\2"

        function find_and_replace() {
          local search="$1"
          local replace="$2"
          shift 2
          
          find "$@" -type f -exec grep -l "$search" {} \; -exec sh -c 'echo "Modifying: $1" && sed -i "s/'"$search"'/'"$replace"'/g" "$1"' _ {} \;
        }
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
        "map ctrl+shift+page_up" = "scroll -24";
        "map ctrl+shift+page_down" = "scroll 24";
        "map ctrl+page_up" = "scroll -1";
        "map ctrl+page_down" = "scroll 1";
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
          ccc = "commit --no-verify";
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
}
