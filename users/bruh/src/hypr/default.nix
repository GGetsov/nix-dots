{ pkgs, inputs, config, ... }:
{
  wayland.windowManager.hyprland.systemd.enable = false;

  home.packages = with pkgs; [
    hyprlock
    hypridle
    hyprpaper
  ];

  xdg = {
    enable = true;
    configFile = {
      # "hypr".source = ./config/hypr;
      "hypr".source = config.lib.file.mkOutOfStoreSymlink /home/bruh/.config/nix-dots/users/bruh/src/hypr/config;
    };
  };
}
