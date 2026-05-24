# Configuration

Desktop-specific settings.

## Display

Wayland on GNOME with auto-login:

```nix
services.displayManager.gdm.wayland = true;
services.displayManager.autoLogin.enable = true;
services.displayManager.autoLogin.user = "mizutani";

systemd.services."getty@tty1".enable = false;
systemd.services."autovt@tty1".enable = false;
```

## Virtualisation

```nix
virtualisation.docker.enable = true;
virtualisation.podman.enable = true;
```

## Media Services

```nix
services.lidarr.enable = true;
services.prowlarr.enable = true;
services.qbittorrent.enable = true;
```

## Packages

```nix
environment.systemPackages = with pkgs; [
  os-prober
  nodejs_22
  ollama
  efibootmgr
  solaar
];
```

## Desktop Environment

From `modules/desktop/default.nix`:

```nix
services.xserver.enable = true;
services.displayManager.gdm.enable = true;
services.desktopManager.gnome.enable = true;
services.flatpak.enable = true;

programs.firefox.enable = true;
programs.fish.enable = true;

environment.systemPackages = with pkgs; [
  kitty
  fastfetch
  discord
  spotify
  vscode
  github-desktop
  gnome-tweaks
];
```

## Gaming

```nix
programs.steam.enable = true;

environment.systemPackages = with pkgs; [
  prismlauncher
];
```
