# Installation Nodes from NixOS Live Image

`nix-shell -p git`

`git clone https://github.com/kannadev/nixos.git`

`cd nixos`

`nano hosts/willow-hazel/configuration.nix` - Modify the drive that is found on here, can be found with `lsblk`

`sudo nix run 'github:nix-community/disko' --experimental-features "nix-command flakes" -- --flake .#willow-hazel --mode disko`

`sudo mkdir /mnt/persist/etc`

`cd ..`

`sudo cp nixos /mnt/persist/etc -r`

`cd /mnt/persist/etc/nixos`

`sudo nixos-install --flake .#willow-hazel --no-channel-copy`