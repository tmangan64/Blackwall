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
        background-color = "0 0 6";
        primary-color = "30 30 70";
        contrast-multiplier = 1.1;
      };

      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                { type = "clock"; hour-format = "24h"; timezones = [{ timezone = "Europe/London"; label = "Jersey"; }]; }
                { type = "calendar"; }
                { type = "weather"; location = "Jersey, Channel Islands"; units = "metric"; }
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
                    { title = "Jellyfin"; url = "https://jellyfin.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/jellyfin.svg"; }
                    { title = "Radarr"; url = "https://radarr.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/radarr.svg"; }
                    { title = "Sonarr"; url = "https://sonarr.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/sonarr.svg"; }
                    { title = "Prowlarr"; url = "https://prowlarr.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/prowlarr.svg"; }
                    { title = "Transmission"; url = "https://transmission.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/transmission.svg"; }
                    { title = "Jellyseerr"; url = "https://jellyseerr.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/jellyseerr.svg"; }
                    { title = "Forgejo"; url = "https://forgejo.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/forgejo.svg"; }
                    { title = "Docs"; url = "https://docs.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/mdbook.svg"; }
                  ];
                }
              ];
            }
          ];
        }
        {
          name = "Media";
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "bookmarks";
                  groups = [
                    {
                      title = "Watch";
                      links = [
                        { title = "Jellyfin"; url = "https://jellyfin.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/jellyfin.svg"; }
                        { title = "Jellyseerr"; url = "https://jellyseerr.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/jellyseerr.svg"; }
                      ];
                    }
                    {
                      title = "Manage";
                      links = [
                        { title = "Radarr"; url = "https://radarr.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/radarr.svg"; }
                        { title = "Sonarr"; url = "https://sonarr.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/sonarr.svg"; }
                        { title = "Prowlarr"; url = "https://prowlarr.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/prowlarr.svg"; }
                      ];
                    }
                    {
                      title = "Download";
                      links = [
                        { title = "Transmission"; url = "https://transmission.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/transmission.svg"; }
                      ];
                    }
                  ];
                }
              ];
            }
          ];
        }
        {
          name = "Development";
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "bookmarks";
                  groups = [
                    {
                      title = "Code";
                      links = [
                        { title = "Forgejo"; url = "https://forgejo.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/forgejo.svg"; }
                        { title = "Code Server"; url = "https://code.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/code-server.svg"; }
                      ];
                    }
                    {
                      title = "Documentation";
                      links = [
                        { title = "Docs"; url = "https://docs.tail222568.ts.net"; icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/mdbook.svg"; }
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
