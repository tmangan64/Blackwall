# Hardware

## Boot

systemd-boot with latest kernel:

```nix
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
boot.kernelPackages = pkgs.linuxPackages_latest;
boot.blacklistedKernelModules = [ "kvm_intel" "kvm" ];
```

## Display

X11 for stability (Wayland disabled):

```nix
services.displayManager.gdm.wayland = false;
services.displayManager.defaultSession = "gnome";
```

## Disabled Services

```nix
services.geoclue2.enable = false;
services.fprintd.enable = false;
```
