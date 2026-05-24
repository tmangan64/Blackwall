# Configuration

Laptop-specific settings.

## Virtualisation

```nix
virtualisation.virtualbox.host.enable = true;
```

## Packages

```nix
environment.systemPackages = with pkgs; [
  hyprland
  speedtest-cli
  nodejs_24
  lynx
  rWrapper
  rstudio
  wireshark-qt
  mdbook
  conky
  gnumake
];
```

## GNOME Extensions

```nix
environment.systemPackages = with pkgs; [
  gnomeExtensions.vitals
  gnomeExtensions.extension-list
  gnomeExtensions.todo
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
```

## Networking

```nix
networking.networkmanager.enable = true;
```
