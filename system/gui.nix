{ config, pkgs, lib, ... }:

{
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
    (nerdfonts.override { fonts = ["JetBrainsMono"]; })
    ];
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
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

  programs.dconf.enable = true;

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
  };

  system.stateVersion = "unstable"; # Did you read the comment?

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
}
