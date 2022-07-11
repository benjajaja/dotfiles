# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./hardware-configuration-extra.nix
      <home-manager/nixos>
    ];


  # A DBus service that allows applications to update firmware
  services.fwupd.enable = true;

  networking.hostName = "motherbase"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Atlantic/Canary";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  services.dbus = {
    enable = true;
    packages = [ pkgs.dconf ];
  };

  services.gnome.gnome-keyring.enable = true;
  services.upower.enable = true;


  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.autorandr.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

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
    lidSwitchDocked = "ignore";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nano # leave this as last resort editor!
    #vim
    #neovim
    wget
    git
    killall
    nixos-option

    lightlocker
    inputplug
    firefox
    dmenu
    arandr
    xfce.thunar
    flameshot
    light
    gnome.adwaita-icon-theme
    gimp

    nodejs
    yarn
    go_1_18
    python3
    python39Packages.pip
    gopls
    nodePackages.typescript-language-server

    gnumake
    gcc
    awscli
    vcprompt

    (steam.override {
       withPrimus = true;
       extraPkgs = pkgs: [ bumblebee glxinfo ];
    }).run
  ];

  services.xserver = {
    enable = true;
    dpi = 150;
    videoDrivers = [ "modesetting" ];
    useGlamor = true;
    xrandrHeads = [ "DP-3" "eDP-1" ];

    # custom xkb is loaded by home-manager, this is fallback
    layout = "us";
    xkbVariant = "";
    xkbOptions = "caps:swapescape,altwin:swap_lalt_lwin";

    libinput = {
      enable = true;
      touchpad.disableWhileTyping = true;
    };
    synaptics.tapButtons = false;

    displayManager = {
    gdm.enable = false;
    lightdm = {
          enable = true;
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

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
  };

  # does not work together with altgr-intl, but home-manager sets proper X keymap
  console.useXkbConfig = true;

  environment.variables = {
    # dpi
    #GDK_SCALE = "2";
    #GDK_DPI_SCALE = "0.5";
    #_JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  };

  fonts.fonts = with pkgs; [
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
        " barbar
        let bufferline = get(g:, 'bufferline', {})
        let bufferline.icons = v:false
        let bufferline.closable = v:false
        let bufferline.icon_close_tab = '·'
        let bufferline.icon_close_tab_modified = '●'
        let bufferline.icon_custom_colors = v:true
        let bufferline.maximum_padding = 1
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
  };

  systemd.services.mywarp = {
    enable = true;
    description = "Warp server";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      ExecStart = "/home/gipsy/.nix-profile/bin/warp-svc";
    };
    wantedBy = [ "multi-user.target" ];
  };

  system.stateVersion = "22.05"; # Did you read the comment?
}

