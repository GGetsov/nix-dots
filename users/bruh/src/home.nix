{ lib, config, pkgs, inputs, ... }:

let 
  catppuccin-gtk = {
    name = "Catppuccin-Macchiato-Standard-Mauve-Dark";
    package = pkgs.catppuccin-gtk.override {
      accents = [ "mauve" ];
      size = "standard";
      tweaks = [ "rimless" ];
      variant = "macchiato";
    };
  };
   
  nvimPlugins = with pkgs.vimPlugins; [
    telescope-fzf-native-nvim
    nvim-treesitter.withAllGrammars
  ];

  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  home.username = "bruh";
  home.homeDirectory = "/home/bruh";

  home.stateVersion = "23.05"; # Please read the comment before changing.

  programs.bash = {
    enable = true;
  };

  xsession.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    GTK_THEME = catppuccin-gtk.name;
  };

  home.packages = with pkgs; [
    kitty
    tree
    qbittorrent
    vlc
    neovim-nightly
    rofi-wayland
    hyprpaper
    keepassxc
    libreoffice

    gnomeExtensions.user-themes
    gnomeExtensions.unite
  ];

  programs.git = {
    enable = true;
    userName = "GGetsov";
    userEmail = "g.getsov.dev@gmail.com";
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
              ];
            } 
          ];
        }
      ];
      settings = {
        "browser.privatebrowsing.autostart" = true;
        "browser.translations.automaticallyPopup" =  false;
      };
      extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
        keepassxc-browser
        ublock-origin
        vimium-c
      ];
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = catppuccin-gtk.name;
      package = catppuccin-gtk.package;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Catppuccin-Macchiato-Dark-Cursors";
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
    platformTheme = "gtk";
    style.name =  "gtk2";
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = nvimPlugins;
  };

  xdg = {
    enable = true;
    # configHome = ./config;
    configFile = {
      "hypr".source = ./config/hypr;
      "kitty/kitty.conf".source = ./config/kitty/kitty.conf;
      "rofi".source = ./config/rofi;
      "autostart".source = ./config/gnome-autostart;
    };
  };
    
  home.file = {
    
    # ".config/hypr" = {
    #   source = ./hypr;
    #   recursive = true;
    # };

    # ".config/kitty" = {
      # source = ./config/kitty;
      # recursive = true;
    # };

    # ".config/rofi" = {
    #   source = ./config/rofi;
    #   recursive = true;
    # };
    
    # Autotart XServer even on wayland in order to fix kitty transparency bug
    # ".config/autostart/StartXWayland.desktop" = {
    #   source = ./config/gnome-autostart/StartXWayland.desktop;
    # };

    #generate lua file containing a table with Nix managed plugins (pkg.name = pkg.out) and their locations
    ".config/nvim/lua/nix-plugins.lua".text = let
      tableEntries = map (plugin: 
        ''pkgs["${plugin.src.repo}"] = "${plugin.out}"''
      ) nvimPlugins;
    in ''
    local pkgs = {}
    ${builtins.concatStringsSep "\n" tableEntries}
    return pkgs
    '';

  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
