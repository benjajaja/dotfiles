{ pkgs, ... }:
{
  imports = [
    ./vim.nix
  ];

  home.username = "gipsy";
  home.homeDirectory = "/home/gipsy";
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
        NIXOS_OZONE_WL = "1";  # Electron apps
        _JAVA_AWT_WM_NONREPARENTING = "1";
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_DESKTOP = "niri";
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
          normal.family = "EnvyCodeR Nerd Font Mono";
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
      settings = {
        cursor_shape = "block";
        cursor_shape_unfocused = "hollow";
        scrollback_lines = 10000;
        background = "#1c1a23";
        font_family = "EnvyCodeR Nerd Font Mono";
        font_size = 12;
        "map ctrl+shift+page_up" = "scroll -24";
        "map ctrl+shift+page_down" = "scroll 24";
        "map ctrl+page_up" = "scroll -1";
        "map ctrl+page_down" = "scroll 1";
      };
      shellIntegration = {
        enableBashIntegration = true;
        mode = "no-cursor";
      };
    };

    foot = {
      enable = true;
      settings = {
        main = {
          font = "ProFontWindows Nerd Font Mono:size=12";
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
      lfs.enable = true;
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
      settings = {
        core = {
          pager = "delta";
        };
        interactive = {
          diffFilter = "delta --color-only";
        };
        delta = {
          navigate = true;  # use n and N to move between diff sections
          dark = true;      # or light = true, or omit for auto-detection
        };
        merge = {
          conflictStyle = "zdiff3";
        };
        user = {
          name = "Benjamin Große";
          email = "ste3ls@gmail.com";
        };
        alias = {
          pff = "pull --ff-only";
          mff = "merge --ff-only";
          psu = "push -u origin HEAD";
          ccc = "commit --no-verify";
        };
        sendemail = {
          smtpserver = "smtp.gmail.com";
          smtpserverport = "587";
          smtpencryption = "tls";
          smtpuser = "ste3ls@gmail.com";
        };
        rerere.enabled = true;
      };
    };

    direnv = {
      enable = true;
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
        DisplayMenuBar = "never";
        SearchBar = "unified";
        PasswordManagerEnabled = true;
      };
      profiles.default = {
        settings = {
          "browser.aboutConfig.showWarning" = false;
        };
      };
    };
  };

  services = {
    udiskie.enable = true;
  };
}
