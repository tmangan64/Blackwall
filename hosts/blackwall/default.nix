# Blackwall - Beelink homeserver
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/common
    ../../modules/server
    ../../modules/server/networking.nix
    ../../modules/server/secrets.nix
    ../../modules/server/caddy.nix
    ../../modules/server/adguard.nix
    ../../modules/server/nextcloud.nix
    ../../modules/server/media.nix
    ../../modules/server/auto-upgrade.nix
    ../../modules/server/disko.nix
    ../../modules/users/mizutani-server.nix
  ];

  system.stateVersion = "24.11";
}
