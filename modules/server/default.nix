# Server base configuration
{ config, pkgs, lib, ... }:

{
  imports = [
    ./ssh.nix
  ];

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Minimal server packages
  environment.systemPackages = with pkgs; [
    tmux
    dig
    pciutils
    usbutils
    age
    sops
    ssh-to-age
  ];

  # Journald limits
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=2week
  '';
}
