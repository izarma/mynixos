#base:
#    sudo nixos-rebuild switch -I nixos-config=/home/izarma/mynixos/base-configuration.nix

flake:
    sudo nixos-rebuild switch --flake .#izasus
