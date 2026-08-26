{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.blackwall.vikunja;
in
{
  options.blackwall.vikunja = {
    enable = mkEnableOption "Vikunja project management";
  };

  config = mkIf cfg.enable {
    services.vikunja = {
      enable = true;
      frontendScheme = "https";
      frontendHostname = "vikunja.tail222568.ts.net";
      database = {
        type = "sqlite";
      };
      settings = {
        service = {
          enableregistration = true;
        };
      };
    };

    # Caddy-Tailscale reverse proxy
    services.caddy-tailscale.services = {
      vikunja = { port = 3456; };
    };
  };
}
