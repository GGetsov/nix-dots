{ config, pkgs, machine, ... }:

let
  update-user = pkgs.writeShellScriptBin "update-user" ''
    pushd ~/nix-dots/users/bruh/ > /dev/null 2>&1
    git add .
    home-manager switch --flake ./${machine}/#bruh
    git reset
    popd > /dev/null 2>&1
  '';

  update-system = pkgs.writeShellScriptBin "update-system" ''
    pushd ~/nix-dots/system/ > /dev/null 2>&1
    git add -f hardware-configuration.nix
    sudo nixos-rebuild switch --flake ./#laptop
    git reset hardware-configuration.nix
    popd > /dev/null 2>&1
  '';
in
{
  home.packages = with pkgs; [
    update-system
    update-user
  ];
} 
