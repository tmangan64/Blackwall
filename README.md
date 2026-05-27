# Blackwall

A Dendritic NixOS multi-host configuration

## Structure

```
Blackwall/
├── flake.nix
├── hosts/
│   ├── elysia/                    # Gaming desktop
│   └── canto/                     # Thinkpad laptop
├── profiles/
│   ├── base.nix                   # Shared base (user, nix, locale)
│   ├── workstation.nix            # Desktop environment
│   ├── developer.nix              # Dev tools, containers
│   ├── gaming.nix                 # Steam, gaming
│   └── laptop.nix                 # Laptop-specific
├── modules/
│   ├── audio.nix                  # Pipewire
│   ├── fonts.nix                  # System fonts
│   ├── locale.nix                 # Timezone, locale
│   └── nix-settings.nix           # Flakes, unfree
├── home/
│   ├── mizutani.nix               # Main home config
│   └── profiles/
│       ├── base.nix               # Shell, terminal
│       ├── desktop.nix            # Productivity apps
│       ├── developer.nix          # Dev tools
│       └── gaming.nix             # Gaming packages
├── source/                        # Original config (archived)
└── resources/                     # Documentation
```

### Planned Services

```
- Astro.js webpage (blackwall.cam)
- DNS server, routing & firewall services for local network (AdGuard Home)
- Jellyfin Media Stack, TubeArchivist & Tunarr
- Nextcloud NAS
- Soulseek/Nicotine+
- Private Mastodon instance
- Authentik identity management
- Home Assistant
- Gitea
- n8n/local LLM
- Homebox for item, kitchen and hardware inventory management
- Mealie
- WireGuard
- code-server
```

### Archive

The server will also host archived copies of public repositories for local access:

```
- https://github.com/lockfale/osint-framework
- https://github.com/Augani/openreel-video
- https://github.com/trimstray/the-book-of-secret-knowledge
- https://github.com/coderamp-labs/pad.ws
- https://github.com/fmhy/edit
- https://github.com/Lifeforge-app/lifeforge
- https://github.com/nilbuild/developer-roadmap
- https://github.com/codecrafters-io/build-your-own-x
- https://github.com/kaifcodec/ytconverter
- https://github.com/usememos/memos
- https://github.com/piotrkulpinski/openalternative
- https://x.com/d2cliparchive
- https://x.com/destiny2team
```

## Architecture

| Layer | Description |
|-------|-------------|
| `profiles/` | Composable system feature sets |
| `modules/` | Atomic, single-purpose modules |
| `home/` | Home Manager with profiles |


## Resources

https://github.com/tkashkin/Adwaita-for-Steam