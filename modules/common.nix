# Common NixOS configuration shared across all machines
{ config, pkgs, lib, inputs, iamb, mdfried, ... }:

let
  git-recent = pkgs.callPackage ../packages/git-recent.nix {};
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.settings.trusted-users = ["root" "@wheel"];

  # Bootloader
  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "keep";
    configurationLimit = 15;
    memtest86.enable = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.plymouth.enable = true;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" "rtl2832" "rtl2830" ]; # tinkering

  # A DBus service that allows applications to update firmware
  services.fwupd.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.0.50.3/32" ];
      privateKeyFile = "/etc/wireguard/laptop.key";
      dns = [ "192.168.8.1" ];
      autostart = false;

      peers = [
        {
          publicKey = "rBuslEAt+tKDXIaqu/wOQQLewhVVWSe8AMFL1iVwNHU=";
          allowedIPs = [
            "10.0.50.0/24"
            "192.168.8.0/24"
          ];
          endpoint = "qdice.wtf:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # Set your time zone
  time.timeZone = "Atlantic/Canary";

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  services.dbus = {
    enable = true;
    packages = [ pkgs.dconf ];
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-gnome pkgs.gnome-keyring ];
    config = {
      common = {
        default = [ "wlr" "gtk" ];
      };
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.swaylock.text = ''
    auth include greetd
  '';
  security.pam.loginLimits = [
    { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
  ];
  security.polkit.enable = true;
  services.upower.enable = true;
  services.gvfs.enable = true;

  # Enable CUPS to print documents
  services.printing.enable = true;
  services.autorandr.enable = false;

  hardware.bluetooth.enable = true;
  hardware.keyboard.qmk.enable = true;

  # Define a user account
  users.users.gipsy = {
    isNormalUser = true;
    description = "gipsy";
    extraGroups = [ "networkmanager" "wheel" "docker" "disk" "audio" "video" "adbusers" "kvm" "dialout" "plugdev"];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

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

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  environment.systemPackages = with pkgs; [
    nano # leave this as last resort editor!
    niri
    waybar
    swaybg
    starship
    busybox
    fish

    xwayland-satellite
    wdisplays
    fuzzel
    wget
    git
    killall
    nixos-option
    stow
    mesa-demos # glxinfo
    inxi
    xorg.xdpyinfo
    pciutils
    ethtool
    usbutils
    traceroute
    inetutils
    iperf
    unrar
    nfs-utils
    imv
    wireguard-tools

    inputplug
    firefox
    dmenu
    xfce.thunar
    xfce.thunar-archive-plugin
    nautilus
    light
    adwaita-icon-theme
    gimp
    tuigreet
    claude-code

    gnumake
    gcc
    ssm-session-manager-plugin
    vcprompt

    (steam.override {
       extraPkgs = pkgs: [ mesa-demos ];
    }).run
    steamcmd
    wine64

    htop
    docker-compose

    # wm session
    hsetroot
    trayer
    networkmanagerapplet
    pa_applet
    pasystray
    dunst
    pavucontrol
    pulseaudio
    pulsemixer
    gvfs
    samba
    rubik
    cbatticon
    flameshot
    swappy
    grim
    slurp
    xfce.xfce4-clipman-plugin
    mate.mate-applets
    brightnessctl
    obs-studio
    emote
    swayidle
    swaylock-effects
    wl-clipboard

    # terminals
    kitty
    xterm
    contour
    ctx
    wezterm
    kdePackages.konsole
    ghostty
    enlightenment.terminology
    warp-terminal

    # programs
    tmux
    qutebrowser
    neovide
    tig
    chromium
    libreoffice
    inkscape
    gnomecast
    nheko
    fractal
    iamb.packages.${pkgs.system}.default
    mdfried.packages.${pkgs.system}.default
    glow
    ncdu
    gnupg
    awscli
    file
    exiftool
    _1password-cli
    jq
    postgresql
    dbeaver-bin
    eza
    parquet-tools
    zed-editor
    transmission_4-gtk
    transmission-remote-gtk
    celluloid
    vscode
    devenv
    gh
    niv
    nodejs
    ffmpeg
    watchexec

    # work dev
    go
    gopls
    delve
    terraform
    git-recent
    python313
    google-cloud-sdk
    nil
    ruff
    mise

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

    bat
    tree-sitter

    ripgrep
    sd
    fd
    fzf

    unzip
    zip
    unar

    # debug / unusual
    mesa-demos # glxinfo
    vulkan-tools
    xorg.xev
    imagemagick
    binutils
    xorg.xwd

    # tinkering
    arduino
    arduino-cli
    gqrx
    rtl_433
    rtl-sdr
    rtl-ais
    sdrpp
    esphome
    (pkgs.python3.withPackages (ps: with ps; [
      esptool
      pyserial
    ]))
    python313Packages.meshtastic
  ];

  services.udev.extraRules = ''
    # CP210x (Silicon Labs) UART
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", GROUP="dialout", MODE="0666"

    # CH340 chips
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", GROUP="dialout", MODE="0666"
  '';

  services.pulseaudio.enable = false;

  services.libinput = {
      enable = true;
      touchpad = {
        disableWhileTyping = true;
        tapping = false;
        clickMethod = "buttonareas";
      };
  };

  services.displayManager = {
    defaultSession = "none+xmonad";
  };

  console.useXkbConfig = true;

  environment.variables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  fonts.packages = with pkgs; [
    fira-code
    fira-mono
    nerd-fonts.agave
    nerd-fonts.droid-sans-mono
    nerd-fonts.envy-code-r
    nerd-fonts.fira-code
    nerd-fonts.hurmit
    nerd-fonts.iosevka-term
    nerd-fonts.monofur
    nerd-fonts.profont
    nerd-fonts.mononoki
    nerd-fonts.shure-tech-mono
    nerd-fonts.terminess-ttf
    nerd-fonts.ubuntu-mono
    profont
    termsyn
    tamsyn
    tamzen
  ];

  programs = {
    bash = {
      shellAliases = {
        nv = "nvim";
      };
      interactiveShellInit = ''
        eval "$(starship init bash)"
        set -o vi
        set show-mode-in-prompt on
        set vi-cmd-mode-string "\1\e[2 q\2"
        set vi-ins-mode-string "\1\e[6 q\2"
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
      gamescopeSession.enable = true;
    };
    ssh = {
      startAgent = false;
    };
    seahorse.enable = true;
  };

  qt.platformTheme = "qt5ct";

  services.blueman.enable = true;

  services.udev.packages = with pkgs; [ qmk-udev-rules rtl-sdr ];

  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
       governor = "powersave";
       turbo = "never";
    };
    charger = {
       governor = "performance";
       turbo = "auto";
    };
  };

  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
      ];
    };
  };

  services.greetd = {
    enable = true;
    settings = rec {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet -t -r --remember-session --asterisks -s \"/etc/tuigreeter/sessions\"";
      };
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  environment.etc."tuigreeter/sessions/niri".text = ''
    [Desktop Entry]
    Name=Niri
    Exec="${pkgs.niri}/bin/niri-session"
    '';
  environment.etc."tuigreeter/sessions/bash".text = ''
    [Desktop Entry]
    Name=bash
    Exec="${pkgs.bash}/bin/bash"
    '';

  services.udisks2.enable = true;

  # Enable NFS client support
  services.rpcbind.enable = true;

  # Define the NFS mount
  fileSystems."/mnt/ops" = {
    device = "ops:/";
    fsType = "nfs4";
    options = [
      "nfsvers=4"
      "nofail"
      "timeo=5"
      "retrans=2"
      "hard"
    ];
  };

  systemd.services.backup-sync = {
    description = "Sync Pictures and Documents to NFS";
    script = ''
      ${pkgs.rsync}/bin/rsync -av --delete /home/gipsy/Pictures/ /mnt/ops/backup/Pictures/
      ${pkgs.rsync}/bin/rsync -av --delete /home/gipsy/Documents/ /mnt/ops/backup/Documents/
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "gipsy";
    };
  };

  systemd.timers.backup-sync = {
    description = "Run backup sync daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  xdg.mime.defaultApplications = {
    "image/jpeg" = "imv.desktop";
    "image/png" = "imv.desktop";
    "image/gif" = "imv.desktop";
    "image/webp" = "imv.desktop";
    "image/svg+xml" = "imv.desktop";
    "image/x-icon" = "imv.desktop";
    "image/vnd.microsoft.icon" = "imv.desktop";
    "image/bmp" = "imv.desktop";
    "image/tiff" = "imv.desktop";
    "image/x-tiff" = "imv.desktop";
    "image/x-canon-cr2" = "imv.desktop";
    "image/x-canon-crw" = "imv.desktop";
    "image/x-nikon-nef" = "imv.desktop";
    "image/x-sony-arw" = "imv.desktop";
    "image/x-pixmap" = "imv.desktop";
    "image/x-portable-pixmap" = "imv.desktop";
    "image/x-portable-graymap" = "imv.desktop";
    "image/x-portable-bitmap" = "imv.desktop";
  };

  system.stateVersion = "22.05";
}
