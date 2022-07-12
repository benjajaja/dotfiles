NixOS dotfiles

```
stow home
sudo stow root -t /
```

Edit `/etc/nixos/configuration.nix` as usual and import `./common.nix`, e.g.:

```
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./common.nix
    ];

  networking.hostName = "motherbase"; # Define your hostname.

  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.useGlamor = true;
  services.xserver.xrandrHeads = [ "DP-3" "eDP-1" ];

}
```

