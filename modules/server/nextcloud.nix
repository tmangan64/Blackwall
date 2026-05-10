# Nextcloud configuration
{ config, lib, pkgs, ... }:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud33;
    hostName = "cloud.home";
    https = true;
    datadir = "/srv/data/nextcloud";

    settings = {
      trusted_proxies = [ "127.0.0.1" ];
      trusted_domains = [ "cloud.home" ];
      overwriteprotocol = "https";
      default_phone_region = "GB";
      maintenance_window_start = 1;
    };

    config = {
      adminuser = "admin";
      adminpassFile = config.sops.secrets."nextcloud/admin_password".path;
      dbtype = "pgsql";
      dbname = "nextcloud";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
    };

    database.createLocally = true;
    configureRedis = true;
    caching.redis = true;

    phpOptions = {
      "opcache.interned_strings_buffer" = "16";
      "opcache.memory_consumption" = "256";
    };

    maxUploadSize = "16G";
  };

  services.nginx.virtualHosts."cloud.home" = {
    listen = [{
      addr = "127.0.0.1";
      port = 8080;
    }];
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [{
      name = "nextcloud";
      ensureDBOwnership = true;
    }];
  };

  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" "srv-data.mount" ];
    after = [ "postgresql.service" "srv-data.mount" ];
  };
}
