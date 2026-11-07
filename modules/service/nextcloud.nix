{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.blackwall.nextcloud;
  storageCfg = config.blackwall.storage;

  # Same rule as vaultwarden.nix: the caddy-tailscale node name is the first
  # label of the domain, so the tailnet hostname and the hostName Nextcloud
  # believes it is served on cannot drift apart. That matters more here than
  # elsewhere - see the WebAuthn note below, the hostname is the credential
  # scope for FIDO2 keys, not just a cosmetic URL.
  nodeName = head (splitString "." cfg.domain);

  # Apps are pinned to the server major version: nextcloud32Packages tracks
  # nextcloud32. Bumping `package` means bumping this attribute too, otherwise
  # the apps advertise a max-version the server has outgrown and Nextcloud
  # disables them on upgrade.
  ncPackages = pkgs.nextcloud32Packages;
in
{
  # Nextcloud - Files (the core app) plus News (a feed reader), both served
  # from one instance at https://<domain>.
  #
  # "Files" is not an app that gets installed: it ships with the server and is
  # what Nextcloud *is*. "News" is an appstore app, pinned here as a package so
  # it is part of the system closure rather than something clicked into place
  # in the web UI. News covers the "RSS Feed" line in the README to-do list; it
  # polls feeds from nextcloud-cron.service (every 5 minutes, enabled by the
  # upstream module) so no separate updater daemon is needed.
  #
  # Storage split, following navidrome.nix and vaultwarden.nix:
  #
  #   home    -> /var/lib/nextcloud          (apps, store-apps, root SSD)
  #   datadir -> storage.basePath/nextcloud  (config.php + user files, media disk)
  #   database -> local PostgreSQL           (/var/lib/postgresql, root SSD)
  #
  # User files are content, not appdata, and they are the one part of this
  # service that grows without bound, so they live on the media disk. Note that
  # datadir holds config.php as well as data/ - that is upstream's layout, not a
  # choice this module makes - so the media disk ends up holding the DB password
  # and the instance secret, in a 0750 nextcloud:nextcloud directory.
  #
  # Reached only over the tailnet, through caddy-tailscale. nginx is bound to
  # loopback and nothing is opened in the firewall.
  #
  # == Accounts ==
  #
  # One admin account is created declaratively (adminUser / adminPasswordFile),
  # and it is the account for both apps: News is per-user state inside the same
  # instance, so there is no second account to make. The password is only read
  # during the initial nextcloud-setup run; changing the secret afterwards does
  # nothing, and `nextcloud-occ user:resetpassword <user>` is the way to rotate
  # it on a live instance.
  #
  # == FIDO2 ==
  #
  # The plan is to log in with a hardware key, so this instance is set up to
  # make that a UI step rather than a reconfiguration:
  #
  #   * WebAuthn needs a secure context and a stable origin. Caddy terminates
  #     TLS with a real Tailscale cert, and overwriteprotocol = "https" below
  #     stops Nextcloud generating http:// URLs behind the proxy - without it
  #     registration fails in the browser for reasons that look like a TLS bug.
  #   * A WebAuthn credential is bound to the hostname that registered it. Keys
  #     enrolled against this domain stop working if `domain` changes later, so
  #     it is worth settling on the name before enrolling anything.
  #   * Core Nextcloud already supports passwordless WebAuthn login (Settings ->
  #     Security -> "Add WebAuthn device"), which needs no app. The
  #     twofactor_webauthn app installed below is the other half: the key as a
  #     second factor on top of the password.
  #   * 2FA enforcement is deliberately left off. Turning it on before a key is
  #     enrolled locks the admin account out of the web UI; the recovery path is
  #     `nextcloud-occ twofactorauth:disable <user>` over SSH.
  options.blackwall.nextcloud = {
    enable = mkEnableOption "Nextcloud (Files + News)";

    domain = mkOption {
      type = types.str;
      default = "cloud.tail222568.ts.net";
      description = ''
        Tailnet hostname Nextcloud is served on. Its first label doubles as the
        caddy-tailscale node name, so changing this renames the tailnet node.

        This is also the WebAuthn relying-party ID, so hardware keys enrolled
        against the old name are void after a change - re-enroll them.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8085;
      description = ''
        Loopback port nginx serves Nextcloud on, behind caddy-tailscale.

        The upstream module always configures an nginx vhost; this module binds
        it to 127.0.0.1 only, so port 80 stays unused and nothing answers on
        the LAN.
      '';
    };

    adminUser = mkOption {
      type = types.str;
      default = "mizutani";
      description = ''
        Username of the admin account created on first start.

        Nextcloud uses the username as the account's internal ID, so it cannot
        be renamed later - only the display name can.
      '';
    };

    adminPasswordFile = mkOption {
      type = types.path;
      example = literalExpression ''config.sops.secrets.nextcloud_admin_password.path'';
      description = ''
        Path to a file containing *only* the admin password, consumed by
        nextcloud-setup.service during the initial install.

        Stored with sops rather than written into this repo, following
        modules/core/secrets.nix:

          1. sops secrets/secrets.yaml, add
               nextcloud_admin_password: <password>
          2. in secrets.nix:
               secrets.nextcloud_admin_password.owner = "nextcloud";
          3. here:
               adminPasswordFile = config.sops.secrets.nextcloud_admin_password.path;

        Unlike the vaultwarden admin token this is a bare value, not a KEY=value
        line: Nextcloud reads the whole file as the password, trailing newline
        included, so do not add one.

        Keep the secret after the hardware key is in use. It is the fallback
        when a key is lost, and the only alternative is resetting the password
        over SSH with nextcloud-occ.
      '';
    };

    dataPath = mkOption {
      type = types.nullOr types.path;
      default = "${storageCfg.basePath}/nextcloud";
      defaultText = literalExpression ''"''${config.blackwall.storage.basePath}/nextcloud"'';
      description = ''
        Directory holding user files and config.php, kept off the root SSD.

        Set to null to keep everything in /var/lib/nextcloud instead. Either
        way this is fixed at install time: moving it afterwards means moving the
        directory by hand and correcting `datadirectory` in config.php, so
        decide before the first deploy.
      '';
    };

    maxUploadSize = mkOption {
      type = types.str;
      default = "4G";
      description = ''
        Largest single file that can be uploaded. Sets php's
        upload_max_filesize/post_max_size and nginx's client_max_body_size.
        Caddy imposes no body limit of its own, so this is the only ceiling.
      '';
    };
  };

  config = mkIf cfg.enable {
    # The default dataPath lives under the media filesystem that storage.nix
    # owns; pointing dataPath elsewhere (or at null) lifts the requirement.
    assertions = [{
      assertion = cfg.dataPath != null -> storageCfg.enable;
      message = "blackwall.nextcloud requires blackwall.storage to be enabled, or blackwall.nextcloud.dataPath set to null";
    }];

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud32;

      hostName = cfg.domain;

      # Generate https:// links. Also turns on HSTS on the nginx vhost, which
      # is harmless here - the only thing in front of it is Caddy, which is
      # already https-only.
      https = true;

      # Apps on the SSD, content and config on the media disk. datadir defaults
      # to home, so the null case needs no branch.
      datadir = mkIf (cfg.dataPath != null) cfg.dataPath;

      inherit (cfg) maxUploadSize;

      # PostgreSQL over a unix socket, provisioned by the upstream module
      # (peer-authenticated, so there is no DB password to manage). SQLite is
      # accepted by Nextcloud but not by its own documentation, and News is the
      # exact workload it falls over on: dozens of feed updates every five
      # minutes against a single-writer database produces "database is locked"
      # rather than slowness. Worth knowing that a nixpkgs PostgreSQL major
      # bump is a manual pg_upgrade, not a rebuild.
      database.createLocally = true;

      config = {
        dbtype = "pgsql";
        adminuser = cfg.adminUser;
        adminpassFile = toString cfg.adminPasswordFile;
      };

      # Declared as packages rather than installed from the web UI, so the set
      # of apps is part of the closure and survives a rebuild from scratch.
      # Nextcloud 32 ships Files, Photos, Activity and the rest of the core set
      # already; only the extras belong here.
      #
      # Populating extraApps turns the appstore off (see appstoreEnable), which
      # is the intent: apps come from this list. To install something from the
      # UI instead, either add it here or set
      #   services.nextcloud.appstoreEnable = true;
      extraApps = {
        inherit (ncPackages.apps) news twofactor_webauthn;
      };
      extraAppsEnable = true;

      # Upstream ties memory_limit to maxUploadSize, which would hand every
      # php-fpm worker a 4G ceiling. Uploads are chunked, so the limit does not
      # need to cover a whole file.
      phpOptions.memory_limit = mkForce "512M";

      settings = {
        # Behind caddy-tailscale: trust the proxy for X-Forwarded-*, and force
        # https in generated URLs. Nextcloud only honours X-Forwarded-Proto
        # from a trusted proxy, and a WebAuthn registration served over a
        # mixed-origin page fails outright, so both are load-bearing.
        trusted_proxies = [ "127.0.0.1" "::1" ];
        overwriteprotocol = "https";

        # Only reachable by name through Caddy. hostName is trusted implicitly.
        trusted_domains = [ ];

        default_phone_region = "GB";

        # Nothing is configured to send mail, so password resets and share
        # notifications stay inside the instance rather than failing in the
        # background. Revisit alongside the 'contact for security issues' mail
        # setup in the README.
        mail_smtpmode = "null";

        # Thumbnails for the file types a home instance actually holds.
        # Upstream's default list omits HEIC/HEIF (phone photos) and PDFs.
        enabledPreviewProviders = [
          "OC\\Preview\\PNG"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\GIF"
          "OC\\Preview\\BMP"
          "OC\\Preview\\WebP"
          "OC\\Preview\\HEIC"
          "OC\\Preview\\TIFF"
          "OC\\Preview\\PDF"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\TXT"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\Movie"
        ];
      };
    };

    # The vhost upstream creates listens on :80 on every interface by default,
    # which would put Nextcloud on the LAN. Replacing `listen` pins it to
    # loopback, where Caddy reaches it and nothing else does.
    services.nginx.virtualHosts.${cfg.domain}.listen = [{
      addr = "127.0.0.1";
      port = cfg.port;
    }];

    # Preview generation for video, and the HEIC/TIFF/PDF providers above, are
    # shelled out to ffmpeg and ImageMagick rather than done in PHP.
    environment.systemPackages = with pkgs; [ ffmpeg ];

    # Wait for the media filesystem. /media is mounted `nofail`, so without
    # this a boot with the disk missing would leave Nextcloud serving an empty
    # data directory against a database full of files - every file "missing",
    # and new uploads landing in a shadow directory on the root SSD that the
    # mount later hides. Refusing to start is the better failure.
    systemd.services = mkIf (cfg.dataPath != null) (
      genAttrs [ "nextcloud-setup" "nextcloud-cron" "nextcloud-update-plugins" "phpfpm-nextcloud" ]
        (_: { unitConfig.RequiresMountsFor = [ cfg.dataPath ]; })
    );

    # Caddy-Tailscale reverse proxy
    services.caddy-tailscale.services = {
      ${nodeName} = { port = cfg.port; };
    };
  };
}
