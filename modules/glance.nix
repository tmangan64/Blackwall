{ config, pkgs, lib, ... }:

{
  services.glance = {
    enable = true;
    openFirewall = true;

    settings = {
      server = {
        host = "127.0.0.1";
        port = 8082;
      };

      theme = {
        background-color = "15 15 15";
        primary-color = "200 170 154";
        contrast-multiplier = 1.1;
      };

      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                { type = "clock"; hour-format = "24h"; }
                { type = "calendar"; }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "monitor";
                  cache = "1m";
                  title = "Services";
                  sites = [
                    { title = "Jellyfin"; url = "https://jellyfin.tail222568.ts.net"; icon = "si:jellyfin"; }
                    { title = "Radarr"; url = "https://radarr.tail222568.ts.net"; icon = "si:radarr"; }
                    { title = "Sonarr"; url = "https://sonarr.tail222568.ts.net"; icon = "si:sonarr"; }
                    { title = "Prowlarr"; url = "https://prowlarr.tail222568.ts.net"; icon = "si:prowlarr"; }
                    { title = "Transmission"; url = "https://transmission.tail222568.ts.net"; icon = "si:transmission"; }
                    { title = "Forgejo"; url = "https://forgejo.tail222568.ts.net"; icon = "si:forgejo"; }
                  ];
                }
                {
                  type = "bookmarks";
                  groups = [
                    {
                      title = "Media";
                      links = [
                        { title = "Jellyfin"; url = "https://jellyfin.tail222568.ts.net"; }
                        { title = "Jellyseerr"; url = "https://jellyseerr.tail222568.ts.net"; }
                      ];
                    }
                    {
                      title = "Downloads";
                      links = [
                        { title = "Radarr"; url = "https://radarr.tail222568.ts.net"; }
                        { title = "Sonarr"; url = "https://sonarr.tail222568.ts.net"; }
                        { title = "Prowlarr"; url = "https://prowlarr.tail222568.ts.net"; }
                        { title = "Transmission"; url = "https://transmission.tail222568.ts.net"; }
                      ];
                    }
                    {
                      title = "Development";
                      links = [
                        { title = "Docs"; url = "https://docs.tail222568.ts.net"; }
                        { title = "Forgejo"; url = "https://forgejo.tail222568.ts.net"; }
                      ];
                    }
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };
}
