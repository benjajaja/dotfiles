# NixOS dotfiles

1. Install NixOS as usual, set up user shell with git.
2. Clone this repo to `~/dotfiles`, `cd` into it, rename username.
3. Optionally create a machine specific file `root/etc/nixos/machines/<name>.nix`.
4. `stow` the config files to home-manager and root dirs:
```
stow home
sudo stow root -t /
```

Edit `/etc/nixos/configuration.nix` as usual and only import `./machines/<name>.nix`:
```
{ config, pkgs, ... }:

{
  imports = [ 
    ./machines/thinkpad.nix
  ];
}
```
...or just add machine specific configuration there:
```
{ config, pkgs, ... }:

{
  imports = [ 
    ./common.nix
  ];
  boot.initrd.kernelModules = [ "i915" ];
  services.xserver.videoDrivers = [ "modesetting" ];
}
```
5. Run `nixos-rebuild switch` and `home-manager switch`.

# Stow
The "filesystem files" are symlinks to their equivalents in `~/dotfiles`, you
can edit either. When adding some file, run `stow -R home/` or
`sudo stow -R root/ -t /`.
