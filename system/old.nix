{ pkgs , lib, ... }:
{
  services = {
    xserver = {
      excludePackages = [ pkgs.xterm ];
      
      desktopManager = {
        gnome.enable = true;
        xterm.enable = false;
      };
    };

    displayManager = {
      # add new session, named default, that opens to the last picked session (gnome or hyprland)
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
    # then pick that session as the new default one
    defaultSession = "default";
  };
  
  # exclude gnome default packages
  environment.gnome.excludePackages = lib.attrValues {
    inherit (pkgs) 
      gnome-console
      epiphany #browser
      gnome-connections #something like team-viewer
      gnome-contacts
      gnome-maps
      gnome-music
      gnome-text-editor
      gnome-photos
      gnome-tour
      xdg-desktop-portal-gnome
      geary #email client
      simple-scan #document scanner
      totem #video player
      yelp #help viewer
    ;
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

  # stylix = {
  #   enable = true;
  #   autoEnable = false;
  #   image = ../users/bruh/src/wallpaper.png;
  #   base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
  #   cursor =  {
  #     name = "catppuccin-macchiato-dark-cursors";
  #     package = pkgs.catppuccin-cursors.macchiatoDark;
  #     size = 32;
  #   };
  #   targets = {
  #     # gnome.enable = true;
  #     gtk.enable = true;
  #   };
  # };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [

    gnome-tweaks
    # gnome externsion to fix multimonitor bar support
    (stdenv.mkDerivation{
      name = "multi-monitors-add-on";
      src = fetchFromGitHub {
        owner = "lazanet";
      };
    })

    # use this overlay if ENV vars don't work with GDM
    (hyprland.overrideAttrs (prevAttrs: rec {
      postInstall =
        let
          hyprlandSession = ''
            [Desktop Entry]
            Name=Hyprland
            Comment=Dynamic Wayland compositor
            Exec= bash -l -c Hyprland
            Type=Application
          '';
        in
        ''
          mkdir -p $out/share/wayland-sessions
          echo "${hyprlandSession}" > $out/share/wayland-sessions/hyprland.desktop
        '';
      passthru.providedSessions = [ "hyprland" ];
    }))
  ];
}
