# Blackwall

A Dendritic NixOS multi-host configuration

# Hosts

The config describes three hosts;

- Elysia - Small form factor desktop PC for gaming, development and productivity.
- Canto - Thinkpad X1 Carbon Gen 1 for development and productivity.
- Blackwall - Beelink ME Pro N150 private server hosting game servers, web servers, media servers and NAS.

## Elysia

```
Hardware:
- Case: Meshroom S
- CPU: Intel i7-12700KF
- GPU: GigaByte GeForce RTX 4070TI
- RAM: 32GB DDR5@6000MHz
- Storage: 2TB NVMe (Windows 10) & 256GB (NixOS#elysia)
```

Named after [Rache Bartmoss](https://cyberpunk.fandom.com/wiki/Rache_Bartmoss)' Cyberdeck.

## Canto

Named after the [Militech Canto](https://cyberpunk.fandom.com/wiki/Militech_Canto)

## Blackwall

```
Beelink ME Pro N150
Storage:
- 1TB NVMe (OS & configs)
- 1TB 3.5" SATA (Nextcloud Data)
```

### Services

Hosting:

- [Astro.js webpage](https://blackwall.cam/)
- DNS server, routing & firewall services for local network
- Jellyfin Media Stack
- Nextcloud NAS
- Soulseek/Nicotine+
- Private Mastodon instance
-
