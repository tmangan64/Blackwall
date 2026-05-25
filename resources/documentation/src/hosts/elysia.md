# hosts/elysia

Gaming desktop workstation.

## Profiles

- base
- workstation
- developer
- gaming

## Boot

- GRUB with EFI and OS prober (Windows dual-boot)
- Blacklisted: nouveau

## Display

- GNOME with Wayland
- NVIDIA proprietary drivers
- 32-bit graphics support
- Auto-login enabled

## Services

- lidarr
- prowlarr
- qbittorrent

## Hardware

- Wooting keyboard support
- NVIDIA GPU

## Packages

- os-prober
- ollama
- efibootmgr
- solaar
- wootility
- wooting-udev-rules
- mdbook

## Home Manager

Imports full `home/mizutani.nix` configuration.
