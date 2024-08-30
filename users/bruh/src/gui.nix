{ lib, config, pkgs, inputs, ... }:

let
  # catppuccin-gtk = {
  #   # name = "Catppuccin-Macchiato-Standard-Mauve-Dark";
  #   name = "Catppuccin-Macchiato-Standard-Text-Dark";
  #   package = (pkgs.catppuccin-gtk.overrideAttrs {
  #     
  #     # installPhase = ''
  #     #   mkdir -p $out/share/themes
  #     #   export HOME=$(mktemp -d)
  #     #   cp -r ${./test/Catppuccin-Macchiato-Standard-Text-Dark} $out/share/themes/Catppuccin-Macchiato-Standard-Text-Dark
  #     #   cp -r ${./test/Catppuccin-Macchiato-Standard-Text-Dark-hdpi} $out/share/themes/Catppuccin-Macchiato-Standard-Text-Dark-hdpi
  #     #   cp -r ${./test/Catppuccin-Macchiato-Standard-Text-Dark-xhdpi} $out/share/themes/Catppuccin-Macchiato-Standard-Text-Dark-xhdpi
  #     #
  #     #   runHook postInstall
  #     # '';
  #
  #   installPhase = let
  #     sources = (import ../../../system/nix/sources.nix);
  #     gtk = (import sources.nixpuccin-macchiato).gtk;
  #   in
  #     ''
  #       runHook preInstall
  #
  #       cp -r colloid colloid-base
  #       mkdir -p $out/share/themes
  #       export HOME=$(mktemp -d)
  #
  #       cp ${gtk}/install.py ./install.py
  #       cp ${gtk}/var.py ./scripts/var.py
  #
  #       python3 install.py "macchiato" --accent "text" --size "standard" --tweaks "rimless" --dest $out/share/themes
  #       
  #       patch -d $out/share/themes/Catppuccin-Macchiato-Standard-Text-Dark/gnome-shell/ < ${gtk}/patch
  #
  #       runHook postInstall
  #     '';
  #
  #   }).override {
  #     accents = [ "mauve" ];
  #     size = "standard";
  #     tweaks = [ "rimless" ];
  #     variant = "macchiato";
  #   };
  # };
  # 
  mkTuple = lib.hm.gvariant.mkTuple;

  catppuccin-gtk = (pkgs.magnetic-catppuccin-gtk.override {
    tweaks = ["macchiato" "macos"];
  });
in
{
  xsession.enable = true;

  # home.sessionVariables = {
  #   GTK_THEME = catppuccin-gtk.name;
  # };

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-GTK-Dark-Macchiato";
      package = catppuccin-gtk;
      # package = pkgs.magnetic-catppuccin-gtk;
      # name = catppuccin-gtk.name;
      # package = catppuccin-gtk.package;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "catppuccin-macchiato-dark-cursors";
      package = pkgs.catppuccin-cursors.macchiatoDark;
      size = 32;
    };
    gtk3.extraConfig = {
    #   Settings = ''
        gtk-application-prefer-dark-theme = 1;
    #   '';
    };
    gtk4.extraConfig = {
    #   Settings = ''
        gtk-application-prefer-dark-theme=1;
    #   '';
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        #apps in dock
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "kitty.desktop"
          "firefox.desktop"
        ];
        #extensions
        disable-user-extensions = false;
        enabled-extensions = [
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "unite@hardpixel.eu"
        ];
      };

      "org/gnome/shell/extensions/user-theme" = {
        name = catppuccin-gtk.name;
      };

      "org/gnome/desktop/background" = {
        picture-uri = "file:///home/bruh/.config/nix-dots/users/bruh/src/wallpaper.png";
        picture-uri-dark = "file:///home/bruh/.config/nix-dots/users/bruh/src/wallpaper.png";
      };

      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
        titlebar-font = "JetBrainsMono Nerd Font 14";
      };

      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        #fonts
        font-name = "JetBrainsMono Nerd Font 14";
        document-font-name = "JetBrainsMono Nerd Font 14";
        monospace-font-name = "JetBrainsMono Nerd Font 14";
      };
      
      #keyboard layouts + different for different windows
      "org/gnome/desktop/input-sources" = {
        sources = [ (mkTuple ["xkb" "us"]) (mkTuple ["xkb" "bg+phonetic"]) ];
        per-window = true;
      };
      
      #numlock by default
      "org/gnome/desktop/peripherals/keyboard" = {
        numlock-state = true;
      };

      "org/gnome/shell/extensions/unite" = {
        #general
        extend-left-box = false;
        restrict-to-primary-screen = false;

        hide-activities-button = "never";
        # handled by autostart
        # hide-window-titlebars = "never";
        show-window-title = "never";
        show-window-buttons = "never";
        #appearance
        greyscale-tray-icons = true;
        hide-app-menu-icon = false;
        reduce-panel-spacing = false;
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name =  "gtk2";
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

    gnomeExtensions.user-themes
    gnomeExtensions.unite
  ];

  xdg = {
    # also declared in home.nix
    enable = true;
    mimeApps = {
    enable = true;
    associations.added = {
      "application/pdf" = ["org.gnome.Evince.desktop"];
    };
    defaultApplications = {
      "application/pdf" = ["org.gnome.Evince.desktop"];
    };
  };
  };

  programs.firefox = {
    enable = true;
    profiles.bruh = {
      bookmarks = [
        {
          # name = "Singles";
          toolbar = true;
          bookmarks = [
            {
              name = "Blackboard";
              url = "https://elearn.mu-varna.bg/";
            }
            {
              name = "Webstudent";
              url = "https://webstudent.mu-varna.bg";
            }
          ];
        }
        { 
          # name = "Folders";
          toolbar = true;
          bookmarks = [
            { 
              name = "Study";
              bookmarks = [
                {
                  name = "5 kurs";
                  url = "https://drive.google.com/drive/folders/1gwV_0arFMICVYtxqF9_G_0oXXP7dxNnT";
                }
                {
                  name = "6 kurs";
                  url = "https://drive.google.com/drive/folders/1S_hfoHuqoWtIkH9kG7q6iJ9-zUsAIwvu";
                }
              ];
            } 
          ];
        }
      ];
      settings = {
        "browser.privatebrowsing.autostart" = true;
        "browser.translations.automaticallyPopup" =  false;
      };
      extraConfig = ''
	      user_pref("extensions.autoDisableScopes", 0);
	      user_pref("extensions.enabledScopes", 15);
      '';
      extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
        keepassxc-browser
        ublock-origin
        vimium-c
      ];
    };
  };
}
