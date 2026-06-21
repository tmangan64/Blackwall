{ config, pkgs, lib, ... }:

{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;

    settings = {
      title = "Blackwall";
      description = "Built with intention";
      theme = "dark";
      color = "stone";
      headerStyle = "clean";
      layout = {
        Services = {
          style = "row";
          columns = 3;
        };
        Infrastructure = {
          style = "row";
          columns = 3;
        };
      };
    };

    widgets = [
      {
        greeting = {
          text_size = "xl";
          text = "Blackwall";
        };
      }
      {
        datetime = {
          text_size = "xl";
          format = {
            dateStyle = "long";
            timeStyle = "short";
            hour12 = false;
          };
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
    ];

    services = [
      {
        Services = [
          # Add services here as you deploy them
          # {
          #   Nextcloud = {
          #     icon = "nextcloud";
          #     href = "https://cloud.example.com";
          #     description = "File storage";
          #   };
          # }
        ];
      }
      {
        Infrastructure = [
          # {
          #   "This Server" = {
          #     icon = "mdi-server";
          #     href = "#";
          #     description = "Blackwall homelab";
          #   };
          # }
        ];
      }
    ];

    customCSS = ''
      /* Blackwall Theme - matching blackwall.cam */
      @import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:ital,wght@0,400;0,500;1,400&family=IBM+Plex+Sans:wght@300;400;500&display=swap');

      :root {
        --color-bg: #0f0f0f;
        --color-fg: #d4d0c8;
        --color-fg-dim: #7a776e;
        --color-fg-faint: #2e2c28;
        --color-accent: #c8b89a;
        --color-accent-dim: #6e5f4a;
        --color-link: #a8c4b8;
        --color-link-hover: #d4ede3;
        --color-border: #2a2826;
        --color-border-light: #3a3830;
      }

      body {
        font-family: 'IBM Plex Sans', sans-serif !important;
        background-color: var(--color-bg) !important;
        color: var(--color-fg) !important;
      }

      /* Main container */
      #page_container, .bg-theme-100\/20 {
        background-color: var(--color-bg) !important;
      }

      /* Widget styling */
      .widget, .widget-container, div[class*="widget"] {
        font-family: 'IBM Plex Mono', monospace !important;
      }

      /* Greeting text */
      .text-xl, .text-2xl, .text-3xl, .text-4xl {
        font-family: 'IBM Plex Mono', monospace !important;
        color: var(--color-fg) !important;
      }

      /* Service cards */
      .service, .service-card, div[class*="service"] {
        background-color: var(--color-fg-faint) !important;
        border: 1px solid var(--color-border) !important;
        border-radius: 4px !important;
      }

      .service:hover, .service-card:hover {
        border-color: var(--color-border-light) !important;
        background-color: var(--color-border) !important;
      }

      /* Service titles */
      .service-title, h2, h3 {
        font-family: 'IBM Plex Mono', monospace !important;
        color: var(--color-accent) !important;
        font-weight: 500 !important;
      }

      /* Service descriptions */
      .service-description, .text-xs {
        color: var(--color-fg-dim) !important;
      }

      /* Links */
      a {
        color: var(--color-link) !important;
        text-decoration: none !important;
      }

      a:hover {
        color: var(--color-link-hover) !important;
      }

      /* Search bar */
      input[type="text"], .search-input {
        background-color: var(--color-fg-faint) !important;
        border: 1px solid var(--color-border) !important;
        color: var(--color-fg) !important;
        font-family: 'IBM Plex Mono', monospace !important;
        border-radius: 4px !important;
      }

      input[type="text"]:focus, .search-input:focus {
        border-color: var(--color-accent-dim) !important;
        outline: none !important;
      }

      /* Tab styling */
      .tab, .tab-item {
        background-color: transparent !important;
        color: var(--color-fg-dim) !important;
        border-bottom: 2px solid transparent !important;
      }

      .tab:hover, .tab-item:hover, .tab.active, .tab-item.active {
        color: var(--color-accent) !important;
        border-bottom-color: var(--color-accent) !important;
      }

      /* Category headers */
      .category-header, .group-header {
        font-family: 'IBM Plex Mono', monospace !important;
        color: var(--color-accent) !important;
        text-transform: lowercase !important;
        font-size: 0.875rem !important;
        letter-spacing: 0.05em !important;
      }

      /* Scrollbar styling */
      ::-webkit-scrollbar {
        width: 8px;
        height: 8px;
      }

      ::-webkit-scrollbar-track {
        background: var(--color-bg);
      }

      ::-webkit-scrollbar-thumb {
        background: var(--color-border-light);
        border-radius: 4px;
      }

      ::-webkit-scrollbar-thumb:hover {
        background: var(--color-fg-dim);
      }

      /* Remove any default shadows */
      * {
        box-shadow: none !important;
      }
    '';
  };

  # Open port 8082 (homepage default)
  networking.firewall.allowedTCPPorts = [ 8082 ];

  # Allow access from local network
  systemd.services.homepage-dashboard.environment.HOMEPAGE_ALLOWED_HOSTS = lib.mkForce "blackwall:8082,localhost:8082,127.0.0.1:8082,192.168.1.66:8082";
}
