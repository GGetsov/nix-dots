{ config, pkgs, machine, ... }:

let
  update-user = pkgs.writeShellScriptBin "update-user" ''
    pushd ~/.config/nix-dots/users/bruh/ > /dev/null 2>&1
    git add .
    home-manager switch --flake ./${machine}/#bruh
    git reset > /dev/null 2>&1
    popd > /dev/null 2>&1
  '';

  update-system = pkgs.writeShellScriptBin "update-system" ''
    pushd ~/.config/nix-dots/system/ > /dev/null 2>&1
    git add -f hardware-configuration.nix
    sudo nixos-rebuild switch --flake ./#laptop
    git reset hardware-configuration.nix > /dev/null 2>&1
    popd > /dev/null 2>&1
  '';

  edit-config = pkgs.writeShellScriptBin "edit-config" ''
    cd ~/.config/nix-dots/
    nix-shell -I nixpkgs=/nix/var/nix/profiles/per-user/bruh/channels/nixpkgs/
  '';

in
{
  home.packages = with pkgs; [
    update-system
    update-user

    edit-config
  ];
} 
