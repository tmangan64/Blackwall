# File Paths

Important paths on the system.

## Configuration

| Path | Purpose |
|------|---------|
| `/etc/nixos` | NixOS configuration (symlink) |
| `/nix/store` | Nix store |
| `/nix/var/nix/profiles` | System profiles |

## Server Data

| Path | Purpose |
|------|---------|
| `/srv/data` | SATA drive mount |
| `/srv/data/nextcloud` | Nextcloud data |

## Secrets

| Path | Purpose |
|------|---------|
| `/run/secrets` | Decrypted SOPS secrets |
| `/etc/ssh/ssh_host_ed25519_key` | Age key source |

## Services

| Service | Data Path |
|---------|-----------|
| Nextcloud | `/srv/data/nextcloud` |
| PostgreSQL | `/var/lib/postgresql` |
| Jellyfin | `/var/lib/jellyfin` |
| AdGuard Home | `/var/lib/AdGuardHome` |

## Logs

| Path | Purpose |
|------|---------|
| `/var/log/journal` | systemd journal |

View with:

```sh
journalctl -u <service>
```

## Repository Structure

```
Blackwall/
├── flake.nix
├── flake.lock
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
├── secrets/
└── resources/
    ├── documentation/
    └── site/
```
