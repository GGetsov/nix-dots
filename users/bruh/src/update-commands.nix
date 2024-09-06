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
    pushd ~/.config/nix-dots/ > /dev/null 2>&1
    cp ./flake.lock locks/shell.lock
    cp system/flake.lock locks/system.lock
    cp users/bruh/laptop/flake.lock locks/bruh.lock
    nix flake update
    popd > /dev/null 2>&1
    pushd ~/.config/nix-dots/system/ > /dev/null 2>&1
    nix flake update
    pushd ~/.config/nix-dots/users/bruh/${machine}/ > /dev/null 2>&1
    nix flake update
    popd > /dev/null 2>&1
  '';
  
  cleanup = pkgs.writeShellScriptBin "cleanup" ''
    ${pkgs.nh}/bin/nh clean all -k 5
  '';

  edit-config = pkgs.writeShellScriptBin "edit-config" ''
    cd ~/.config/nix-dots/
    nix develop -c $SHELL
  '';

in
{
  home.packages = with pkgs; [
    update-system
    update-user
    update-flake
    cleanup

    edit-config
  ];
} 
