{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.blackwall.minecraft;
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.blackwall.minecraft = {
    enable = mkEnableOption "Modded Minecraft 1.21.1 server";

    serverName = mkOption {
      type = types.str;
      default = "blackwall";
      description = "Name of the Minecraft server";
    };

    port = mkOption {
      type = types.port;
      default = 25565;
      description = "Port for the Minecraft server";
    };

    maxPlayers = mkOption {
      type = types.int;
      default = 10;
      description = "Maximum number of players";
    };

    memory = mkOption {
      type = types.str;
      default = "4G";
      description = "Maximum memory allocation for the server";
    };

    whitelist = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Whitelist of players (username = UUID)";
      example = { playerName = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"; };
    };

    ops = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of operator usernames";
      example = [ "playerName" ];
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

    services.minecraft-servers = {
      enable = true;
      eula = true;
      dataDir = "/var/lib/minecraft";

      servers.${cfg.serverName} = {
        enable = true;
        package = pkgs.neoforgeServers.neoforge-1_21_1;

        jvmOpts = "-Xms${cfg.memory} -Xmx${cfg.memory}";

        serverProperties = {
          server-port = cfg.port;
          max-players = cfg.maxPlayers;
          motd = "Now ISO 27000 compliant!";
          difficulty = "normal";
          gamemode = "survival";
          white-list = cfg.whitelist != {};
          enable-command-block = true;
          spawn-protection = 0;
          view-distance = 12;
          simulation-distance = 10;
        };

        whitelist = cfg.whitelist;

        # Mods from README.md for 1.21.1 (NeoForge)
        #
        # To get the correct sha256 hash, run:
        #   nix-prefetch-url <URL>
        # Then convert to SRI format:
        #   nix hash to-sri --type sha256 <HASH>
        #
        # Or use lib.fakeSha256 temporarily to get the correct hash from error message
        symlinks = {
          # Quark - Vanilla+ content and tweaks
          # https://modrinth.com/mod/quark
          "mods/Quark.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/qg1rwffq/versions/Lrz8TIWX/Quark-1.21.1-4.0-463.jar";
            sha256 = lib.fakeSha256;
          };

          # Zeta - Library required by Quark
          # https://modrinth.com/mod/zeta
          "mods/Zeta.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/2EKYwlDp/versions/IG2Q9xOD/Zeta-1.21.1-1.0-24.jar";
            sha256 = lib.fakeSha256;
          };

          # Universal Shops - Economy and player shops
          # https://modrinth.com/mod/universal-shops
          # Note: Find the 1.21.1 NeoForge version URL and uncomment
          # "mods/UniversalShops.jar" = pkgs.fetchurl {
          #   url = "URL_HERE";
          #   sha256 = lib.fakeSha256;
          # };

          # Bosses Rise - Additional boss mobs
          # Note: Find the 1.21.1 NeoForge version URL and uncomment
          # "mods/BossesRise.jar" = pkgs.fetchurl {
          #   url = "URL_HERE";
          #   sha256 = lib.fakeSha256;
          # };
        };

        # Datapacks - Matcha Flavoured
        # Download the datapack and place in:
        #   /var/lib/minecraft/${cfg.serverName}/world/datapacks/
        # Or add via symlinks:
        # symlinks."world/datapacks/matcha-flavoured.zip" = pkgs.fetchurl {
        #   url = "DATAPACK_URL";
        #   sha256 = lib.fakeSha256;
        # };
      };
    };

    # Open firewall port for Minecraft
    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];
  };
}
