{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.blackwall.navidrome;
  storageCfg = config.blackwall.storage;
in
{
  # Navidrome - Subsonic-compatible music streaming server.
  #
  # Storage is split three ways so that moving the media filesystem onto a
  # RAID5/ZFS pool later is a mount-level change rather than a config rewrite:
  #
  #   music   -> blackwall.storage.basePath  (bulk data, mounted read-only here)
  #   state   -> /var/lib/navidrome          (SQLite DB + cache, root SSD)
  #   backups -> blackwall.storage.basePath  (DB dumps, so they land on the pool)
  #
  # Migrating to ZFS:
  #   1. Mount the pool at the SAME path as the current media disk (/media by
  #      default, see hosts/blackwall/hardware.nix). Navidrome keys tracks off
  #      their library paths, so an identical mountpoint avoids a full rescan
  #      and the risk of orphaning play counts, ratings and playlist entries.
  #      If the path must change, change blackwall.storage.basePath - every
  #      path below is derived from it - and expect a full rescan.
  #   2. Stop navidrome, `rsync -aHAX --info=progress2` the old disk into the
  #      new dataset, swap the mount, start navidrome.
  #   3. Suggested dataset properties for the music dataset: recordsize=1M
  #      (large sequential reads), compression=lz4, atime=off, xattr=sa.
  #      Do not put the SQLite DB on a dataset with sync=disabled; leaving
  #      dataPath as-is keeps it on the SSD, which is the better place for it
  #      anyway - the array gains nothing from a latency-bound 100MB database.
  options.blackwall.navidrome = {
    enable = mkEnableOption "Navidrome music streaming server";

    musicPath = mkOption {
      type = types.path;
      default = "${storageCfg.basePath}/library/music";
      defaultText = literalExpression ''"''${config.blackwall.storage.basePath}/library/music"'';
      description = ''
        Music library root. Mounted read-only into Navidrome's sandbox, so
        Navidrome can never write to or reorganise the library itself.
      '';
    };

    dataPath = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Where Navidrome keeps its SQLite database, cache and artwork.

        null keeps them in the systemd StateDirectory, /var/lib/navidrome, on
        the root SSD. Set this only to move state onto the pool as well; stop
        the service and move the existing contents of /var/lib/navidrome across
        first, or Navidrome will start from an empty database and rescan.
      '';
    };

    backupPath = mkOption {
      type = types.nullOr types.path;
      default = "${storageCfg.basePath}/backups/navidrome";
      defaultText = literalExpression ''"''${config.blackwall.storage.basePath}/backups/navidrome"'';
      description = ''
        Directory for Navidrome's nightly database backups, kept off the root
        SSD so a dead system disk does not take the library metadata with it.
        Set to null to disable backups.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 4533;
      description = "Local port Navidrome listens on, behind caddy-tailscale.";
    };
  };

  config = mkIf cfg.enable {
    # Storage provides the media group and the library directory tree
    assertions = [{
      assertion = storageCfg.enable;
      message = "blackwall.navidrome requires blackwall.storage to be enabled";
    }];

    services.navidrome = {
      enable = true;

      # Run as the media group rather than adding navidrome to it as a
      # supplementary group: the upstream unit sets PrivateUsers = true, which
      # maps only the service's own uid/gid into the namespace and leaves
      # supplementary groups as nobody.
      group = storageCfg.group;

      settings = {
        # Bound to loopback only - reached through caddy-tailscale, so there is
        # nothing to open in the firewall.
        Address = "127.0.0.1";
        Port = cfg.port;
        MusicFolder = cfg.musicPath;
      } // optionalAttrs (cfg.dataPath != null) {
        DataFolder = cfg.dataPath;
      } // optionalAttrs (cfg.backupPath != null) {
        Backup = {
          Path = cfg.backupPath;
          Schedule = "0 4 * * *";
          Count = 7;
        };
      };
    };

    # The upstream unit bind-mounts these paths into its sandbox and fails to
    # start if they do not exist yet.
    systemd.tmpfiles.rules =
      optional (cfg.dataPath != null)
        "d ${cfg.dataPath} 0750 navidrome ${storageCfg.group} -"
      ++ optional (cfg.backupPath != null)
        "d ${cfg.backupPath} 0750 navidrome ${storageCfg.group} -";

    # Wait for the media filesystem. Without this, a slow or failed disk (or
    # pool) lets Navidrome start against an empty directory and flag the whole
    # library as missing.
    systemd.services.navidrome.unitConfig.RequiresMountsFor =
      [ cfg.musicPath ]
      ++ optional (cfg.dataPath != null) cfg.dataPath
      ++ optional (cfg.backupPath != null) cfg.backupPath;

    # Caddy-Tailscale reverse proxy
    services.caddy-tailscale.services = {
      navidrome = { port = cfg.port; };
    };
  };
}
