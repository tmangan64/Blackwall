# Base profile - shared by all hosts
{ config, pkgs, hostname, ... }:

{
  imports = [
    ../modules/nix-settings.nix
    ../modules/locale.nix
  ];

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  # User account
  users.users.mizutani = {
    isNormalUser = true;
    description = "Teague Mangan";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    git
  ];
}
