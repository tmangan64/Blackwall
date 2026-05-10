# Canto - Thinkpad X1 Carbon laptop
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

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.blacklistedKernelModules = [ "kvm_intel" "kvm" ];

  # X11 instead of Wayland for laptop
  services.displayManager.gdm.wayland = false;
  services.displayManager.defaultSession = "gnome";

  # Networking
  networking.networkmanager.enable = true;

  # Disable geoclue (causing issues)
  services.geoclue2.enable = false;

  # Fingerprint (disabled)
  services.fprintd.enable = false;
  security.pam.services.gdm.enable = true;
  security.pam.services.login.enable = true;
  security.pam.services.sudo.enable = true;

  # VirtualBox
  virtualisation.virtualbox.host.enable = true;

  # Additional packages
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
    gnomeExtensions.vitals
    gnomeExtensions.extension-list
    gnomeExtensions.todo
    gnumake
  ];

  # Home Manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.mizutani = import ../../home;
  };
}
