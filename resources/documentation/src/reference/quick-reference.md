# Quick Reference

Common commands and information.

## Rebuild

```sh
# Desktop
sudo nixos-rebuild switch --flake .#elysia
sudo nixos-rebuild switch --flake .#canto

# Server
sudo nixos-rebuild switch --flake .#blackwall
```

## Update

```sh
nix flake update
sudo nixos-rebuild switch --flake .
```

## SSH to Server

```sh
ssh -p 33 mizutani@192.168.0.55
```

## Service Management

```sh
systemctl status <service>
systemctl restart <service>
journalctl -u <service> -f
```

## Garbage Collection

```sh
sudo nix-collect-garbage -d
```

## Rollback

```sh
sudo nixos-rebuild switch --rollback
```

## Web Interfaces

| Service | URL |
|---------|-----|
| AdGuard Home | https://dns.home |
| Nextcloud | https://cloud.home |

## Network

| Host | IP |
|------|-----|
| blackwall | 192.168.0.55 |
| gateway | 192.168.0.1 |

## Secrets

```sh
sops secrets/secrets.yaml
```
