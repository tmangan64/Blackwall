{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.blackwall.mdbook;
  dataDir = "/var/lib/mdbook";
  repoDir = "${dataDir}/repo";
  buildDir = "${dataDir}/book";
in
{
  options.blackwall.mdbook = {
    enable = mkEnableOption "mdbook documentation server";

    repo = mkOption {
      type = types.str;
      default = "https://github.com/tmangan64/BlackwallDocs";
      description = "Git repository URL for the mdbook source";
    };

    port = mkOption {
      type = types.port;
      default = 3080;
      description = "Port to serve the book on";
    };

    updateInterval = mkOption {
      type = types.str;
      default = "hourly";
      description = "How often to pull and rebuild (systemd calendar format)";
    };
  };

  config = mkIf cfg.enable {
    # Ensure mdbook and git are available
    environment.systemPackages = [ pkgs.mdbook pkgs.git ];

    # Create data directory
    systemd.tmpfiles.rules = [
      "d ${dataDir} 0755 root root -"
      "d ${repoDir} 0755 root root -"
      "d ${buildDir} 0755 root root -"
    ];

    # Service to clone/pull and build the book
    systemd.services.mdbook-build = {
      description = "Clone/update and build mdbook";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = [ pkgs.git pkgs.mdbook ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
      };

      script = ''
        set -euo pipefail

        if [ ! -d "${repoDir}/.git" ]; then
          echo "Cloning repository..."
          git clone ${cfg.repo} ${repoDir}
        else
          echo "Pulling latest changes..."
          cd ${repoDir}
          git fetch origin
          git reset --hard origin/HEAD
        fi

        echo "Building mdbook..."
        cd ${repoDir}
        mdbook build --dest-dir ${buildDir}

        echo "Build complete!"
      '';
    };

    # Timer to periodically update the book
    systemd.timers.mdbook-build = {
      description = "Periodically update and rebuild mdbook";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.updateInterval;
        Persistent = true;
        RandomizedDelaySec = "5min";
      };
    };

    # Simple HTTP server using Python to serve the built book
    systemd.services.mdbook-server = {
      description = "Serve mdbook documentation";
      after = [ "network.target" "mdbook-build.service" ];
      wants = [ "mdbook-build.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.python3}/bin/python -m http.server ${toString cfg.port} --directory ${buildDir}";
        Restart = "always";
        RestartSec = "5s";

        # Security hardening
        DynamicUser = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadOnlyPaths = [ buildDir ];
        NoNewPrivileges = true;
        PrivateTmp = true;
      };
    };

    # Caddy-Tailscale reverse proxy
    services.caddy-tailscale.services = {
      docs = { port = cfg.port; };
    };
  };
}
