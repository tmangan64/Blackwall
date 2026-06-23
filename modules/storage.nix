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
    ];
  };
}
