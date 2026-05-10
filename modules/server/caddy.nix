# Caddy reverse proxy
{ config, lib, pkgs, ... }:

{
  services.caddy = {
    enable = true;

    virtualHosts = {
      "dns.home" = {
        extraConfig = ''
          tls internal
          reverse_proxy localhost:3000
        '';
      };

      "cloud.home" = {
        extraConfig = ''
          tls internal
          reverse_proxy localhost:8080
        '';
      };
    };
  };
}
