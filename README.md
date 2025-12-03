# NixOS Dotfiles (Flakes)

Nix flakes-based NixOS configuration with home-manager integration.

## Structure

```
~/dotfiles/
├── flake.nix              # Entry point - defines inputs and hosts
├── flake.lock             # Pinned dependency versions
├── hosts/
│   ├── thinkpad/          # hostname: motherbase
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── slimbook/          # hostname: lz
│       └── default.nix
├── modules/
│   ├── common.nix         # Shared system configuration
│   ├── falcon-sensor.nix  # CrowdStrike Falcon module
│   └── home/              # Home-manager configuration
│       ├── home.nix       # User packages, git, shell config
│       ├── vim.nix        # Neovim + plugins
│       ├── nvim.lua       # Neovim init
│       ├── lsp.lua        # LSP configuration
│       └── blink.lua      # Blink completion
├── packages/
│   ├── git-recent.nix     # git-recent script package
│   ├── git-recent         # Source script
│   └── falcon-sensor.nix  # CrowdStrike package
└── home/                  # Non-Nix dotfiles (stow)
    └── .config/
        ├── iamb/          # Matrix client config
        ├── niri/          # Niri compositor
        ├── waybar/        # Status bar
        ├── xkb/           # Keyboard layouts
        └── starship.toml  # Shell prompt
```

## Setup

```bash
# Symlink so nixos-rebuild finds the flake automatically
sudo ln -s /home/gipsy/dotfiles /etc/nixos

# Stow non-Nix dotfiles
stow home
```

## Usage

```bash
sudo nixos-rebuild switch          # Rebuild system
sudo nixos-rebuild dry-run         # Test without activating
nix flake update                   # Update all inputs
nix flake lock --update-input nixpkgs  # Update single input
```

## Fresh Install

1. Boot NixOS installer, install minimal system
2. Clone repo: `git clone <url> ~/dotfiles && cd ~/dotfiles`
3. Copy hardware config: `cp /etc/nixos/hardware-configuration.nix hosts/<machine>/`
4. Switch: `sudo nixos-rebuild switch --flake .#<hostname>`
5. Stow configs: `stow home`

## Adding a New Host

1. `mkdir -p hosts/<name>`
2. Create `hosts/<name>/default.nix` (see existing hosts)
3. `cp /etc/nixos/hardware-configuration.nix hosts/<name>/`
4. Add to `flake.nix`: `<hostname> = mkHost "<name>";`

## Flake Inputs

| Input | Description |
|-------|-------------|
| `nixpkgs` | NixOS 25.11 |
| `home-manager` | Home-manager release-25.11 |
| `iamb` | Matrix TUI client |
| `mdfried` | Markdown TUI renderer |

## Hosts

| Hostname | Machine | Description |
|----------|---------|-------------|
| `motherbase` | ThinkPad | Intel laptop, Cloudflare Warp, Falcon Sensor |
| `lz` | Slimbook | AMD/NVIDIA hybrid, PRIME offload |
