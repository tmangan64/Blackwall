# Security

Hardened server configuration.

## SSH

Port 33, key-only authentication.

```nix
services.openssh = {
  enable = true;
  ports = [ 33 ];
  settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
    X11Forwarding = false;
  };
};
```

Connect: `ssh -p 33 mizutani@192.168.0.55`

## Fail2Ban

Exponential backoff for repeat offenders.

```nix
services.fail2ban = {
  enable = true;
  maxretry = 5;
  bantime = "1h";
  bantime-increment = {
    enable = true;
    multipliers = "1 2 4 8 16 32 64";
    maxtime = "168h";
  };
};
```

| Offence | Ban Time |
|---------|----------|
| 1st | 1 hour |
| 2nd | 2 hours |
| 3rd | 4 hours |
| 7th | 64 hours |

## User

Immutable, SSH-key only.

```nix
users.mutableUsers = false;

users.users.mizutani = {
  isNormalUser = true;
  shell = pkgs.bash;
  hashedPasswordFile = config.sops.secrets."admin/password_hash".path;
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5..."
  ];
};

users.users.root.hashedPassword = "!";
security.sudo.wheelNeedsPassword = false;
```

## Secrets

SOPS with age encryption.

```nix
sops = {
  defaultSopsFile = ../../secrets/secrets.yaml;
  age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  secrets = {
    "admin/password_hash".neededForUsers = true;
    "nextcloud/admin_password" = {
      owner = "nextcloud";
      group = "nextcloud";
    };
  };
};
```

Edit secrets: `sops secrets/secrets.yaml`
