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
      default = "10G";
      description = "Maximum memory allocation for the server";
    };

    whitelist = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Whitelist of players (username = UUID)";
      example = { playerName = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"; };
    };

    ops = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Operators (username = UUID), granted permission level 4";
      example = { playerName = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"; };
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
          motd = "NEW - Now with Create + more!";
          difficulty = "normal";
          gamemode = "survival";
          white-list = cfg.whitelist != {};
          # Don't require Mojang-signed chat; avoids "chat validation" errors/kicks
          # for clients on modded multiplayer (singleplayer/LAN never enforces this)
          enforce-secure-profile = false;
          enable-command-block = true;
          spawn-protection = 0;
          view-distance = 12;
          simulation-distance = 10;
        };

        whitelist = cfg.whitelist;

        # Copied (not symlinked) at each server start so it stays writable,
        # but note in-game /op and /deop changes are overwritten on restart
        files."ops.json" = pkgs.writeText "ops.json" (builtins.toJSON (
          mapAttrsToList (name: uuid: {
            inherit name uuid;
            level = 4;
            bypassesPlayerLimit = true;
          }) cfg.ops
        ));

        # Server-side mods for the "Arcadia" modpack (MC 1.21.1, NeoForge 21.1.249),
        # matched exactly (by file hash) to the client pack's jars.
        # Client-only mods (Sodium, Iris, BetterF3, Continuity, Entity Culling,
        # Euphoria Patches, Freecam, Fusion, Just Zoom + Konkrete, LambDynamicLights,
        # McQoy, 3D Skin Layers, Antique Atlas, CreateBetterFps, Distant Horizons)
        # are intentionally excluded.
        #
        # When updating the pack, resolve URLs/hashes from a local jar with:
        #   sha1sum <jar>  ->  https://api.modrinth.com/v2/version_file/<sha1>
        symlinks = {
          # Ancient Structures
          "mods/ancientstructures-neoforge-1.21.1-0.1.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/gZp8ofn3/versions/y6lK8Sua/ancientstructures-neoforge-1.21.1-0.1.1.jar";
            hash = "sha512-rVRGTLlr3DVN2Okt6AEk/p9gdhnQ1APfpTiCgeWp7DCzvzEDeICpHJdJg5uKUMUqbARDowSIySEW8cBt90w/VQ==";
          };

          # AppleSkin
          "mods/appleskin-neoforge-mc1.21-3.0.9.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/EsAfCjCV/versions/uAKA6Laj/appleskin-neoforge-mc1.21-3.0.9.jar";
            hash = "sha512-9OpGJz5AczS2PiYuJVXJqCBPe15g8j8nL7qoOtnoiADg7hhqyoQHEN8tvgoYs3dYaV/vKuGpAsELNwbj3ncpNw==";
          };

          # Architectury API
          "mods/architectury-13.0.11-neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/lhGA9TYQ/versions/1IiqEQGl/architectury-13.0.11-neoforge.jar";
            hash = "sha512-2ffDu4FiV337Rh/98EvWo1Y8dYaTSg4qdEwUQhvv+4KG8NiNTHWDFwA/IPmf6AcqObnWda8GHgNpcNNts2An8A==";
          };

          # Armor of the Ages
          "mods/armoroftheages-neoforge-1.21.1-1.5.10.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/vEgtiJIY/versions/p8G3gWwF/armoroftheages-neoforge-1.21.1-1.5.10.jar";
            hash = "sha512-dhfiPV1g5sHXBVOyIn2t2Pydv2hmK7P2l68MbxaTWCY8XknR0td32UuYWLNFMeNW1uL6wwDUDnh/dVc4o6jzeg==";
          };

          # Biomes O' Plenty
          "mods/BiomesOPlenty-neoforge-1.21.1-21.1.0.14.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/HXF82T3G/versions/BtZKRp69/BiomesOPlenty-neoforge-1.21.1-21.1.0.14.jar";
            hash = "sha512-FWnZ7Vthn5nWGnzxstiGsnjfKQWzzpMk+OehfFyWAxLsaBzAbxrZZkS94s3GBEDYvplS8O4PhPeTchD0b7sh1w==";
          };

          # Bosses'Rise
          "mods/block_factorys_bosses-2.1.2-neo-1.21.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/q2bV1Tm1/versions/lE9PF6Wp/block_factorys_bosses-2.1.2-neo-1.21.1.jar";
            hash = "sha512-mitYvXwVwV8InYe90axbjMyuq2ooUYuaEDNugRM0q6fkLJyudzOl/XEl684oVUsN6lMMt/huy4VhcgPZSFkDRA==";
          };

          # Create: Clipboard Curios
          "mods/clipboardcurios-1.0.0.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/hQ4IDaI2/versions/uBmPvTRI/clipboardcurios-1.0.0.jar";
            hash = "sha512-GmIlGyeV4MsZhQpm+1ntc+t7vSZt+rrcEUz97l5sgvwgkrKwhZdT+2n+lh6LJFhFXyllYRAfQXQ9HypzqeQT/A==";
          };

          # Cloth Config API
          "mods/cloth-config-15.0.140-neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/9s6osm5g/versions/izKINKFg/cloth-config-15.0.140-neoforge.jar";
            hash = "sha512-qvmwEJVbjNKU5akvBpmFsYcp/V4s8i01Hx3/loDxVIhoiAPsQed+lBy94TDOtTUBTKTIaAR9gKtpwtUI4hZlTQ==";
          };

          # Sinytra Connector
          "mods/connector-2.0.0-beta.17+1.21.1-full.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/u58R1TMW/versions/IITF0PRC/connector-2.0.0-beta.17%2B1.21.1-full.jar";
            hash = "sha512-y5K2YgRyCHkuYRkdNy0eJVdmIAQGw1dpAHEB+MV4wQGJOGEMO5A1Kv2T7ELXljrPNgfjXFDmad9QrIXXxVKVYA==";
          };

          # Create: Factory
          "mods/create_factory-0.7b-1.21.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/j6Zt3N7W/versions/OA9Dvj5m/create_factory-0.7b-1.21.1.jar";
            hash = "sha512-Ssw3FEpkTqDdwSkOJBmy64UuOPqkiZL3Aq/CVVFi/Mi6qbecnasvd9pXtbUwARrXN89ji6SBMFOmPEOzpVTUhQ==";
          };

          # Create Mechanical Spawner
          "mods/create_mechanical_spawner-1.21.1-1.3.2-6.0.10.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/T1hmeGi9/versions/k7Fepzl4/create_mechanical_spawner-1.21.1-1.3.2-6.0.10.jar";
            hash = "sha512-1+ybZqlGEli9/Pc5v0bBUceNjb7iyLg5sUKUr10itefMOWSbQ1RAvCAMqHyGOqGIx24X1F0GKBig5VJw0+bzDA==";
          };

          # Create: Structures Arise
          "mods/create_structures_arise-176.49.48 NeoForge 1.21.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/9enMEvoc/versions/ZFrDlvkl/create_structures_arise-176.49.48%20NeoForge%201.21.1.jar";
            hash = "sha512-lf9lqDrj9B/O47sTJ85trPTpFuDqhBqOWEsdGSftrQKJcLD2qAFJccwkRMzvALqmKjOiAh5h1g8s+U34s3fEqA==";
          };

          # Create: Misc and Things
          "mods/create_things_and_misc-4.1.1-neoforge-1.21.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/uWrs8XlB/versions/zfExofVB/create_things_and_misc-4.1.1-neoforge-1.21.1.jar";
            hash = "sha512-PkUw2XQDzY76vTrA3d/CNgs8lLDPwGHtNlRqVtiFfRpNlQlMkghzh8h5BOEX08Bf1BXQ8AYrnj+D3nxmPvuHuA==";
          };

          # Create: Trimmed
          "mods/create_trimmed.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/zvaHXgQz/versions/P1pdTwvn/create_trimmed.jar";
            hash = "sha512-vB4lFZdRIvqIhZVCfKA4GhpPbxF7iNFLTTwmCk5rHPwPgRPAEHTkcvtSo1za+LurRev4m6pM5J/0JWfCWkPAyw==";
          };

          # Create: Ultimate Factory
          "mods/create_ultimate_factory-2.2.4-neoforge-1.21.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/N9QToVpw/versions/AEMRNsNS/create_ultimate_factory-2.2.4-neoforge-1.21.1.jar";
            hash = "sha512-Kh0ebieqB0TRMa0S3MTjvK4tXRDGIMxWbLAwDGOma87RxVvgtjaZjzdz46ezhOdO8GOV7H7mqQZJ93Asmok7DQ==";
          };

          # Create
          "mods/create-1.21.1-6.0.10.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/LNytGWDc/versions/UjX6dr61/create-1.21.1-6.0.10.jar";
            hash = "sha512-EcyPwEnS9n9lSMer+tprgqOttcfKQQp0LeBLvKduA4YsUYchuI2Ab25tdopNaFMf25A6hYWbJdFITVUMx7r9Sw==";
          };

          # Create Crafts & Additions
          "mods/createaddition-1.7.0.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/kU1G12Nn/versions/zlC557Yg/createaddition-1.7.0.jar";
            hash = "sha512-Jnd5vyohWgvjl0jmqOOHMi32l7yd6OfpVY5ohap5Ci5z8zSlW/xfl/QTDSImIBFDNnX9CDCrHj47EMmJjYpwLA==";
          };

          # Create Aeronautics
          "mods/create-aeronautics-bundled-1.21.1-1.3.2.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/oWaK0Q19/versions/44pLdPGg/create-aeronautics-bundled-1.21.1-1.3.2.jar";
            hash = "sha512-3H6OEUj6RCJDiJuilBIgcTfhu4YgbmySvApYnxN0pGbpPeIr2/FPdTmE2GwpMI+73A8UpLlhixTArBZmo2tG9Q==";
          };

          # Create Confectionery
          "mods/create-confectionery1.21.1_v1.1.3b.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/WPE5gRs9/versions/ndnETBEN/create-confectionery1.21.1_v1.1.3b.jar";
            hash = "sha512-7imeCz/BLtxQb3OFpE7vIH/NwwumoNMCSGFO7TSG94xmHZoXbLcV66BErBpCVeOKpSK91LP8F3gEliUQjhFOgg==";
          };

          # Create Contraption Terminals
          "mods/createcontraptionterminals-1.21-1.4.0.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/gOPAFzp0/versions/gBvq8zOa/createcontraptionterminals-1.21-1.4.0.jar";
            hash = "sha512-fuLAbCRCI+b4pJqAzmF/iJg+V+aLs9NPgKkJiSeeSYKq1pFPRIgeB42zlLrkovLOlOCPMbGH6UH8GXj3lRrYJA==";
          };

          # Create: New Age
          "mods/create-new-age-1.2.0+neoforge-mc1.21.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/FTeXqI9v/versions/IwtuwMZy/create-new-age-1.2.0%2Bneoforge-mc1.21.1.jar";
            hash = "sha512-UHXGSCuACvcES1lK1pSFXn1W84bLA1SWfq/pnXfoS04m7n+IDSh2ctJNhOqAhv0HS3aV5GYy8y8hWzHOhZracg==";
          };

          # Create Nuclear
          "mods/createnuclear-1.3.2-beta.3-neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/z611fdf7/versions/waO2BSHO/createnuclear-1.3.2-beta.3-neoforge.jar";
            hash = "sha512-OdlpHY8A83WkOBkxOcMP5gAyzwTNmdg/pCj+/vXI7XnUnY8JtfDlf7SyxAWPxMK62UKgkT3YhfcBpenw2dLzbw==";
          };

          # Create Ore Excavation
          "mods/createoreexcavation-1.21-1.6.8.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/ResbpANg/versions/tivxiPTo/createoreexcavation-1.21-1.6.8.jar";
            hash = "sha512-hErjL/DSL008g9s7ri9u3A90zRpTD5AL8Ygpg41aNUseQ55SaIQWEw2f2aUsMxBFi728dFj0wcHY/7CIroAtMg==";
          };

          # Create Propulsion: Simulated
          "mods/createpropulsion-1.1.5.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/ApkoHNO9/versions/H13U56dc/createpropulsion-1.1.5.jar";
            hash = "sha512-YJbJxcsiAhmgtYtW+f79Y/i3mgln0yZye0IG1i3xgT2nOVauri+luDkWChu1r44JlybRLS2T8Q5fFXvrhbucUg==";
          };

          # Curios API
          "mods/curios-neoforge-9.5.1+1.21.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/vvuO3ImH/versions/yohfFbgD/curios-neoforge-9.5.1%2B1.21.1.jar";
            hash = "sha512-WYGiZ2hrdE5+PCJ/eMvNUmfBSsaXmijoFGlfRYknOZhWMUcgf+9KXNt829w5eXzZXZ5KuttVhp8Y4Co40GVK5Q==";
          };

          # Data Anchor
          "mods/Data_Anchor-neoforge-1.21.1-2.0.0.16.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/z2XEADmE/versions/XORWPtYC/Data_Anchor-neoforge-1.21.1-2.0.0.16.jar";
            hash = "sha512-iSRMyRK0NJ/NSs0wysDX8SznyOeaJrk/Hhp+NaMNUsQyJCa6DqhriMkFsmxuNHxLqEBsktZETgmE+w8h6veWPQ==";
          };

          # Dawn of Time
          "mods/dawnoftimebuilder-neoforge-1.21.1-1.6.6.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/RgWXq0La/versions/fo9df0lp/dawnoftimebuilder-neoforge-1.21.1-1.6.6.jar";
            hash = "sha512-jlFu0kqL6Jgr0N16wbsOunxWdozFJczZhCcBRns6y8auG1qEi4a7ZTT4OvwDjPiWNnR8RttlFtHbB3PezJglLw==";
          };

          # Dungeons and Taverns
          "mods/dungeons-and-taverns-v4.4.4.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/tpehi7ww/versions/BYUUUeZA/dungeons-and-taverns-v4.4.4.jar";
            hash = "sha512-gwadwza8whIFn3U5Izc9lSKqWVO/S0/iqM+mZrTijS0BfapmxLNeMVw76NGtYMKHKHndR8wfR2Zeu/0QLadpdg==";
          };

          # Ecologics
          "mods/ecologics-1.21.1-2.3.7.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/NCKpPR0Z/versions/ihEiqSv4/ecologics-1.21.1-2.3.7.jar";
            hash = "sha512-62Lrfng4JZxklNPuZIVPS9eAKdzDnuxDTx5741IfcyI6ijvZlGI1EkdxMtbFQEVXYjH9d3IWG5RgL3K7owA1mQ==";
          };

          # Farmer's Delight
          "mods/FarmersDelight-1.21.1-1.3.4.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/R2OftAxM/versions/XTVZDOol/FarmersDelight-1.21.1-1.3.4.jar";
            hash = "sha512-H2+HlkafdHz/NvR3tPWJo9aWE4gjmfnuf4bbNse8qapIKHMfQ9sV3Gx/Wkwbvj1AkqIy6M7wELCc7AWBhI/akA==";
          };

          # Forgified Fabric API
          "mods/forgified-fabric-api-0.116.15+2.3.5+1.21.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/Aqlf1Shp/versions/V9WdDUTx/forgified-fabric-api-0.116.15%2B2.3.5%2B1.21.1.jar";
            hash = "sha512-K0Ts2DlUTjZooC+N6GQz1QdBfQaNyv7uf2mHRPwrEv2Iihu6UJ2lfI4ohNAduvNE9Ju6wPIs2uWZUHNW7Qy+MA==";
          };

          # Geckolib
          "mods/geckolib-neoforge-1.21.1-4.8.4.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/8BmcQJ2H/versions/gFmrC8Ru/geckolib-neoforge-1.21.1-4.8.4.jar";
            hash = "sha512-NA2WFJoExXwJSF9bHGnn+Ow7aCI8YY44t9hMWPQoDcuj0OlIC4/HlzXZ71/X2l/I8wgdV1v0u80sRLbc8h2YwA==";
          };

          # GlitchCore
          "mods/GlitchCore-neoforge-1.21.1-2.1.0.2.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/s3dmwKy5/versions/S2TfWrZR/GlitchCore-neoforge-1.21.1-2.1.0.2.jar";
            hash = "sha512-egCe0WPQNTb9+u57N8sewwcyBN/8sGpoM2mqiNqNvDeAsKxp1Ga7MqOtk5TJe2mND9pnbhtN1O38UKxaoig8Mg==";
          };

          # Immersive Aircraft
          "mods/immersive_aircraft-1.4.6+1.21.1-neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/x3HZvrj6/versions/RkWu0N4D/immersive_aircraft-1.4.6%2B1.21.1-neoforge.jar";
            hash = "sha512-ZShmGbdTQ5dVNn0kG7SOd89M6vLFwZoFBSI/GVDKU5NhuOIkJkA3jxFvGVLhRhpgdbOPjOTuS4Qlpghu/8fAoA==";
          };

          # Immersive Machinery
          "mods/immersive_machinery-0.2.0+1.21.1-neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/kGP3J2TW/versions/I0rFojKK/immersive_machinery-0.2.0%2B1.21.1-neoforge.jar";
            hash = "sha512-xWeAIYmt/ABN/Kn/hRnnb+mQm09v6n0O4Hc8LkIyBhbNphNYoh6ZFjSVGmoTnazEPAm3F79GBq1p24I5txbN8Q==";
          };

          # Jade
          "mods/Jade-1.21.1-NeoForge-15.10.6.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/nvQzSEkH/versions/eYz2YBGT/Jade-1.21.1-NeoForge-15.10.6.jar";
            hash = "sha512-2tl1Xc6NhdkU/E3yuqAhHxPlg5pxwZJf3QH2kIGpXjCik05ic/iwHwFprevnqdrleo2QTeDEyzbcFzabtHTw8g==";
          };

          # Just Enough Items (JEI)
          "mods/jei-1.21.1-neoforge-19.51.0.417.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/u6dRKJwZ/versions/w1zqfWJi/jei-1.21.1-neoforge-19.51.0.417.jar";
            hash = "sha512-dOgVXK91fJsyYTFKH6gj7GjlCbm+YBT/pc1bZwbZh9uecnldJcBZQHx2+fZm/rxg/Av/+B3z7TpNblLh7cy94w==";
          };

          # KotlinLangForge
          "mods/KotlinLangForge-2.13.0-k2.4.10-3.0+neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/1vrSzlao/versions/XsDHyDlZ/KotlinLangForge-2.13.0-k2.4.10-3.0%2Bneoforge.jar";
            hash = "sha512-HexgC4ex1qNQu/s8etRRNpKed4UdrGbvxw0hfN4q8hFbgiVg9AQ1XPqg9FRTsyyQRc3PpXtYQN7JqI+TAstCvg==";
          };

          # Lamb Lanterns
          "mods/lamblanterns-1.2.0.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/XzuI5IDa/versions/H8iHSQhM/lamblanterns-1.2.0.jar";
            hash = "sha512-C0ZbMenp//8fO2wyPuIw8xzF29S4nUvRmB5KnqsjTqsEUm06SqKQN7QaKtFONuvqYjsIt874upG/d4iTph1D7w==";
          };

          # [Let's Do] Vinery
          "mods/letsdo-vinery-neoforge-1.5.3.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/1DWmBJVA/versions/ZywXpLC6/letsdo-vinery-neoforge-1.5.3.jar";
            hash = "sha512-GpnSGEIPV3M+wTPwWelJH6Gh7JFeLjUMVKONb921MyphYI/9NwNZT68pJNzI6dOHyiVz84Fsa4IlEEbfDN6hIg==";
          };

          # Mechanicals Lib
          "mods/mechanicals-1.21.1-1.1.6.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/ProvjTA7/versions/GBSlpwLT/mechanicals-1.21.1-1.1.6.jar";
            hash = "sha512-hL/NLL0GHrFRb8KtvKDlmaODcrgO+fVxPecL5I0HIkOxxcuEwTF3w18zO2vPFqofcNvQlk7RjhTCv/czxTHGvA==";
          };

          # MidnightLib
          "mods/midnightlib-neoforge-1.9.3+1.21.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/codAaoxh/versions/6Gv5jvTB/midnightlib-neoforge-1.9.3%2B1.21.1.jar";
            hash = "sha512-WRPn6Ou/+3IyNRSqW+3OGQVohEFtCjOzivF2HudM+mAJls3pvX1wnuIVhHb6ouc1subqYQcpbUcdLFt7NdnabA==";
          };

          # Moonlight Lib
          "mods/moonlight-1.21.1-3.5.2-neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/twkfQtEc/versions/dOMcBcAi/moonlight-1.21.1-3.5.2-neoforge.jar";
            hash = "sha512-YTiY2novODdf7rI4uS9DfwYXqVE8HNIyh4/mOyieQOg/+m0XoLx6Tx8BfIov3/AXx0aRuuhrRo++8vIzzvJO6w==";
          };

          # Nature's Compass
          "mods/NaturesCompass-1.21.1-3.4.0-neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/fPetb5Kh/versions/nFniEtJV/NaturesCompass-1.21.1-3.4.0-neoforge.jar";
            hash = "sha512-UxS1Nry5pZSpzyu9RsgkaNF+FVm9bADanZHpbAgU9QQWeZoBFwXw0YS9cx2sPwPewAnHb+o9ArNVamAT+WSQFA==";
          };

          # Platform
          "mods/Platform-neoforge-1.21.1-1.3.3.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/i6fiqm5y/versions/v7P0nBi2/Platform-neoforge-1.21.1-1.3.3.jar";
            hash = "sha512-GrHc81gyN90ww0Q6H6w+6Cca3SWq6Erykz+p6xPe84QNeozKU1I9HdPFp36yMFkJkoXSGFCdAtABA0/KQvX2TQ==";
          };

          # Potentials
          "mods/potentials-neoforge-1.21-0.7.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/J9pKOkxP/versions/EEjnSxLK/potentials-neoforge-1.21-0.7.1.jar";
            hash = "sha512-/kLkCqH+w5pubQ4kulTJlJeYaNd9pCQftinTdSpyxFtGanmImhXp9vERTJPjnKdIGGIu/CXxCvAEvFQ3HbeTYg==";
          };

          # Pufferfish's Skills
          "mods/puffish_skills-0.19.0-1.21-neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/hqQqvaa4/versions/PFZY8Vfz/puffish_skills-0.19.0-1.21-neoforge.jar";
            hash = "sha512-On0e+sLPBssdNhU1FEhz6KeyI73gC8bCr4dWBJjHAEEcF2ayuFEd6CEYfnJISllAfsntw9TfE+khDp6hsnJTNw==";
          };

          # Redomesticate
          "mods/redomesticate-neoforge-1.21.1-1.10.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/4QTKALKe/versions/YN2LKW05/redomesticate-neoforge-1.21.1-1.10.1.jar";
            hash = "sha512-BTpkVheiGxqtaHlht72e904t2OioxCCVSXzNbPx+JZMTX0nV7vrE82qod27WqCxB7D1/wismPIeJwWqzdnKzsg==";
          };

          # Sable
          "mods/sable-neoforge-1.21.1-2.0.5.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/T9PomCSv/versions/U678xqle/sable-neoforge-1.21.1-2.0.5.jar";
            hash = "sha512-vz2Mh7zF77ma//1QMF/JeAhu1Ipj4QaBbjqKOQH4BS9EgOpSfb19QAP3d17U0CBSkJgDT04weu+snMQt8rTBmg==";
          };

          # ShadowizardLib
          "mods/shadowizardlib-1.3.3.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/DNECjG17/versions/ONdhfFC5/shadowizardlib-1.3.3.jar";
            hash = "sha512-J58j37+BTh8iPTq1hgikeKWUOM5qUGF/fFJB8D3yVVTXeKbb2PFuPA7stwqeGSWXY6dsUtwGHx4r7PUo9JCJ0A==";
          };

          # Skillcloaks
          "mods/skillcloaks-1.2.7.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/SpoXB0Dc/versions/4R7Nxxza/skillcloaks-1.2.7.jar";
            hash = "sha512-H9Ldb4HM2GvRqZ5FCF+uVSgoHr6AiWtibSCzKpJ+VLVn4tB/MJsx0Q1jg9yzC8JXDomrIOyag+6dpLTZqrhCfw==";
          };

          # Spud's shops
          "mods/spudaciousshops-1.10.3-neoforge-1.21.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/sHFbDnFN/versions/e6t9dR2G/spudaciousshops-1.10.3-neoforge-1.21.1.jar";
            hash = "sha512-NZNZ59NUzqQMxAeIsZwcRtylzQvO6pJPFPd0aQx5zMTvNCrMSZ7m3xU6VfSZUcYAjjthI11Zu3yOJGp0qfCfyQ==";
          };

          # Stellaris
          "mods/stellaris-1.21-neoforge-1.4.25.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/ItTQpuBn/versions/5BraaKfR/stellaris-1.21-neoforge-1.4.25.jar";
            hash = "sha512-MgRYJQd/SdKl5j4xl/+Vh4mWwWoMAK3qXRhc9BT1dlxG+S7oKDZ4BeuQ/WgeZhOz8VAFaLJxnqzNb6ysbmmseQ==";
          };

          # Supplementaries
          "mods/supplementaries-1.21.1-3.9.6-neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/fFEIiSDQ/versions/Uds6VJIs/supplementaries-1.21.1-3.9.6-neoforge.jar";
            hash = "sha512-qRoXR2lJNqsZTXwxhlz3PqVfN8OJZiLsTKKRc+V8DdecVz4RotURde3tkTdzu5lfFgCu8FozuiL85EMaOQdleQ==";
          };

          # Surveyor Map Framework
          "mods/surveyor-1.1.2+1.21.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/4KjqhPc9/versions/iLOZqG06/surveyor-1.1.2%2B1.21.jar";
            hash = "sha512-1FLVkpED9+8/2rdvMQdvBIrKYdiRHm/qDGD2TjUo9mlBHwPPqLcVeLIIxWmXPXZvE8cZ1KuAZjtV5+khTEekog==";
          };

          # TerraBlender
          "mods/TerraBlender-neoforge-1.21.1-4.1.0.8.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/kkmrDlKT/versions/6e8GCrLb/TerraBlender-neoforge-1.21.1-4.1.0.8.jar";
            hash = "sha512-nUsqG+UTnA+y+tku0hgFsX2eg7bqSOY34Bi7FAY8GCOiBjkHVdv+jQJcIP1irBHN2E21PduVbauu2gG/9XusUA==";
          };

          # Tom's Simple Storage Mod
          "mods/toms_storage-1.21-2.4.2.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/XZNI4Cpy/versions/WQAMoIMC/toms_storage-1.21-2.4.2.jar";
            hash = "sha512-U9thtEhmFrOnjf/4O1j5Qk3Zv1Jeo9tORE/wQD+3Cqmrf8CX3/L0lmXkgLzpNrMr52swUaWv8heJiyuU2EbTCw==";
          };

          # Vanilla Backport
          "mods/VanillaBackport-neoforge-1.21.1-1.1.7.10.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/6xwxDTgf/versions/rUSWdBok/VanillaBackport-neoforge-1.21.1-1.1.7.10.jar";
            hash = "sha512-vgYir9L30hbk2DrtkZDexvb2opGc/86+jzNJibkfFIY476Gz4dS7iqbIP/pfd1lR1rO8dcDUW3C1s4m080drTw==";
          };

          # VeinMiner
          "mods/veinminer-neoforge-2.11.2+1.21.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/OhduvhIc/versions/syKekkIm/veinminer-neoforge-2.11.2%2B1.21.1.jar";
            hash = "sha512-GV/f6fE1joUhjncMlTIjgl0QL1S19geFe4iTlZzSFkoEySGYdhGnkzWSuomoOqK9jzzsCx/PfYeiCxaPiLLMBQ==";
          };

          # Via Romana: Infrastructure-Driven Fast Travel
          "mods/via_romana-2.2.3+1.21.1-neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/FVToiKwr/versions/I7nIGnGB/via_romana-2.2.3%2B1.21.1-neoforge.jar";
            hash = "sha512-KpsoZh3u3d+vLSI/yzlLDfa/WNTMjbbtEOAOsFHoFtDJLGXFRi77QYavYuSYqYNvmPf42T1EP36XEciBUcjnqQ==";
          };

          # YetAnotherConfigLib (YACL)
          "mods/yet_another_config_lib_v3-3.8.2+1.21.1-neoforge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/1eAoo2KR/versions/7TVdVtxF/yet_another_config_lib_v3-3.8.2%2B1.21.1-neoforge.jar";
            hash = "sha512-WD3hm5J86AUMK31eYLdazMaeMl5arIXCeZTIKp3sLk4Hg0P6HUw6ENS9fg5STgs7JGoYzwPbAeNjoeb4Za3PSA==";
          };
        };
      };
    };

    # Open firewall port for Minecraft
    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];
  };
}

