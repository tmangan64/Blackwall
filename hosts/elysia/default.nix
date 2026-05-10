# Elysia - Gaming desktop workstation
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/common
    ../../modules/desktop
    ../../modules/desktop/gaming.nix
    ../../modules/users/mizutani.nix
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

  # Networking
  networking.networkmanager.enable = true;

  # Auto-login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "mizutani";
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Virtualisation
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;

  # Media services
  services.lidarr.enable = true;
  services.prowlarr.enable = true;
  services.qbittorrent.enable = true;

  # Additional packages
  environment.systemPackages = with pkgs; [
    os-prober
    nodejs_22
    ollama
    efibootmgr
    solaar
  ];

  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "generic";
  };

  # Home Manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.mizutani = import ../../home;
  };
}
