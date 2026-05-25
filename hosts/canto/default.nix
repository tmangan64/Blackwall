# Canto - Thinkpad X1 Carbon laptop
{ config, pkgs, inputs, hostname, ... }:

{
  imports = [
    ./hardware.nix
    ../../profiles/base.nix
    ../../profiles/workstation.nix
    ../../profiles/gaming.nix
    ../../profiles/laptop.nix
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

  # Hyprland (disabled)
  programs.hyprland.enable = false;

  # Fingerprint (disabled)
  services.fprintd.enable = false;
  security.pam.services.gdm.enable = true;
  security.pam.services.login.enable = true;
  security.pam.services.sudo.enable = true;

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
    python314
  ];

  # Home Manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.mizutani = { pkgs, ... }: {
      imports = [
        ../../home/profiles/base.nix
        ../../home/profiles/desktop.nix
        ../../home/profiles/developer.nix
        ../../home/modules/firefox.nix
      ];
      home.username = "mizutani";
      home.homeDirectory = "/home/mizutani";
      home.stateVersion = "25.05";
    };
  };
}
