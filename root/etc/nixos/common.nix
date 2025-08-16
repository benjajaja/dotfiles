# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.settings.trusted-users = ["root" "@wheel"];
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
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
  # boot.kernelModules = [ "i2c-dev" ]; # for ddcutils (monitors)
  boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" "rtl2832" "rtl2830" ]; # tinkering

  # A DBus service that allows applications to update firmware
  services.fwupd.enable = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Atlantic/Canary";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  services.dbus = {
    enable = true;
    packages = [ pkgs.dconf ];
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-gnome pkgs.gnome-keyring ];
    config = {
      common = {
        default = [ "wlr" "gtk" ];  # Try wlr first, then fallback to gtk
      };
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.swaylock.text = ''
    # PAM configuration file for the swaylock screen locker. By default, it includes
    # the 'login' configuration file (see /etc/pam.d/login)
    auth include login
  '';
  # Enabling this option allows any program run by the "users" group to request real-time priority.
  security.pam.loginLimits = [
    { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
  ];
  security.polkit.enable = true;
  services.upower.enable = true;
  services.gvfs.enable = true;


  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.autorandr.enable = false;

  hardware.bluetooth.enable = true;
  hardware.keyboard.qmk.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gipsy = {
    isNormalUser = true;
    description = "gipsy";
    extraGroups = [ "networkmanager" "wheel" "docker" "disk" "audio" "video" "adbusers" "kvm" "dialout" "plugdev"];
  };
  home-manager.useGlobalPkgs = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Some insecure package
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

  services.logind = {
    lidSwitch = "suspend"; # also default
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nano # leave this as last resort editor!
    niri
    waybar
    swaybg
    # starship
    busybox

    xwayland-satellite
    wdisplays
    fuzzel
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
    ethtool
    usbutils
    traceroute
    inetutils
    iperf
    unrar
    nfs-utils

    inputplug
    firefox
    dmenu
    xfce.thunar
    xfce.thunar-archive-plugin
    nautilus
    light
    adwaita-icon-theme
    gimp
    greetd.tuigreet
    # nodejs_24
    # nodePackages.pnpm
    claude-code

    gnumake
    gcc
    ssm-session-manager-plugin
    vcprompt

    (steam.override {
       # withPrimus = true;
       extraPkgs = pkgs: [ glxinfo ];
    }).run
    steamcmd

    htop
    docker-compose
    oxker

    # wm session
    networkmanagerapplet
    pa_applet
    pasystray
    dunst
    pavucontrol
    pulsemixer
    gvfs
    samba
    rubik

    # terminals
    kitty
    xterm

    # programs
    tmux
    qutebrowser
    neovide
    tig
    tdesktop
    chromium
    libreoffice
    inkscape
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

    ripgrep
    sd
    fd
    fzf

    unzip
    zip
    unar

    # debug / unusual
    glxinfo
    vulkan-tools
    xorg.xev
    imagemagick
    binutils # a bunch of helper bins, a lot of build tools need some
    xorg.xwd

    # tinkering
    arduino
    arduino-cli
    rtl-sdr
    gqrx
    rtl_433
    esphome
    (pkgs.python3.withPackages (ps: with ps; [
      esptool
      pyserial
    ]))
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

  # does not work together with altgr-intl, but home-manager sets proper X keymap
  console.useXkbConfig = true;

  environment.variables = {
    #QT_QPA_PLATFORM = "wayland";
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
      # promptInit = ''
        # eval "$(starship init bash)"
      # '';
      shellAliases = {
        nv = "nvim";
      };
      interactiveShellInit = ''
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
  };
  qt.platformTheme = "qt5ct";

  services.blueman.enable = true;

  services.udev.packages = with pkgs; [qmk-udev-rules];
  
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
        zlib # numpy
      ];
    };
  };

  services.greetd = {
    enable = true;
    settings = rec {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet -t -r --remember-session --asterisks -s \"/etc/tuigreeter/sessions\"";
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

  # services.pipewire = {
    # enable = true;
    # alsa.enable = true;
    # pulse.enable = true;
  # };
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
      ${pkgs.rsync}/bin/rsync -av --delete /home/gipsy/o/matrix/ /mnt/ops/backup/matrix/
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
      Persistent = true;  # Run if system was off during scheduled time
    };
  };

  system.stateVersion = "22.05"; # Did you read the comment?
}

