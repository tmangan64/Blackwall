# Port Map

Open ports on the Blackwall server.

## Firewall Allowlist

### TCP

| Port | Service | Config |
|------|---------|--------|
| 33 | SSH | `modules/server/ssh.nix` |
| 53 | DNS | `modules/server/networking.nix` |
| 443 | HTTPS | `modules/server/networking.nix` |
| 3000 | AdGuard Home | `modules/server/networking.nix` |

### UDP

| Port | Service |
|------|---------|
| 53 | DNS |

## Service Ports

These are opened via `openFirewall = true`:

| Service | Default Port |
|---------|--------------|
| Jellyfin | 8096 |
| Lidarr | 8686 |
| Radarr | 7878 |
| Sonarr | 8989 |
| Prowlarr | 9696 |
| qBittorrent | 8080 |

## Internal Only

| Port | Service | Proxied Via |
|------|---------|-------------|
| 3000 | AdGuard Home | Caddy (dns.home) |
| 8080 | Nextcloud (nginx) | Caddy (cloud.home) |
