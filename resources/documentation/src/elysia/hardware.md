# Hardware

## NVIDIA

Proprietary drivers with nouveau blacklisted:

```nix
boot.blacklistedKernelModules = [ "nouveau" ];
services.xserver.videoDrivers = [ "nvidia" ];

hardware.nvidia = {
  modesetting.enable = true;
  open = false;
  nvidiaSettings = true;
};

hardware.graphics.enable32Bit = true;
```

## Boot

GRUB for dual-boot with Windows:

```nix
boot.loader.grub = {
  enable = true;
  device = "nodev";
  efiSupport = true;
  useOSProber = true;
};
```
