# Laptop profile - laptop-specific settings
{ config, pkgs, ... }:

{
  # Power management
  services.thermald.enable = true;

  # VirtualBox for testing
  virtualisation.virtualbox.host.enable = true;
  users.users.mizutani.extraGroups = [ "vboxusers" ];

  # Disable services that cause issues on laptops
  services.geoclue2.enable = false;
}
