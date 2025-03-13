{ config, pkgs, lib, ... }:
let
  test = (final: prev: {
    colloid-gtk-theme = prev.colloid-gtk-theme.overrideAttrs (attrs: {
      preInstall = (attrs.preInstall or "") + ''
      rm ./src/sass/_color-palette-catppuccin.scss
      cp ${./cat_test} ./src/sass/_color-palette-catppuccin.scss
      '';
    });
  });
  
  coloid-updated = pkgs.colloid-gtk-theme.override {
    themeVariants = [ "grey"];
    colorVariants = [ "dark" ];
    sizeVariants = [ "standard" ];
    tweaks = [ "catppuccin" "rimless" "black" ];
  };

   gnome-shell-theme = (final: prev: {
      gnome-shell = prev.gnome-shell.overrideAttrs (attrs: {
        postInstall = (attrs.postInstall or "") + ''
        glib-compile-resources ${./gnome-shell-theme.gresource.xml} --sourcedir=${coloid-updated}/share/themes/Colloid-Grey-Dark-Catppuccin/gnome-shell --target=$out/share/gnome-shell/gnome-shell-theme.gresource
        '';
      });
    # });
  }); 
in
{
  # Configure keymap in X11
  services = {
    # somehow fixes suspend issues maybe
    logind.lidSwitch = "ignore";

    #automount external
    udisks2.enable = true;

    xserver = {
      enable = true;
      xkb = {
        options = "eurosign:e,caps:escape";
        layout = "us";
      };

      # GDM
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
      };
    };
  };


  fonts = {
    fontDir.enable = true;
    packages = with pkgs.nerd-fonts; [
      (jetbrains-mono)
    ];
  };

  environment.systemPackages = with pkgs; [
    # Fix clipboard under X11 and Wayland
    xclip
    wl-clipboard

    #cursor-theme for gmd
    catppuccin-cursors.macchiatoDark
  ];

  programs.dconf = {
    enable = true;

    # Setting GDM cursor theme size and font via dconf
    # All GDM and GNOME dconf settings can be found at
    # https://gitlab.gnome.org/GNOME/gsettings-desktop-schemas/blob/b0b0ebf551d0284e285cad9f95c8640dd3f5612e/schemas/org.gnome.desktop.interface.gschema.xml.in#L122
    # Examples for dconf profiles:
    # https://github.com/NixOS/nixpkgs/issues/54150
    # https://github.com/NixOS/nixpkgs/pull/234615

    profiles.gdm.databases = with lib.gvariant; [
      {
        settings = {
          "org/gnome/desktop/interface" = {
            cursor-theme = "catppuccin-macchiato-dark-cursors";
            cursor-size = mkInt32 32;
            show-battery-percentage = true;
          };
        };
      }
    ];
  };
  
  # GDM overlay that applies the custom gnome-shell theme
  # nixpkgs = let 
  #   sources = (import ./nix/sources.nix);
  #   gnome-shell-theme = (import sources.nixpuccin-macchiato).gnome-shell-theme;
  # in 
  #   { overlays = [ gnome-shell-theme ]; };

  nixpkgs.overlays = [ test gnome-shell-theme];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
}
