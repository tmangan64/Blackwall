# Server-specific user configuration (immutable, SSH-key only)
{ config, pkgs, lib, ... }:

{
  users.mutableUsers = false;

  users.users.mizutani = {
    isNormalUser = true;
    description = "Server administrator";
    extraGroups = [ "wheel" ];
    shell = pkgs.bash;
    hashedPasswordFile = config.sops.secrets."admin/password_hash".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPHEr9l0xPvco+x1zz2X5skaIwpjtI0+QGOELm/KtV5d kiroshi"
    ];
  };

  users.users.root.hashedPassword = "!";
  security.sudo.wheelNeedsPassword = false;
}
