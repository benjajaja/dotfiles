{ config, pkgs, ... }:

let
  compiledLayout = pkgs.runCommand "keyboard-layout" {} ''
    ${pkgs.xorg.xkbcomp}/bin/xkbcomp ${./xkb/layout.xkb} $out
  '';
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

    # programs
    alacritty
    neovide
    tig
    tdesktop
    chromium
    gotestsum
    pre-commit
    terraform
    cloudflare-warp
    slack-term

    # hobby
    rustc
    cargo
    cmake
    pkg-config
    freetype
    expat

    # debug / unusual
    glxinfo
    vulkan-tools
    xorg.xkbcomp
    xorg.xev
    qmk
  ];

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
        PATH="$PATH:/home/$USER/go/bin"
      '';
      shellAliases = {
        ne = "neovide --multigrid -- --cmd 'cd ~/p/core' --cmd 'set mouse=a'";
      };
    };
    alacritty = {
      enable = true;
      settings = {
        font = {
          normal.family = "ProFontWindows Nerd Font Mono";
          size = 16.0;
          bold.style = "normal";
          use_thin_strokes = true;
        };
        draw_bold_text_with_bright_colors = true;
      };
    };
    git = {
      enable = true;
      userName = "Benjamin Gro??e";
      userEmail = "ste3ls@gmail.com";
      aliases = {
          pff = "pull --ff-only";
          psu = "push -u origin HEAD";
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
    hsetroot -center $HOME/Pictures/skull_on_fire_framed_c700-477x480.jpg &
    trayer --edge top --align right --SetPartialStrut true --transparent true --tint 0x000000 -l --height 32 --iconspacing 4 --expand false &
    dunst &
    nm-applet &
    pa-applet &
    pasystray &
    mictray &
    xfce4-clipman &
    cbatticon &
    flameshot &
    udiskie -t -a -n -f thunar &
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
    '';
  };
    # TODO: remove when this gets merged:
  # https://github.com/NixOS/nixpkgs/blob/ba0e1d31f9c28342c0eb9007e5609e56ed76697d/nixos/modules/services/networking/cloudflare-warp.nix
  # systemd.user.services.mywarp = {
    # enable = true;
  # };
}
