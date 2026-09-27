{ config, lib, inputs, ... }:

{
  # sops-nix: encrypted secrets committed to this repo, decrypted at activation.
  #
  # The system decrypts using its own SSH host key (see sops.age.sshKeyPaths
  # below), so no key material has to be placed on the machine by hand. Editing
  # is done with the admin age key in ~/.config/sops/age/keys.txt:
  #
  #   sops secrets/secrets.yaml
  #
  # Recipients live in .sops.yaml at the repo root. Both the admin key and the
  # host key are recipients: drop the host key and activation can no longer
  # decrypt; drop the admin key and secrets can only be edited as root.
  #
  # Adding a secret:
  #   1. sops secrets/secrets.yaml           (add the key/value)
  #   2. declare it in sops.secrets below
  #   3. reference its .path from the consuming service
  #   4. git add secrets/secrets.yaml && ./build.sh
  #
  # Note that secrets/secrets.yaml must be tracked by git - flakes only copy
  # tracked files into the store, so an untracked secrets file fails the build
  # with a confusing "file not found" during activation.
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;

    # Decrypt with the host's SSH key rather than a separate age key, so there
    # is no bootstrap secret to provision on a rebuilt machine - the host key is
    # already there. Losing this key (reinstall without preserving /etc/ssh)
    # means re-encrypting to the new host key with `sops updatekeys`.
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      # Tailscale credential used by caddy-tailscale to register its nodes.
      # Currently a reusable auth key; will be replaced by an OAuth client
      # secret, which tsnet accepts in the same TS_AUTHKEY slot and which does
      # not expire.
      caddy_ts_authkey.restartUnits = [ "caddy-tailscale.service" ];

      # playit.gg tunnel agent credential.
      playit_secret_key.restartUnits = [ "playit.service" ];
    };

    # Both consumers want the secret wrapped in a file format rather than bare,
    # so render templates instead of pointing them at the raw secret files.
    # Default ownership (root, 0400) is correct for both: systemd reads
    # EnvironmentFile and LoadCredential as root before dropping privileges.
    templates = {
      "caddy-tailscale.env" = {
        content = "TS_AUTHKEY=${config.sops.placeholder.caddy_ts_authkey}";
        restartUnits = [ "caddy-tailscale.service" ];
      };

      "playit-secret.toml" = {
        content = ''
          secret_key = "${config.sops.placeholder.playit_secret_key}"
        '';
        restartUnits = [ "playit.service" ];
      };
    };
  };
}
