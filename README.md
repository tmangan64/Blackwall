# Blackwall

A Dendritic NixOS multi-host configuration

## Structure

```
Blackwall/
├── flake.nix                      # Single flake defining all 3 hosts
├── hosts/
│   ├── blackwall/                 # Homeserver config
│   ├── canto/                     # Thinkpad laptop config
│   └── elysia/                    # Gaming desktop config
├── modules/
│   ├── common/                    # Shared: nix settings, locale
│   ├── desktop/                   # GNOME, audio, gaming
│   ├── server/                    # SSH, caddy, nextcloud, adguard, etc.
│   └── users/
│       ├── mizutani.nix           # Desktop user
│       └── mizutani-server.nix    # Server user (immutable, SSH-only)
├── home/                          # Home Manager config
│   ├── default.nix                # Main home config
│   ├── terminal.nix               # fish, kitty, fastfetch
│   ├── productivity.nix           # obsidian, libreoffice, etc.
│   └── gaming.nix                 # steam, prismlauncher
├── secrets/
│   └── secrets.yaml               # SOPS secrets placeholder
└── .sops.yaml                     # SOPS configuration
```

## Hosts

The config describes three hosts:

- **Elysia** - Small form factor desktop PC for gaming, development and productivity.
- **Canto** - Thinkpad X1 Carbon Gen 1 for development and productivity.
- **Blackwall** - Beelink ME Pro N150 private server hosting game servers, web servers, media servers and NAS.

### Elysia

```
Hardware:
- Case: Meshroom S
- CPU: Intel i7-12700KF@5Ghz
- GPU: GigaByte GeForce RTX 4070TI
- RAM: 32GB DDR5@6000MHz
- Storage: 2TB NVMe (Windows 10) & 256GB (NixOS#elysia)
```

Named after [Rache Bartmoss](https://cyberpunk.fandom.com/wiki/Rache_Bartmoss)' Cyberdeck.

### Canto
```
Hardware:
- Device: Thinkpad X1 Carbon Gen 1
- CPU: Intel i7-3667U@3.2Ghz
- RAM: 8GB
- Storage: 160GB
```

Named after the [Militech Canto](https://cyberpunk.fandom.com/wiki/Militech_Canto).

### Blackwall

```
Beelink ME Pro N150
Storage:
- 1TB NVMe (OS & configs)
- 1TB 3.5" SATA (Nextcloud Data)
```

#### Services

```
- [Astro.js webpage](https://blackwall.cam/)
- DNS server, routing & firewall services for local network (AdGuard Home)
- Jellyfin Media Stack, TubeArchivist & Tunarr
- Nextcloud NAS
- Soulseek/Nicotine+
- Private Mastodon instance
- Authentik identity management
- Home Assistant
- Gitea
- Node Red
- Homebox for item, kitchen and hardware inventory management
- Mealie
- WireGuard
- code-server
```

## Modules

| Module | Description |
|--------|-------------|
| `modules/common/` | Shared base config: nix settings, locale, timezone |
| `modules/desktop/` | GNOME desktop, Pipewire audio, gaming (Steam) |
| `modules/server/` | SSH hardening, fail2ban, Caddy, Nextcloud, AdGuard |
| `modules/users/` | User configurations for desktop and server |
| `home/` | Home Manager: terminal, productivity apps, gaming |
