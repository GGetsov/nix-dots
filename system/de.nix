{ config, pkgs, lib, ... }:

{
  # Configure keymap in X11
  services.xserver = {
    enable = true;
    xkbOptions = "eurosign:e,caps:escape";
    layout = "us";
    excludePackages = [ pkgs.xterm ];
    

  # GDM
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

  environment.gnome.excludePackages = lib.attrValues {
    inherit (pkgs) 
      gnome-console
      epiphany #browser
      gnome-text-editor
      gnome-photos
      gnome-tour
      gnome-connections #something like team-viewer
      xdg-desktop-portal-gnome
    ;
    inherit (pkgs.gnome)
      gnome-music
      totem #video player
      simple-scan #document scanner
      gnome-maps
      geary #email client
      yelp #help viewer
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
            cursor-theme = "Catppuccin-Macchiato-Dark-Cursors";
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

    gnome3.gnome-tweaks

    (hyprland.overrideAttrs (prevAttrs: rec {
      postInstall =
        let
          launch-last-used-session = import ./default-session.nix { inherit pkgs; };

          hyprlandSession = ''
            [Desktop Entry]
            Name=Hyprland
            Comment=Dynamic Wayland compositor
            Exec= bash -l -c Hyprland
            Type=Application
          '';
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
          echo "${hyprlandSession}" > $out/share/wayland-sessions/hyprland.desktop
          echo "${defaultSession}" > $out/share/wayland-sessions/default.desktop
        '';
      passthru.providedSessions = [ "hyprland" "default" ];
    }))
  ];
  
  # GDM overlay that applies the custom gnome-shell theme
  nixpkgs = {
    overlays = [
      (self: super: {
        gnome = super.gnome.overrideScope' (selfg: superg: {
          gnome-shell = superg.gnome-shell.overrideAttrs (attrs: {
            postInstall = (attrs.postInstall or "") + ''
            glib-compile-resources ${./gnome-shell/gnome-shell-theme.gresource.xml} --sourcedir=${./gnome-shell} --target=$out/share/gnome-shell/gnome-shell-theme.gresource
            '';
          });
        });
      })
    ];
  };

  programs.hyprland = {
    enable = true;
    enableNvidiaPatches = true;
    xwayland.enable = true;
  };

  services.xserver.displayManager = {
    sessionPackages = [
      (pkgs.hyprland.overrideAttrs (prevAttrs: rec {
        postInstall =
          let
            launch-last-used-session = import ./default-session.nix { inherit pkgs; };
            
            # Fix ENV VARS missing issues by launching from bash
            hyprlandSession = ''
              [Desktop Entry]
              Name=Hyprland
              Comment=Dynamic Wayland compositor
              Exec= bash -l -c Hyprland
              Type=Application
            '';

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
            echo "${hyprlandSession}" > $out/share/wayland-sessions/hyprland.desktop
            echo "${defaultSession}" > $out/share/wayland-sessions/default.desktop
          '';
        passthru.providedSessions = [ "hyprland" "default" ];  
      }))
    ];
  };
}
