{ config, pkgs, inputs, ... }:

{
  # Allow unfree packages (required for NeoForge)
  nixpkgs.config.allowUnfree = true;
  imports =
    [
      ./hardware.nix
      # Core
      ../../modules/core/storage.nix
      # Networking
      ../../modules/networking/tailscale.nix
      ../../modules/networking/caddy-tailscale.nix
      # Services
      ../../modules/service/glance.nix
      ../../modules/service/arr.nix
      ../../modules/service/vikunja.nix
      # Development
      ../../modules/development/forgejo.nix
      ../../modules/development/code-server.nix
      ../../modules/development/mdbook.nix
      # Gaming
      ../../modules/gaming/minecraft.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "blackwall";

  # Networking
  networking.networkmanager.enable = true;

  # Static IP for SSH port forwarding
  networking.interfaces.enp3s0 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "192.168.1.66";
      prefixLength = 24;
    }];
  };
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Timezone
  time.timeZone = "Europe/Jersey";

  # Locale
  i18n.defaultLocale = "en_GB.UTF-8";

  # Keymap
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };
  console.keyMap = "uk";

  # Media storage for Arr* suite, Nicotine+, etc.
  blackwall.storage.enable = true;

  # Arr* media management suite
  blackwall.arr.enable = true;

  # Forgejo Git forge
  blackwall.forgejo.enable = true;

  # code-server (VS Code in browser, sandboxed to Forgejo repos)
  blackwall.code-server.enable = true;

  # mdbook documentation server
  blackwall.mdbook.enable = true;

  # Vikunja project management
  blackwall.vikunja.enable = true;

  # Modded Minecraft 1.21.1 server (disabled until mods are configured)
  blackwall.minecraft = {
    enable = true;
    memory = "8G";
    maxPlayers = 20;
    # Add whitelisted players here:
    # whitelist = {
    #   "PlayerName" = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
    # };
    # Add operators here:
    # ops = {
    #   "PlayerName" = 4;
    # };
  };

  # User account
  users.users.mizutani = {
    isNormalUser = true;
    description = "Teague Mangan";
    extraGroups = [ "networkmanager" "wheel" "media" ];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPHEr9l0xPvco+x1zz2X5skaIwpjtI0+QGOELm/KtV5d kiroshi"
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    tmux
  ];

  # SSH
  services.openssh = {
    enable = true;
    ports = [ 6622 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Firewall
  networking.firewall.allowedTCPPorts = [ 6622 ];

  # Fail2ban
  services.fail2ban.enable = true;

  # Caddy-Tailscale reverse proxy
  # Each service gets its own custom URL: https://<name>.your-tailnet.ts.net
  services.caddy-tailscale = {
    enable = true;
    # authKeyFile = "/run/secrets/tailscale-caddy-authkey";
    services = {
      glance = { port = 8082; };
    };
  };

  system.stateVersion = "25.11";
}
