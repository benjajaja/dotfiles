# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "2";
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.plymouth.enable = true;
  boot.supportedFilesystems = [ "ntfs" ];
  # boot.kernelModules = [ "i2c-dev" ]; # for ddcutils (monitors)

  # A DBus service that allows applications to update firmware
  services.fwupd.enable = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.extraHosts =
  ''
    192.168.1.131 shield
  '';

  # Set your time zone.
  time.timeZone = "Atlantic/Canary";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  services.dbus = {
    enable = true;
    packages = [ pkgs.dconf ];
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    # extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.swaylock.text = ''
    # PAM configuration file for the swaylock screen locker. By default, it includes
    # the 'login' configuration file (see /etc/pam.d/login)
    auth include login
  '';
  security.polkit.enable = true;
  services.upower.enable = true;
  services.gvfs.enable = true;


  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.autorandr.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  hardware.bluetooth.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gipsy = {
    isNormalUser = true;
    description = "gipsy";
    extraGroups = [ "networkmanager" "wheel" "docker" "disk" "audio" "video" ];
    packages = with pkgs; [
    ];
  };
  home-manager.useGlobalPkgs = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        libgdiplus
      ];
    };
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  virtualisation.docker.enable = true;

  services.logind = {
    lidSwitch = "suspend"; # also default
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "suspend";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nano # leave this as last resort editor!
    wget
    git
    killall
    nixos-option
    stow
    glxinfo
    inxi
    xorg.xdpyinfo
    pciutils
    refind
    efibootmgr

    lightlocker
    inputplug
    firefox
    dmenu
    arandr
    xfce.thunar
    light
    gnome.adwaita-icon-theme
    gimp
    greetd.tuigreet

    gnumake
    gcc
    ssm-session-manager-plugin
    vcprompt

    (steam.override {
       # withPrimus = true;
       extraPkgs = pkgs: [ glxinfo ];
    }).run

    htop
    docker-compose
    oxker
    xclip
    xbindkeys

    # wayland
    sway
    swaylock-effects
    swayidle
    swaybg
    kickoff
    foot
    cagebreak
    swayrbar
    swayr
    playerctl
    grim
    slurp
    bemenu
    # xdg-utils

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

    bat
    tree-sitter
    dbeaver-bin
    postgresql # for pg_dump

    ripgrep
    sd
    fd

    unzip
    zip
    unar

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
    xorg.xwd
    imagemagick

    # media apps
    losslesscut-bin
    vlc
    quaternion
    libsForQt5.neochat
    gtk3
    lmms
    menyoki
    blender

  ];

  services.libinput = {
      enable = true;
      touchpad = {
        disableWhileTyping = true;
        tapping = false;
        clickMethod = "buttonareas";
      };
  };

  services.xserver = {
    enable = true;
    dpi = 150;

    # custom xkb is loaded by home-manager, this is fallback
    xkb = {
      variant = "";
      options = "caps:swapescape,altwin:swap_lalt_lwin";
      layout = "us";
    };

    displayManager = {
      startx.enable = true;
      defaultSession = "none+xmonad";
      lightdm = {
          enable = false;
          greeters.mini = {
            enable = true;
            user = "gipsy";
            extraConfig = ''
                [greeter]
                show-password-label = true
                password-label-text = PASSWORD:
                password-alignment = left
                password-input-width = 16
                show-sys-info = true
                [greeter-theme]
                background-image = ""
                background-color = "#601019"
                font = "ProFont"
                window-color = "#dd2137"
                border-color = "#080800"
                password-character = *
            '';
          };
        };
    };
    desktopManager.gnome.enable = true;

    windowManager = {
      xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };
    };
  };

  # does not work together with altgr-intl, but home-manager sets proper X keymap
  console.useXkbConfig = true;

  environment.variables = {
    # QT_QPA_PLATFORM = "wayland";
    # dpi
    #GDK_SCALE = "2";
    #GDK_DPI_SCALE = "0.5";
    #_JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  };

  # fonts.packages = with pkgs; [
  fonts.packages = with pkgs; [
    fira-code fira-mono
    (nerdfonts.override { fonts = [
      "FiraCode"
      "DroidSansMono"
      "ProFont"
      "Mononoki"
      "ShareTechMono"
    ]; })
  ];

  programs = {
    bash = {
      shellAliases = {
        nv = "nvim";
      };
      promptInit = ''
        PROMPT_COLOR="1;31m"
        let $UID && PROMPT_COLOR="1;32m"
        PS1="\[\033[$PROMPT_COLOR\]\w:\$(vcprompt -f %b%m%u)> \[\033[0m\]"
      '';
    };
    dconf.enable = true;
    light.enable = true;
    neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      defaultEditor = true;
      withRuby = false;
      configure.packages.neovimPlugins = with pkgs.vimPlugins; {
        start = [ vim-nix barbar-nvim vim-repeat vim-surround nerdcommenter ];
      };
      configure.customRC = ''
        syntax enable
        set softtabstop=2
        set tabstop=2
        set shiftwidth=2
        set expandtab
        nnoremap <silent>    <C-PageUp> :BufferPrevious<CR>
        nnoremap <silent>    <C-PageDown> :BufferNext<CR>
        nnoremap <silent>    <C-K> :BufferPrevious<CR>
        nnoremap <silent>    <C-J> :BufferNext<CR>
        nnoremap <silent>    <C-H> :BufferMovePrevious<CR>
        nnoremap <silent>    <C-L> :BufferMoveNext<CR>
        nnoremap <silent>    <C-W> :BufferClose<CR>
      '';
    };
    steam = {
      enable = true;
    };
    ssh = {
      startAgent = true;
    };
  };
  qt.platformTheme = "qt5ct";

  services.blueman.enable = true;

  services.udev.packages = with pkgs; [qmk-udev-rules];
  
  # For ddcutils (monitors)
  # services.udev.extraRules = "KERNEL==\"i2c-[0-9]*\", GROUP+=\"users\"";

  # services.pgadmin = {
    # enable = true;
    # initialEmail = "benjamin.grosse@re-cap.com";
  # };

  # nixpkgs.overlays = [
    # (self: super: {
      # fcitx-engines = self.fcitx5;
    # })
  # ];

  services.auto-cpufreq.settings = {
    enable = true;
    battery = {
       governor = "powersave";
       turbo = "never";
    };
    charger = {
       governor = "performance";
       turbo = "auto";
    };
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib # numpy
    ];
  };

  # kanshi systemd service
  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
    };
  };
  services.greetd = {
    enable = true;
    settings = rec {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet -t -r --asterisks -s \"/etc/tuigreeter/sessions\"";
      };
    };
  };
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
  environment.etc."tuigreeter/sessions/sway".text = ''
    [Desktop Entry]
    Name=Sway
    Exec="${pkgs.sway}/bin/sway --unsupported-gpu"
    '';
  environment.etc."tuigreeter/sessions/bash".text = ''
    [Desktop Entry]
    Name=bash
    Exec="${pkgs.bash}/bin/bash"
    '';
  environment.etc."tuigreeter/sessions/xorg".text = ''
    [Desktop Entry]
    Name=Xorg
    Exec="${pkgs.xorg.xinit}/bin/startx"
    '';

  # services.pipewire = {
    # enable = true;
    # alsa.enable = true;
    # pulse.enable = true;
  # };

  system.stateVersion = "22.05"; # Did you read the comment?
}

