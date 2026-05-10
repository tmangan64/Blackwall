# Media server stack
{ config, pkgs, lib, ... }:

{
  # Jellyfin media server
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  # Lidarr - Music collection manager
  services.lidarr = {
    enable = true;
    openFirewall = true;
  };

  # Prowlarr - Indexer manager
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  # qBittorrent - Torrent client
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
  };

  # Sonarr - TV series manager
  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  # Radarr - Movie collection manager
  services.radarr = {
    enable = true;
    openFirewall = true;
  };
}
