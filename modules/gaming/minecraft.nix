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
        # Pinned to match the client modpack (Minecraft 1.21.1, NeoForge 21.1.249)
        package = pkgs.neoforgeServers.neoforge-1_21_1-21_1_249;

        jvmOpts = "-Xms${cfg.memory} -Xmx${cfg.memory}";

        # Clients connect via mc.blackwall.cam (point an A/AAAA record at this host)
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

        # Server-side mods, matched exactly (by file hash) to the client
        # modpack's jars. Client-only mods (Sodium, Iris, LambDynamicLights)
        # are intentionally excluded.
        #
        # When updating the pack, resolve URLs/hashes from a local jar with:
        #   sha1sum <jar>  ->  https://api.modrinth.com/v2/version_file/<sha1>
        symlinks = {
          # AppleSkin - hunger/saturation sync
          "mods/appleskin-neoforge-mc1.21-3.0.9.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/EsAfCjCV/versions/uAKA6Laj/appleskin-neoforge-mc1.21-3.0.9.jar";
            hash = "sha512-9OpGJz5AczS2PiYuJVXJqCBPe15g8j8nL7qoOtnoiADg7hhqyoQHEN8tvgoYs3dYaV/vKuGpAsELNwbj3ncpNw==";
          };

          # Bosses'Rise (Block Factory's Bosses)
          "mods/block_factorys_bosses-2.1.2-neo-1.21.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/q2bV1Tm1/versions/lE9PF6Wp/block_factorys_bosses-2.1.2-neo-1.21.1.jar";
            hash = "sha512-mitYvXwVwV8InYe90axbjMyuq2ooUYuaEDNugRM0q6fkLJyudzOl/XEl684oVUsN6lMMt/huy4VhcgPZSFkDRA==";
          };

          # Carry On
          "mods/carryon-neoforge-1.21.1-2.2.6.13.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/joEfVgkn/versions/PV8oLZ1q/carryon-neoforge-1.21.1-2.2.6.13.jar";
            hash = "sha512-4JexHW8U4JV7q2wCdrgVQueGy4a5wx2fJZdfjJ+wSnNBiLh5BoMpi7xcaV3D3n1ulHYWogrSbUpyijvrC7eGZw==";
          };

          # Curios API
          "mods/curios-neoforge-9.5.1+1.21.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/vvuO3ImH/versions/yohfFbgD/curios-neoforge-9.5.1%2B1.21.1.jar";
            hash = "sha512-WYGiZ2hrdE5+PCJ/eMvNUmfBSsaXmijoFGlfRYknOZhWMUcgf+9KXNt829w5eXzZXZ5KuttVhp8Y4Co40GVK5Q==";
          };

          # Data Anchor - library
          "mods/Data_Anchor-neoforge-1.21.1-2.0.0.16.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/z2XEADmE/versions/XORWPtYC/Data_Anchor-neoforge-1.21.1-2.0.0.16.jar";
            hash = "sha512-iSRMyRK0NJ/NSs0wysDX8SznyOeaJrk/Hhp+NaMNUsQyJCa6DqhriMkFsmxuNHxLqEBsktZETgmE+w8h6veWPQ==";
          };

          # Enchantments Encore
          "mods/enchantments-encore-1.8.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/GD1QoExk/versions/G0Ilv4nD/enchantments-encore-1.8.jar";
            hash = "sha512-FUpW6kReLZYVnLH5sY1Q5CN71M7QT/75abjI84ergvOXsLb4BPpCv7mjsrqRI9bB0L+ms4yRafjzxsatFDU/Og==";
          };

          # GeckoLib - animation library
          "mods/geckolib-neoforge-1.21.1-4.8.4.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/8BmcQJ2H/versions/gFmrC8Ru/geckolib-neoforge-1.21.1-4.8.4.jar";
            hash = "sha512-NA2WFJoExXwJSF9bHGnn+Ow7aCI8YY44t9hMWPQoDcuj0OlIC4/HlzXZ71/X2l/I8wgdV1v0u80sRLbc8h2YwA==";
          };

          # Just Enough Items (JEI)
          "mods/jei-1.21.1-neoforge-19.50.0.414.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/u6dRKJwZ/versions/zKog3N6a/jei-1.21.1-neoforge-19.50.0.414.jar";
            hash = "sha512-p1UkzJhubx9aq9DjIdtFrro5aaoiH9T7REsqRa7WLkxOveIRARBKPZgVrCF1N0jocH93oxk3/20sIr/2AQEH4g==";
          };

          # Lamb Lanterns
          "mods/lamblanterns-1.2.0.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/XzuI5IDa/versions/H8iHSQhM/lamblanterns-1.2.0.jar";
            hash = "sha512-C0ZbMenp//8fO2wyPuIw8xzF29S4nUvRmB5KnqsjTqsEUm06SqKQN7QaKtFONuvqYjsIt874upG/d4iTph1D7w==";
          };

          # Map Atlases
          "mods/map_atlases-1.21-6.7.2-neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/4hwXMFif/versions/PnETlK1o/map_atlases-1.21-6.7.2-neoforge.jar";
            hash = "sha512-m0B56ksU94Zw8hB4BiWR6sc4J6YrPFJnfyykhJq14b34bxs/Fpb2JSYiPeafHIKT1DD5cEHMXDNJtuMbPyIzSQ==";
          };

          # MidnightLib - library
          "mods/midnightlib-neoforge-1.9.3+1.21.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/codAaoxh/versions/6Gv5jvTB/midnightlib-neoforge-1.9.3%2B1.21.1.jar";
            hash = "sha512-WRPn6Ou/+3IyNRSqW+3OGQVohEFtCjOzivF2HudM+mAJls3pvX1wnuIVhHb6ouc1subqYQcpbUcdLFt7NdnabA==";
          };

          # Moonlight Lib - library for Supplementaries/Map Atlases
          "mods/moonlight-1.21.1-3.5.2-neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/twkfQtEc/versions/dOMcBcAi/moonlight-1.21.1-3.5.2-neoforge.jar";
            hash = "sha512-YTiY2novODdf7rI4uS9DfwYXqVE8HNIyh4/mOyieQOg/+m0XoLx6Tx8BfIov3/AXx0aRuuhrRo++8vIzzvJO6w==";
          };

          # Quark - vanilla+ content and tweaks
          "mods/Quark-4.1-482.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/qnQsVE2z/versions/yvp3Jbmk/Quark-4.1-482.jar";
            hash = "sha512-gR4enyY6fklRiWpkZQfW0Dvr72w4wRNCXl0lrNTaCvmgem5fnxE5PLQctvGpdmfXdIxL8hv4Quh8orBdbqnNgQ==";
          };

          # Redomesticate
          "mods/redomesticate-neoforge-1.21.1-1.10.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/4QTKALKe/versions/YN2LKW05/redomesticate-neoforge-1.21.1-1.10.1.jar";
            hash = "sha512-BTpkVheiGxqtaHlht72e904t2OioxCCVSXzNbPx+JZMTX0nV7vrE82qod27WqCxB7D1/wismPIeJwWqzdnKzsg==";
          };

          # Spud's Shops - economy and player shops
          "mods/spudaciousshops-1.10.3-neoforge-1.21.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/sHFbDnFN/versions/e6t9dR2G/spudaciousshops-1.10.3-neoforge-1.21.1.jar";
            hash = "sha512-NZNZ59NUzqQMxAeIsZwcRtylzQvO6pJPFPd0aQx5zMTvNCrMSZ7m3xU6VfSZUcYAjjthI11Zu3yOJGp0qfCfyQ==";
          };

          # Supplementaries
          "mods/supplementaries-1.21.1-3.9.6-neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/fFEIiSDQ/versions/Uds6VJIs/supplementaries-1.21.1-3.9.6-neoforge.jar";
            hash = "sha512-qRoXR2lJNqsZTXwxhlz3PqVfN8OJZiLsTKKRc+V8DdecVz4RotURde3tkTdzu5lfFgCu8FozuiL85EMaOQdleQ==";
          };

          # TrimsEffects
          "mods/trimeffects-neoforge-mc1.21-2.1.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/BL7ADJ7w/versions/bEjVixg6/trimeffects-neoforge-mc1.21-2.1.1.jar";
            hash = "sha512-g8/dvuCCKIvwCOcdrsooRtHYBtFhAeAilHYJb6QQXYRJPdiFA2sPrq7kmwj8sOTu7PBI2st/5RotUD6tuOcHvA==";
          };

          # Via Romana - infrastructure-driven fast travel
          "mods/via_romana-2.2.3+1.21.1-neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/FVToiKwr/versions/I7nIGnGB/via_romana-2.2.3%2B1.21.1-neoforge.jar";
            hash = "sha512-KpsoZh3u3d+vLSI/yzlLDfa/WNTMjbbtEOAOsFHoFtDJLGXFRi77QYavYuSYqYNvmPf42T1EP36XEciBUcjnqQ==";
          };

          # Zeta - library required by Quark
          "mods/Zeta-1.1-40.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/MVARlG2f/versions/9GjNW2Gf/Zeta-1.1-40.jar";
            hash = "sha512-qB3PRPK/0PwaUvANnKR6hK0rrwZ63ts17shZ9rnOx7YcpDLlSaM0KxCQL4TnbXAiTNVEAChcixOgkmg1pixmfA==";
          };
        };
      };
    };

    # Open firewall port for Minecraft
    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];
  };
}
