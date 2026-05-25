# Developer profile - development tools and virtualisation
{ config, pkgs, ... }:

{
  # Virtualisation
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;

  users.users.mizutani.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    nodejs_22
    python3
    gnumake
  ];
}
