# Elysia - Gaming desktop workstation
{ config, pkgs, inputs, hostname, ... }:

{
  imports = [
    ./hardware.nix
    ../../profiles/base.nix
    ../../profiles/workstation.nix
    ../../profiles/developer.nix
    ../../profiles/gaming.nix
  ];

  system.stateVersion = "25.05";

  # GRUB for dual-boot with Windows
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [ "nouveau" ];

  # Wayland on GNOME
  services.displayManager.gdm.wayland = true;

  # NVIDIA GPU
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    powerManagement.enable = false;
  };
  hardware.graphics.enable32Bit = true;

  # Auto-login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "mizutani";
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Media services
  services.lidarr.enable = true;
  services.prowlarr.enable = true;
  services.qbittorrent.enable = true;

  # Wooting keyboard support
  hardware.wooting.enable = true;

  # Additional packages
  environment.systemPackages = with pkgs; [
    os-prober
    ollama
    efibootmgr
    solaar
    wootility
    wooting-udev-rules
    mdbook
  ];

  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "generic";
  };

  # Home Manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.mizutani = import ../../home/mizutani.nix;
  };
}
