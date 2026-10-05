{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.blackwall.vaultwarden;
  storageCfg = config.blackwall.storage;

  # The caddy-tailscale node name is the first label of the domain, so the
  # tailnet hostname and the DOMAIN vaultwarden advertises cannot drift apart:
  # "vault.tail222568.ts.net" -> node "vault" -> https://vault.tail222568.ts.net.
  # Clients pin absolute URLs (icons, attachments, the 2FA issuer) from DOMAIN,
  # so a mismatch between it and the address the browser used breaks the web
  # vault in ways that look like a TLS or CORS fault rather than a typo.
  nodeName = head (splitString "." cfg.domain);
in
{
  # Vaultwarden - Bitwarden-compatible password vault.
  #
  # Storage is split the same way as navidrome.nix:
  #
  #   state   -> /var/lib/vaultwarden                 (SQLite DB, keys, root SSD)
  #   backups -> blackwall.storage.basePath/backups   (nightly dump, media disk)
  #
  # The vault is a few megabytes and latency-sensitive, so it stays on the SSD;
  # only the nightly backup lands on the media disk, where a dead system disk
  # cannot take it along. That backup is the only copy of rsa_key.pem - the key
  # that signs session tokens - and of the attachments, both of which the
  # exported-vault JSON does *not* contain, so it is worth having even though
  # every client also holds a full local copy of the vault itself.
  #
  # Reached only over the tailnet, through caddy-tailscale, bound to loopback.
  # Nothing is opened in the firewall; the vault is never exposed to the LAN,
  # let alone the internet. Websocket notifications (the live-sync push clients
  # use) are served on the same port in vaultwarden 1.30+, and Caddy forwards
  # upgrade requests transparently, so the proxy needs no extra configuration.
  options.blackwall.vaultwarden = {
    enable = mkEnableOption "Vaultwarden password vault";

    domain = mkOption {
      type = types.str;
      default = "vault.tail222568.ts.net";
      description = ''
        Tailnet hostname the vault is served on. Its first label doubles as the
        caddy-tailscale node name, so changing this renames the tailnet node.

        Changing it after clients have been set up means every client has to be
        re-pointed at the new URL, and TOTP entries keyed to the old host keep
        working but show the old issuer.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8222;
      description = "Local port Vaultwarden listens on, behind caddy-tailscale.";
    };

    allowSignups = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether anyone reaching the vault can create an account.

        Left open so the first account can be created without the admin panel -
        registration is the only other way in on a fresh database. Once your own
        account exists, set this to false: the tailnet is a small blast radius
        but not an empty one, and from then on new users are invited from the
        admin panel instead (see adminTokenFile).
      '';
    };

    adminTokenFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = literalExpression ''config.sops.secrets.vaultwarden_admin_token.path'';
      description = ''
        Path to a systemd EnvironmentFile holding the admin panel credential:

          ADMIN_TOKEN=$argon2id$v=19$...

        null (the default) leaves /admin disabled entirely, which is the right
        setting until it is needed - the panel can read and delete every account
        on the server and is protected by this one string.

        Generate the value with `vaultwarden hash` and store it with sops rather
        than writing it into this repo, following the pattern in
        modules/core/secrets.nix:

          1. sops secrets/secrets.yaml, add
               vaultwarden_admin_token: ADMIN_TOKEN=$argon2id$v=19$...
          2. in secrets.nix:
               secrets.vaultwarden_admin_token.restartUnits = [ "vaultwarden.service" ];
          3. here:
               adminTokenFile = config.sops.secrets.vaultwarden_admin_token.path;

        The whole KEY=value line is stored as the secret, so the secret file is
        already a valid EnvironmentFile and no sops template is needed. Note
        that `$` is literal in an EnvironmentFile, so an Argon2 hash needs no
        escaping, but it does need the value quoted when editing YAML.
      '';
    };

    backupPath = mkOption {
      type = types.nullOr types.path;
      default = "${storageCfg.basePath}/backups/vaultwarden";
      defaultText = literalExpression ''"''${config.blackwall.storage.basePath}/backups/vaultwarden"'';
      description = ''
        Directory for the nightly backup (23:00): a consistent sqlite dump of
        the vault plus a copy of the keys, config and attachments. Kept off the
        root SSD, like the navidrome backups.

        This is a mirror, not a history - each run overwrites the last - so it
        protects against a dead disk, not against a bad change noticed a week
        later. Set to null to disable backups.
      '';
    };
  };

  config = mkIf cfg.enable {
    # The default backupPath lives under the media filesystem that storage.nix
    # owns; pointing backupPath elsewhere lifts the requirement.
    assertions = [{
      assertion = cfg.backupPath != null -> storageCfg.enable;
      message = "blackwall.vaultwarden requires blackwall.storage to be enabled, or blackwall.vaultwarden.backupPath set to null";
    }];

    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";

      # Upstream prefixes https:// itself, so this is the bare hostname.
      domain = cfg.domain;

      backupDir = cfg.backupPath;

      # config is an attrsOf, so defining it replaces upstream's default
      # { ROCKET_ADDRESS = "::1"; ROCKET_PORT = 8222; } wholesale rather than
      # merging with it - both have to be restated here or vaultwarden binds
      # 0.0.0.0:80 and the vault is on the LAN.
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = cfg.port;

        SIGNUPS_ALLOWED = cfg.allowSignups;

        # Let existing users invite others by email address. With no SMTP
        # server configured the invitation is not actually mailed; the admin
        # panel lists it so the link can be passed along by hand. Harmless
        # with signups open, and the useful path once they are closed.
        INVITATIONS_ALLOWED = true;

        # Left at upstream's defaults: entry icons are fetched by this server,
        # direct from the sites the entries point at. That means those hosts
        # see a request from this IP for each domain in the vault - the one
        # outbound trace the vault leaves. Add
        #   DISABLE_ICON_DOWNLOAD = true;
        # to stop it; entries then show a letter tile instead. (Vaultwarden
        # already refuses to fetch icons from non-global addresses, so an entry
        # pointing at a LAN host cannot be used to probe the network.)
      };

      # ADMIN_TOKEN is passed as an environment file rather than through
      # config, which is rendered into a world-readable store path.
      environmentFile = optional (cfg.adminTokenFile != null) cfg.adminTokenFile;
    };

    # Wait for the media filesystem. Without this a missing mount turns the
    # backup directory into a plain directory on the root SSD and the nightly
    # dump silently lands next to the data it is meant to survive.
    systemd.services.backup-vaultwarden = mkIf (cfg.backupPath != null) {
      unitConfig.RequiresMountsFor = [ cfg.backupPath ];
    };

    # Caddy-Tailscale reverse proxy
    services.caddy-tailscale.services = {
      ${nodeName} = { port = cfg.port; };
    };
  };
}
