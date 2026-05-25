# flake.nix

Entry point for the NixOS configuration.

## Inputs

- **nixpkgs**: `github:nixos/nixpkgs/nixos-unstable`
- **home-manager**: `github:nix-community/home-manager` (follows nixpkgs)

## Outputs

Two NixOS configurations:

### elysia

Gaming desktop workstation.

- Profiles: base, workstation, developer, gaming
- Home Manager: full config (home/mizutani.nix)

### canto

Thinkpad X1 Carbon laptop.

- Profiles: base, workstation, gaming, laptop
- Home Manager: minimal config (base profile only)

## Special Args

Both hosts receive:

- `inputs` - All flake inputs
- `self` - Reference to this flake
- `hostname` - The host's name
