{ config, pkgs, machine, ... }:

let
  update-user = pkgs.writeShellScriptBin "update-user" ''
    pushd ~/.config/nix-dots/ > /dev/null 2>&1
    git add .
    popd > /dev/null 2>&1
    pushd ~/.config/nix-dots/users/bruh/${machine}/ > /dev/null 2>&1
    git add .
    home-manager switch --flake ./#bruh
    git reset > /dev/null 2>&1
    popd > /dev/null 2>&1
  '';

  update-system = pkgs.writeShellScriptBin "update-system" ''
    pushd ~/.config/nix-dots/system/ > /dev/null 2>&1
    git add -f hardware-configuration.nix
    sudo nixos-rebuild switch --flake ./#${machine}
    git reset hardware-configuration.nix > /dev/null 2>&1
    popd > /dev/null 2>&1
  '';

  update-flake = pkgs.writeShellScriptBin "update-flake" ''
    pushd ~/.config/nix-dots/system/ > /dev/null 2>&1
    nix flake update
    popd > /dev/null 2>&1
    pushd ~/.config/nix-dots/users/bruh/${machine}/ > /dev/null 2>&1
    nix flake update
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
    update-flake

    edit-config
  ];
} 
