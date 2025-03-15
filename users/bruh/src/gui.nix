{ lib, config, pkgs, inputs, ... }:
let 
  test = (final: prev: {
    colloid-gtk-theme = prev.colloid-gtk-theme.overrideAttrs (attrs: {
      preInstall = (attrs.preInstall or "") + ''
      rm ./src/sass/_color-palette-catppuccin.scss
      cp ${./cat_test} ./src/sass/_color-palette-catppuccin.scss
      '';
    });
  });
in
{
  imports = [
    ./hypr/.
    ./ags/.
    ./firefox/.
  ];

  xsession.enable = true;

  nixpkgs.overlays = [ test ];
  
  gtk = {
    enable = true;
    theme = {
      name = "Colloid-Grey-Dark-Catppuccin";
      package = pkgs.colloid-gtk-theme.override {
        themeVariants = [ "grey"];
        colorVariants = [ "dark" ];
        sizeVariants = [ "standard" ];
        tweaks = [ "catppuccin" "rimless" "black" ];
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name =  "gtk2";
  };
  home = {
    pointerCursor ={
      name = "catppuccin-macchiato-dark-cursors";
      package = pkgs.catppuccin-cursors.macchiatoDark;
      size = 32;
      gtk.enable = true;
      x11.enable = true;
    };
    packages = with pkgs; [
      kitty
      qbittorrent
      vlc
      rofi-wayland
      hyprpaper
      keepassxc
      libreoffice
      obsidian
      nautilus
    ];
  };
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:";
      };
    };
  };

  xdg = {
    # also declared in home.nix
    enable = true;
    mimeApps = {
      enable = true;
    };
  };
}
