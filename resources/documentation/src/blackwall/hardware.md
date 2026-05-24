# Hardware

## Storage

```
/dev/nvme0n1    1TB NVMe
├── ESP         1GB     /boot
└── root        rest    /

/dev/sda1       1TB SATA    /srv/data
```

Configured via Disko with `noatime` mount options.

## Boot

```nix
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
boot.kernelPackages = pkgs.linuxPackages_latest;
```

## Firmware

Intel microcode with xhci_pci, ahci, nvme, usb_storage modules.
