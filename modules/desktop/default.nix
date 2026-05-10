# Desktop environment configuration
{ config, pkgs, lib, ... }:

{
  imports = [
    ./audio.nix
  ];

  # X11 and display manager
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Printing
  services.printing.enable = true;

  # Flatpak
  services.flatpak.enable = true;

  # Hardware graphics
  hardware.graphics.enable = true;

  # Programs
  programs.firefox.enable = true;
  programs.fish.enable = true;
  programs.dconf.enable = true;

  # Common desktop packages
  environment.systemPackages = with pkgs; [
    kitty
    fastfetch
    discord
    spotify
    vscode
    github-desktop
    gnome-tweaks
  ];
}
