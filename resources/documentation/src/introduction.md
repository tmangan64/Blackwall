# Introduction

A Dendritic NixOS multi-host configuration.

## Hosts

| Host | Description |
|------|-------------|
| blackwall | Beelink EQ Pro N150 private server |
| elysia | Small form factor gaming desktop |
| canto | ThinkPad X1 Carbon development laptop |

## Structure

```
Blackwall/
├── flake.nix
├── hosts/
│   ├── blackwall/
│   ├── canto/
│   └── elysia/
├── modules/
│   ├── common/
│   ├── desktop/
│   ├── server/
│   └── users/
├── home/
└── secrets/
```

## Modules

| Module | Description |
|--------|-------------|
| `modules/common/` | Shared base config: nix settings, locale, timezone |
| `modules/desktop/` | GNOME desktop, Pipewire audio, gaming |
| `modules/server/` | SSH hardening, fail2ban, Caddy, Nextcloud, AdGuard |
| `modules/users/` | User configurations for desktop and server |
| `home/` | Home Manager: terminal, productivity apps, gaming |

## Source

[github.com/tmangan64/Blackwall](https://github.com/tmangan64/Blackwall)
