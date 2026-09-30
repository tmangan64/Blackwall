{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.blackwall.books;
  storageCfg = config.blackwall.storage;

  # Container state (settings, logs, app.db) lives on the root SSD; only the
  # library and the ingest folder sit on the media disk.
  calibreStateDir = "/var/lib/calibre-web-automated";
  shelfmarkStateDir = "/var/lib/shelfmark";
in
{
  # Books - Calibre-Web-Automated for storage and reading, Shelfmark for
  # discovery and download.
  #
  # Both run as podman containers rather than native services. Neither is
  # packaged in nixpkgs: Shelfmark is Docker-only (Flask plus a bundled
  # Chromium for source scraping), and while nixpkgs does have a
  # services.calibre-web, plain Calibre-Web has no ingest-folder watcher, so
  # Shelfmark's downloads would need a hand-rolled calibredb timer to get into
  # the library. CWA has that watcher built in and is what Shelfmark documents
  # integrating with. arr.nix already selects the podman backend for
  # FlareSolverr, so the precedent exists.
  #
  # The integration between the two is a single shared directory: Shelfmark's
  # download target *is* CWA's ingest folder. CWA imports each finished file
  # into the library and then deletes it from the ingest folder, so nothing
  # accumulates there.
  #
  # The containers want PUID/PGID as numbers. The media group in storage.nix is
  # created without an explicit gid, so its number was allocated dynamically at
  # first activation and Nix cannot know it at evaluation time. Pinning it after
  # the fact is the obvious fix and also the dangerous one: a wrong number
  # re-owns the media user and orphans everything under /media. So the ids are
  # resolved at runtime instead, by books-container-ids.service writing an
  # environment file that both containers read. That needs nothing from the host
  # and keeps working if the media gid ever changes.
  #
  # The books user's primary group is the media group, so the containers write
  # as books:media and the existing 2775 media directories are group-writable to
  # them without any ownership changes.
  options.blackwall.books = {
    enable = mkEnableOption "Books media stack (Calibre-Web-Automated + Shelfmark)";

    libraryPath = mkOption {
      type = types.path;
      default = "${storageCfg.basePath}/library/books";
      defaultText = literalExpression ''"''${config.blackwall.storage.basePath}/library/books"'';
      description = ''
        Calibre library root, holding metadata.db and the book files. CWA
        creates the library here on first start if the directory is empty, so
        there is no seeding step.
      '';
    };

    ingestPath = mkOption {
      type = types.path;
      default = "${storageCfg.basePath}/downloads/complete/books";
      defaultText = literalExpression ''"''${config.blackwall.storage.basePath}/downloads/complete/books"'';
      description = ''
        Shared ingest folder: Shelfmark writes finished downloads here and CWA
        watches it, imports into the library, and deletes the originals.
        Follows the downloads/complete/<service> layout arr.nix uses.
      '';
    };

    calibrePort = mkOption {
      type = types.port;
      default = 8083;
      description = "Local port Calibre-Web-Automated listens on, behind caddy-tailscale.";
    };

    shelfmarkPort = mkOption {
      type = types.port;
      default = 8084;
      description = "Local port Shelfmark listens on, behind caddy-tailscale.";
    };

    uid = mkOption {
      type = types.int;
      default = 2000;
      description = ''
        Static uid for the books user the containers run as. Pinned rather than
        allocated so that file ownership under the library is stable and
        legible. Kept clear of the 400-999 range NixOS allocates system users
        from and of 1000+ where normal users live.
      '';
    };

    timeZone = mkOption {
      type = types.str;
      default = config.time.timeZone;
      defaultText = literalExpression "config.time.timeZone";
      description = "Timezone passed to both containers as TZ.";
    };
  };

  config = mkIf cfg.enable {
    # Storage provides the media group and the library directory tree
    assertions = [{
      assertion = storageCfg.enable;
      message = "blackwall.books requires blackwall.storage to be enabled";
    }];

    # oci-containers uses rootful podman with no user namespace remapping, so
    # the PUID/PGID the containers are given are host ids directly. Primary
    # group is the media group, which is what makes the existing 2775
    # directories writable without re-owning anything.
    users.users.books = {
      isSystemUser = true;
      uid = cfg.uid;
      group = storageCfg.group;
      description = "Books stack container user";
    };

    systemd.tmpfiles.rules = [
      # Ingest folder. setgid, so files the containers create stay in the media
      # group and remain readable by the other media services.
      "d ${cfg.ingestPath} 2775 books ${storageCfg.group} -"

      # Container state on the root SSD. The library directory itself is left
      # entirely to storage.nix: a second rule for that path here would fight
      # with it, and the one declared last wins on every activation.
      "d ${calibreStateDir} 0750 books ${storageCfg.group} -"
      "d ${shelfmarkStateDir} 0750 books ${storageCfg.group} -"
    ];

    # Resolve the numeric ids the containers need. The media gid is allocated at
    # activation time and so is not available during evaluation; this writes it
    # out just before the containers start. PUID/PGID are deliberately set only
    # here and not in the containers' `environment`, because podman lets --env
    # override --env-file.
    systemd.services.books-container-ids = {
      description = "Resolve uid/gid for the books stack containers";
      before = [ "podman-calibre-web-automated.service" "podman-shelfmark.service" ];
      requiredBy = [ "podman-calibre-web-automated.service" "podman-shelfmark.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        RuntimeDirectory = "books";
        RuntimeDirectoryPreserve = true;
      };
      script = ''
        printf 'PUID=%s\nPGID=%s\n' \
          "$(${pkgs.coreutils}/bin/id -u books)" \
          "$(${pkgs.coreutils}/bin/id -g books)" \
          > /run/books/ids.env
      '';
    };

    # Already set by arr.nix for FlareSolverr; types.enum merges identical
    # definitions, so restating it here keeps this module standalone.
    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers = {
      calibre-web-automated = {
        image = "crocodilestick/calibre-web-automated:latest";
        # Loopback only - reached through caddy-tailscale, so there is nothing
        # to open in the firewall.
        ports = [ "127.0.0.1:${toString cfg.calibrePort}:8083" ];
        environment = {
          TZ = cfg.timeZone;
          # caddy-tailscale is the single proxy in front of this.
          TRUSTED_PROXY_COUNT = "1";
        };
        # PUID/PGID, written by books-container-ids.service.
        environmentFiles = [ "/run/books/ids.env" ];
        volumes = [
          "${calibreStateDir}:/config"
          "${cfg.libraryPath}:/calibre-library"
          "${cfg.ingestPath}:/cwa-book-ingest"
        ];
      };

      shelfmark = {
        image = "ghcr.io/calibrain/shelfmark:latest";
        ports = [ "127.0.0.1:${toString cfg.shelfmarkPort}:8084" ];
        environment = {
          TZ = cfg.timeZone;
          INGEST_DIR = "/books";
        };
        environmentFiles = [ "/run/books/ids.env" ];
        volumes = [
          "${shelfmarkStateDir}:/config"
          # Same host directory as CWA's ingest bind - this is the whole
          # integration between the two.
          "${cfg.ingestPath}:/books"
        ];
      };
    };

    # Wait for the media filesystem. Without this, a slow or failed disk lets
    # CWA start against an empty directory and create a second, empty library
    # over the top of the real one.
    systemd.services.podman-calibre-web-automated.unitConfig.RequiresMountsFor =
      [ cfg.libraryPath cfg.ingestPath ];
    systemd.services.podman-shelfmark.unitConfig.RequiresMountsFor =
      [ cfg.ingestPath ];

    # Caddy-Tailscale reverse proxy
    services.caddy-tailscale.services = {
      books = { port = cfg.calibrePort; };
      shelfmark = { port = cfg.shelfmarkPort; };
    };
  };
}
