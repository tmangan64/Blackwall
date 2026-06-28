{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.blackwall.code-server;
  forgejoRepoPath = "/var/lib/forgejo/repositories";
  forgejoStateDir = "/var/lib/forgejo";
in
{
  options.blackwall.code-server = {
    enable = mkEnableOption "code-server (VS Code in browser)";
  };

  config = mkIf cfg.enable {
    # code-server (runs as forgejo user)
    services.code-server = {
      enable = true;
      user = "forgejo";
      group = "forgejo";
      host = "127.0.0.1";
      port = 8443;
      auth = "none";  # Tailscale handles auth
      disableTelemetry = true;
      disableUpdateCheck = true;
      userDataDir = "${forgejoStateDir}/code-server/user-data";
      extensionsDir = "${forgejoStateDir}/code-server/extensions";
      extraPackages = with pkgs; [ git ];
      extraArguments = [ "--disable-workspace-trust" ];
    };

    # Systemd sandboxing - restrict code-server to Forgejo repos only
    systemd.services.code-server.serviceConfig = {
      TemporaryFileSystem = "/:ro";
      BindPaths = [
        forgejoRepoPath
        "${forgejoStateDir}/code-server"
      ];
      BindReadOnlyPaths = [
        "/nix/store"
        "-/etc/resolv.conf"
        "-/etc/ssl"
        "-/etc/static"
        "-/run/current-system/sw"
      ];
      PrivateTmp = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
    };

    # Directory setup
    systemd.tmpfiles.rules = [
      "d ${forgejoStateDir}/code-server 0750 forgejo forgejo -"
      "d ${forgejoStateDir}/code-server/user-data 0750 forgejo forgejo -"
      "d ${forgejoStateDir}/code-server/extensions 0750 forgejo forgejo -"
    ];

    # Caddy-Tailscale reverse proxy
    services.caddy-tailscale.services = {
      code = { port = 8443; };
    };
  };
}
