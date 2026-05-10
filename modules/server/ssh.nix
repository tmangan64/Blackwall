# SSH hardening for server
{ config, pkgs, lib, ... }:

{
  services.openssh = {
    enable = true;
    ports = [ 33 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
    };
    openFirewall = true;
  };

  # Fail2ban for SSH brute-force resistance
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h";
    };
  };
}
