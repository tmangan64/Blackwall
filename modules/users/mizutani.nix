# Unified user configuration for mizutani
{ config, pkgs, lib, ... }:

{
  users.users.mizutani = {
    isNormalUser = true;
    description = "Teague Mangan";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPHEr9l0xPvco+x1zz2X5skaIwpjtI0+QGOELm/KtV5d kiroshi"
    ];
  };

  users.defaultUserShell = pkgs.fish;
}
