{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware.nix
      ../../modules/homepage.nix
      ../../modules/tailscale.nix
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

  # User account
  users.users.mizutani = {
    isNormalUser = true;
    description = "Teague Mangan";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # System packages
  environment.systemPackages = with pkgs; [
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

  system.stateVersion = "25.11";
}
