# NixOS Dotfiles (Flakes)

This repository uses Nix flakes for reproducible NixOS configuration.

## Structure

```
~/dotfiles/
├── flake.nix              # Entry point - defines all inputs and hosts
├── flake.lock             # Pinned dependency versions
├── hosts/                 # Machine-specific configurations
│   ├── thinkpad/          # hostname: motherbase
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   ├── slimbook/          # hostname: lz
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── falcon/            # hostname: falcon
│       ├── default.nix
│       └── hardware-configuration.nix
├── modules/
│   ├── common.nix         # Shared system configuration
│   ├── falcon-sensor.nix  # CrowdStrike module
│   └── home/              # Home-manager configuration
│       ├── home.nix
│       ├── vim.nix
│       └── *.lua
├── packages/              # Custom package definitions
│   ├── git-recent.nix
│   ├── git-recent
│   └── falcon-sensor.nix
└── home/                  # Non-Nix dotfiles (use stow)
    └── .config/
        ├── niri/
        ├── waybar/
        ├── starship.toml
        └── ...
```

## Fresh Install

1. Boot NixOS installer and install minimal system
2. Clone this repo:
   ```bash
   git clone <repo-url> ~/dotfiles
   cd ~/dotfiles
   ```
3. Copy hardware configuration for your machine:
   ```bash
   cp /etc/nixos/hardware-configuration.nix hosts/<machine>/
   ```
4. Build and switch:
   ```bash
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

   Where `<hostname>` is one of: `motherbase`, `lz`, `falcon`

5. Stow non-Nix dotfiles:
   ```bash
   stow home
   ```

## Daily Usage

### Rebuild system
```bash
sudo nixos-rebuild switch --flake ~/dotfiles#<hostname>
```

### Update all inputs (nixpkgs, home-manager, etc.)
```bash
nix flake update
sudo nixos-rebuild switch --flake ~/dotfiles#<hostname>
```

### Update a single input
```bash
nix flake lock --update-input nixpkgs
```

### Test configuration without switching
```bash
sudo nixos-rebuild test --flake ~/dotfiles#<hostname>
```

### Build without activating
```bash
sudo nixos-rebuild build --flake ~/dotfiles#<hostname>
```

## Adding a New Machine

1. Create directory: `mkdir -p hosts/<name>`
2. Create `hosts/<name>/default.nix` with machine-specific config
3. Copy hardware config: `cp /etc/nixos/hardware-configuration.nix hosts/<name>/`
4. Add to `flake.nix`:
   ```nix
   nixosConfigurations = {
     # ...existing...
     <name> = mkHost "<name>";
   };
   ```

## Non-Nix Dotfiles (Stow)

The `home/` directory contains configuration files that aren't managed by Nix/home-manager.
These are symlinked to your home directory using stow:

```bash
# Initial setup
stow home

# After adding new files
stow -R home
```

## Flake Inputs

| Input | Description |
|-------|-------------|
| `nixpkgs` | NixOS unstable packages |
| `home-manager` | Home directory management |
| `iamb` | Matrix client |
| `mdfried` | Markdown renderer |

## Hosts

| Hostname | Machine | Description |
|----------|---------|-------------|
| `motherbase` | ThinkPad | Intel laptop with Cloudflare Warp |
| `lz` | Slimbook | AMD/NVIDIA hybrid laptop |
| `falcon` | Desktop | Intel desktop |
