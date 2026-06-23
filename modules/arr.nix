{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.blackwall.arr;
  storageCfg = config.blackwall.storage;
in
{
  options.blackwall.arr = {
    enable = mkEnableOption "Arr* media management suite";
  };

  config = mkIf cfg.enable {
    # Ensure storage is enabled
    assertions = [{
      assertion = storageCfg.enable;
      message = "blackwall.arr requires blackwall.storage to be enabled";
    }];

    # Jellyfin - Media server
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      group = storageCfg.group;
    };

    # Radarr - Movie management
    services.radarr = {
      enable = true;
      openFirewall = true;
      group = storageCfg.group;
    };

    # Prowlarr - Indexer manager
    services.prowlarr = {
      enable = true;
      openFirewall = true;
    };

    # Transmission - Torrent client
    services.transmission = {
      enable = true;
      openFirewall = true;
      group = storageCfg.group;
      settings = {
        download-dir = "${storageCfg.basePath}/downloads/complete";
        incomplete-dir = "${storageCfg.basePath}/downloads/incomplete";
        incomplete-dir-enabled = true;
        watch-dir = "${storageCfg.basePath}/downloads/torrents";
        watch-dir-enabled = true;
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist-enabled = false;
        rpc-host-whitelist-enabled = false;
        umask = 2; # Results in 775 permissions
      };
    };

    # Jellyseerr - Media request management (for Jellyfin)
    services.jellyseerr = {
      enable = true;
      openFirewall = true;
    };

    # Add service users to media group for shared file access
    users.users.jellyfin.extraGroups = [ storageCfg.group ];
    users.users.radarr.extraGroups = [ storageCfg.group ];
    users.users.transmission.extraGroups = [ storageCfg.group ];

    # Caddy-Tailscale reverse proxy entries
    services.caddy-tailscale.services = {
      jellyfin = { port = 8096; };
      radarr = { port = 7878; };
      prowlarr = { port = 9696; };
      transmission = { port = 9091; };
      jellyseerr = { port = 5055; };
    };
  };
}
