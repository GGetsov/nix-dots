{ config, pkgs, ... }:

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
    #Delete on real hardware
    #LIBGL_ALWAYS_SOFTWARE = 1;
  };

  home.packages = with pkgs; [
    kitty
    firefox
    tree
    qbittorrent
    vlc
    neovim-nightly
    rofi-wayland

    gnomeExtensions.user-themes
    gnomeExtensions.unite
  ];

  programs.git = {
    enable = true;
    userName = "GGetsov";
    userEmail = "g.getsov.dev@gmail.com";
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
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
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

      "org/gnome/shell/extensions/unite" = {
        #general
        extend-left-box = false;
        restrict-to-primary-screen = false;

        hide-activities-button = "never";
        hide-window-titlebars = "never";
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

    
  home.file = {
    
    ".config/hypr" = {
      source = ./hypr;
      recursive = true;
    };

    ".config/kitty" = {
      source = ./kitty;
      recursive = true;
    };

    ".config/rofi" = {
      source = ./rofi;
      recursive = true;
    };

    ".config/autostart/StartXWayland.desktop" = {
      source = ./gnome-autostart/StartXWayland.desktop;
    };

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
