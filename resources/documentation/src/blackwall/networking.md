# Networking

Static IP configuration.

## Network Settings

```nix
networking = {
  domain = "local";
  networkmanager.enable = false;
  useDHCP = false;

  interfaces.enp3s0 = {
    ipv4.addresses = [{
      address = "192.168.0.55";
      prefixLength = 24;
    }];
  };

  defaultGateway = "192.168.0.1";
  nameservers = [ "127.0.0.1" "1.1.1.1" "9.9.9.9" ];

  hosts = {
    "127.0.0.1" = [ "dns.home" "cloud.home" ];
  };
};

services.resolved.enable = false;
```

| Setting | Value |
|---------|-------|
| IP | 192.168.0.55 |
| Subnet | /24 |
| Gateway | 192.168.0.1 |
| Interface | enp3s0 |

## DNS Resolution

| Priority | Server |
|----------|--------|
| 1 | 127.0.0.1 (AdGuard) |
| 2 | 1.1.1.1 (Cloudflare) |
| 3 | 9.9.9.9 (Quad9) |

## Local Rewrites

```nix
# AdGuard Home
rewrites = [
  { domain = "dns.home"; answer = "192.168.0.55"; }
  { domain = "cloud.home"; answer = "192.168.0.55"; }
];
```

## Firewall

```nix
networking.firewall = {
  enable = true;
  allowPing = true;
  allowedTCPPorts = [ 33 53 443 3000 ];
  allowedUDPPorts = [ 53 ];
  logRefusedConnections = true;
};
```
