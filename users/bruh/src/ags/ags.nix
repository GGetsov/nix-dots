{ lib, config, pkgs, inputs, ... }:
{  
  programs.ags = {
    enable = true;

    # null or path, leave as null if you don't want hm to manage the config
    # configDir = ./config/ags/;
    configDir = config.lib.file.mkOutOfStoreSymlink /home/bruh/.config/nix-dots/users/bruh/src/config/ags;

    # additional packages to add to gjs's runtime
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk
      accountsservice
    ];
  };
}
