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
  };
  stylix = {
    enable = true;
    autoEnable = false;
    image = ./wallpaper.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    targets = {
      firefox.enable = true;
      # gnome.enable = true;
      # gtk = {
      #   enable = true;
      #   flatpakSupport.enable = true;
      # };
      kde.enable = true;
      qt = {
        enable = true;
      };
    };
    cursor =  {
      name = "catppuccin-macchiato-dark-cursors";
      package = pkgs.catppuccin-cursors.macchiatoDark;
      size = 32;
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:";
      };
    };
  };

  home.packages = with pkgs; [
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

  xdg = {
    # also declared in home.nix
    enable = true;
    mimeApps = {
      enable = true;
    };
  };
}
