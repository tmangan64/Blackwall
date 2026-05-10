# Common base configuration shared across all hosts
{ config, pkgs, lib, hostname, ... }:

{
  imports = [
    ./nix.nix
    ./locale.nix
  ];

  networking.hostName = hostname;

  # Base packages available on all systems
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    curl
    wget
  ];
}
