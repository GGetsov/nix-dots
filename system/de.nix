{ config, pkgs, lib, ... }:

{
  # Configure keymap in X11
  services.xserver = {
    enable = true;
    xkbOptions = "eurosign:e,caps:escape";
    layout = "us";
    excludePackages = [ pkgs.xterm ];
     
    displayManager = {
      defaultSession = "default";
      gdm = {
        enable = true;
        wayland = true;
      };
    };

    desktopManager = {
      gnome.enable = true;
      xterm.enable = false;
    };
  };
}
