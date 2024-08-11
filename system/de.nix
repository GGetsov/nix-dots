{ config, pkgs, lib, ... }:

{
  # Configure keymap in X11
  services = {
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
      
      excludePackages = [ pkgs.xterm ];
      
      desktopManager = {
        gnome.enable = true;
        xterm.enable = false;
      };
    };

    displayManager = {
      defaultSession = "default";
    };
  };

  environment.gnome.excludePackages = lib.attrValues {
    inherit (pkgs) 
      gnome-console
      epiphany #browser
      gnome-text-editor
      gnome-photos
      gnome-tour
      gnome-connections #something like team-viewer
      xdg-desktop-portal-gnome
      geary #email client
      simple-scan #document scanner
      totem #video player
      yelp #help viewer
    ;
    inherit (pkgs.gnome)
      gnome-music
      gnome-maps
      gnome-contacts
    ;
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
    (nerdfonts.override { fonts = ["JetBrainsMono"]; })
    ];
  };

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
            font-name = "JetBrainsMono Nerd Font 14";
            show-battery-percentage = true;
          };
        };
      }
    ];
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    # Fix clipboard under X11 and Wayland
    xclip
    wl-clipboard

    catppuccin-cursors.macchiatoDark

    gnome-tweaks
    
    hyprland
    # use this overlay if ENV vars don't work with GDM
    # (hyprland.overrideAttrs (prevAttrs: rec {
    #   postInstall =
    #     let
    #       hyprlandSession = ''
    #         [Desktop Entry]
    #         Name=Hyprland
    #         Comment=Dynamic Wayland compositor
    #         Exec= bash -l -c Hyprland
    #         Type=Application
    #       '';
    #     in
    #     ''
    #       mkdir -p $out/share/wayland-sessions
    #       echo "${hyprlandSession}" > $out/share/wayland-sessions/hyprland.desktop
    #     '';
    #   passthru.providedSessions = [ "hyprland" ];
    # }))
  ];
  
  # GDM overlay that applies the custom gnome-shell theme
  nixpkgs = let 
    sources = (import ./nix/sources.nix);
    gnome-shell-theme = (import sources.nixpuccin-macchiato).gnome-shell-theme;
  in 
    { overlays = [ gnome-shell-theme ]; };

  programs.hyprland = {
    enable = true;
    # enableNvidiaPatches = true;
    xwayland.enable = true;
  };

  services.displayManager = {
    sessionPackages = [
      (pkgs.stdenv.mkDerivation {
        name = "default-session";
        src = ./. ;
      
        installPhase = let
          launch-last-used-session = import ./default-session.nix { inherit pkgs; };
        
          # While at it create custom session that launches last used DE
          defaultSession = ''
            [Desktop Entry]
            Name=Default
            Comment=Last session
            Exec=${launch-last-used-session}/bin/launch-last-used-session
            Type=Application
          '';
        in
        ''
          mkdir -p $out/share/wayland-sessions
          echo "${defaultSession}" > $out/share/wayland-sessions/default.desktop
        '';
        passthru.providedSessions = [ "default" ];
      })
    ];
  };
}
