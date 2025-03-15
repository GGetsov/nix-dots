{ pkgs, inputs, config, ... }:
{
  # add the home manager module
  imports = [ inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;

    # null or path, leave as null if you don't want hm to manage the config
    configDir = config.lib.file.mkOutOfStoreSymlink "/home/bruh/.config/nix-dots/users/bruh/src/ags/config/";

    # additional packages to add to gjs's runtime
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk
      accountsservice

      astal.battery
    ];
  };
}
