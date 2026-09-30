{ config, pkgs, lib, ... }:

let
  cfg = config.services.caddy-tailscale;

  # Build Caddy with the tailscale plugin using nixpkgs' withPlugins
  # To update: remove the hash, build, and copy the correct hash from the error
  caddy-with-tailscale = pkgs.caddy.withPlugins {
    plugins = [ "github.com/tailscale/caddy-tailscale@v0.0.0-20250207163903-69a970c84556" ];
    hash = "sha256-rcdUxdgkP33U6F9qd4lqVL+po3YlLdf1PrKFGgZ6tik=";
  };
in
{
  options.services.caddy-tailscale = {
    enable = lib.mkEnableOption "Caddy with Tailscale integration for custom service URLs";

    authKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a systemd EnvironmentFile containing the Tailscale credential.
        Format: TS_AUTHKEY=tskey-auth-...

        Normally rendered by sops-nix rather than written by hand, see
        modules/core/secrets.nix:
          authKeyFile = config.sops.templates."caddy-tailscale.env".path;

        A reusable auth key works but expires (90 days maximum); an OAuth client
        secret goes in the same TS_AUTHKEY slot and does not.

        Generate a reusable auth key at:
        https://login.tailscale.com/admin/settings/keys
      '';
    };

    services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          port = lib.mkOption {
            type = lib.types.port;
            description = "Local port the service is running on";
          };
        };
      });
      default = {};
      example = lib.literalExpression ''
        {
          homepage = { port = 8082; };
          grafana = { port = 3000; };
        }
      '';
      description = ''
        Services to expose via Tailscale with custom URLs.
        Each service will appear as a separate node on your tailnet.
        For example: homepage -> https://homepage.your-tailnet.ts.net
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure Tailscale is enabled
    services.tailscale.enable = true;

    # Create the Caddyfile
    # Each service gets its own Tailscale node and binds to port 443 on that node
    environment.etc."caddy-tailscale/Caddyfile".text = ''
      {
        tailscale {
          ephemeral false
          state_dir /var/lib/caddy-tailscale
        }
      }

      ${lib.concatStringsSep "\n\n" (lib.mapAttrsToList (name: svc: ''
      :443 {
        bind tailscale/${name}
        tls {
          get_certificate tailscale
        }
        reverse_proxy localhost:${toString svc.port}
      }
      '') cfg.services)}
    '';

    # Create a systemd service for our custom Caddy
    systemd.services.caddy-tailscale = {
      description = "Caddy with Tailscale - Custom URL reverse proxy";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" "tailscaled.service" ];
      wants = [ "network-online.target" "tailscaled.service" ];

      # Without this, adding an entry to cfg.services rewrites the Caddyfile
      # but nothing tells activation to act on it: the unit's only other
      # trigger is the sops authkey template, so Caddy keeps serving the old
      # config and the new tailnet node is never created until someone
      # restarts it by hand.
      #
      # A restart rather than a reload, because registering a new node with
      # the control plane needs the tailscale plugin to re-run its auth loop.
      # Restarting is cheap: `ephemeral false` plus the state_dir above means
      # existing nodes reload their persisted identity instead of consuming
      # TS_AUTHKEY again, so only genuinely new names need a live key. The
      # cost is that every tailnet service blips for a few seconds whenever
      # the vhost list changes.
      restartTriggers = [ config.environment.etc."caddy-tailscale/Caddyfile".source ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${caddy-with-tailscale}/bin/caddy run --config /etc/caddy-tailscale/Caddyfile --adapter caddyfile";
        ExecReload = "${caddy-with-tailscale}/bin/caddy reload --config /etc/caddy-tailscale/Caddyfile --adapter caddyfile";
        TimeoutStartSec = "180s";
        TimeoutStopSec = "30s";
        Restart = "on-failure";
        RestartSec = "5s";
        LimitNOFILE = 1048576;
        LimitNPROC = 512;
        PrivateTmp = true;
        ProtectSystem = "full";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";

        # State directory for Tailscale node state
        StateDirectory = "caddy-tailscale";
        WorkingDirectory = "/var/lib/caddy-tailscale";
      } // lib.optionalAttrs (cfg.authKeyFile != null) {
        EnvironmentFile = cfg.authKeyFile;
      };
    };
  };
}
