{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.blackwall.storage;
in
{
  options.blackwall.storage = {
    enable = mkEnableOption "media storage configuration";

    basePath = mkOption {
      type = types.path;
      default = "/media";
      description = "Base path for all media storage";
    };

    user = mkOption {
      type = types.str;
      default = "media";
      description = "User that owns media directories";
    };

    group = mkOption {
      type = types.str;
      default = "media";
      description = "Group that owns media directories";
    };
  };

  config = mkIf cfg.enable {
    # Order the media disk before systemd-tmpfiles-setup.
    #
    # The mount is `nofail`, and per systemd.mount(5) that does not only make
    # it optional - it also drops the mount's ordering before local-fs.target.
    # systemd-tmpfiles-setup is therefore free to run first, create every
    # directory below on the root disk, and have the real filesystem mounted
    # over the top of them a moment later. Services then write into a shadowed
    # directory that looks correct and disappears on the next boot, which is
    # the failure mode Nextcloud hit on its first deploy.
    #
    # `x-systemd.before=` is ordering only, so the disk stays genuinely
    # optional: if it cannot be mounted, tmpfiles still runs and the boot still
    # completes. Services that must not run without it (see the
    # RequiresMountsFor in nextcloud.nix and vaultwarden.nix) are what refuse.
    #
    # This assumes basePath is a mount point declared in hardware.nix.
    fileSystems.${cfg.basePath}.options = [ "x-systemd.before=systemd-tmpfiles-setup.service" ];

    # Create shared media group for all services to access files
    users.groups.${cfg.group} = { };

    # Create media user (services will be added to media group)
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      description = "Media storage user";
    };

    # Create directory structure with systemd tmpfiles
    systemd.tmpfiles.rules = [
      # Base directories
      "d ${cfg.basePath}/downloads 2775 ${cfg.user} ${cfg.group} -"
      "d ${cfg.basePath}/downloads/incomplete 2775 ${cfg.user} ${cfg.group} -"
      "d ${cfg.basePath}/downloads/complete 2775 ${cfg.user} ${cfg.group} -"
      "d ${cfg.basePath}/downloads/torrents 2775 ${cfg.user} ${cfg.group} -"
      "d ${cfg.basePath}/downloads/usenet 2775 ${cfg.user} ${cfg.group} -"

      # Library directories (organized media)
      "d ${cfg.basePath}/library 2775 ${cfg.user} ${cfg.group} -"
      "d ${cfg.basePath}/library/movies 2775 ${cfg.user} ${cfg.group} -"
      "d ${cfg.basePath}/library/tv 2775 ${cfg.user} ${cfg.group} -"
      "d ${cfg.basePath}/library/music 2775 ${cfg.user} ${cfg.group} -"
      "d ${cfg.basePath}/library/books 2775 ${cfg.user} ${cfg.group} -"
      "d ${cfg.basePath}/library/audiobooks 2775 ${cfg.user} ${cfg.group} -"

      # Archives and other content sources
      "d ${cfg.basePath}/archives 2775 ${cfg.user} ${cfg.group} -"
      "d ${cfg.basePath}/soulseek 2775 ${cfg.user} ${cfg.group} -"

      # Service database backups (kept off the root SSD)
      "d ${cfg.basePath}/backups 2775 ${cfg.user} ${cfg.group} -"
    ];
  };
}
