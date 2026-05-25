# profiles/base.nix

Base profile shared by all hosts.

## Imports

- modules/nix-settings.nix
- modules/locale.nix

## Configuration

### Networking

- Hostname from specialArgs
- NetworkManager enabled

### User

- Username: mizutani
- Groups: networkmanager, wheel
- Shell: fish

### Programs

- fish

### Packages

- git
