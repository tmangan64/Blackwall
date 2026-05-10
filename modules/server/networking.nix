# Static networking for server
{ config, lib, pkgs, ... }:

{
  networking = {
    domain = "local";
    networkmanager.enable = false;
    useDHCP = false;

    interfaces.enp3s0 = {
      ipv4.addresses = [{
        address = "192.168.0.55";
        prefixLength = 24;
      }];
    };

    defaultGateway = "192.168.0.1";
    nameservers = [ "127.0.0.1" "1.1.1.1" "9.9.9.9" ];

    hosts = {
      "127.0.0.1" = [ "dns.home" "cloud.home" ];
    };

    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 33 53 443 3000 ];
      allowedUDPPorts = [ 53 ];
      logRefusedConnections = true;
    };
  };

  services.resolved.enable = false;
}
