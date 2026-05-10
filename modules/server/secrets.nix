# SOPS secrets management
{ config, ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      "admin/password_hash" = {
        neededForUsers = true;
      };
      "nextcloud/admin_password" = {
        owner = "nextcloud";
        group = "nextcloud";
      };
    };
  };
}
