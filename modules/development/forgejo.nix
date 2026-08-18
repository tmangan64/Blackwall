{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.blackwall.forgejo;
in
{
  options.blackwall.forgejo = {
    enable = mkEnableOption "Forgejo Git forge";
  };

  config = mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      database.type = "sqlite3";
      lfs.enable = true;
      settings = {
        server = {
          HTTP_PORT = 3000;
          HTTP_ADDR = "127.0.0.1";
          SSH_PORT = 2222;
          SSH_LISTEN_PORT = 2222;
          START_SSH_SERVER = true;
        };
        repository.DEFAULT_BRANCH = "main";
        ui.DEFAULT_THEME = "forgejo-dark";
      };
    };

    networking.firewall.allowedTCPPorts = [ 2222 ];

    # Caddy-Tailscale reverse proxy
    services.caddy-tailscale.services = {
      forgejo = { port = 3000; };
    };
  };
}
