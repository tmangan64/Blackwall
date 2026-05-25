# Blackwall

Multi-host NixOS configuration for desktop and laptop systems.

## Hosts

| Host | Description |
|------|-------------|
| elysia | Gaming desktop with NVIDIA GPU |
| canto | ThinkPad X1 Carbon laptop |

## Structure

```
Blackwall/
├── flake.nix
├── hosts/
│   ├── elysia/
│   └── canto/
├── profiles/
│   ├── base.nix
│   ├── workstation.nix
│   ├── developer.nix
│   ├── gaming.nix
│   └── laptop.nix
├── modules/
│   ├── audio.nix
│   ├── fonts.nix
│   ├── locale.nix
│   └── nix-settings.nix
└── home/
    ├── mizutani.nix
    └── profiles/
        ├── base.nix
        ├── desktop.nix
        ├── developer.nix
        └── gaming.nix
```

## Architecture

- **hosts/** - Machine-specific configuration and hardware
- **profiles/** - Composable system-level feature sets
- **modules/** - Atomic, single-purpose modules
- **home/** - Home Manager user configuration with profiles

## Usage

```bash
sudo nixos-rebuild switch --flake .#elysia
sudo nixos-rebuild switch --flake .#canto
```
