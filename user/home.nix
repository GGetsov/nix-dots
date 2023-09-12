{ config, pkgs, ... }:

let
  theme_name = "Catppuccin-Macchiato-Standard-Mauve-Dark";
  theme_package = pkgs.catppuccin-gtk.override {
    accents = [ "mauve" ];
    size = "standard";
    tweaks = [ "rimless" "black" ];
    variant = "macchiato";
  }; 
  nvPlugins = with pkgs.vimPlugins; [
    telescope-fzf-native-nvim
    nvim-treesitter.withAllGrammars
  ];
  in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "alice";
  home.homeDirectory = "/home/alice";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  programs.bash = {
    enable = true;
    initExtra = ''
      export EDITOR="nvim"
      export GTK_THEME="Catppuccin-Macchiato-Standard-Mauve-Dark"
    '';
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    (writeShellScriptBin "update-user" ''
      pushd ~/.dotfiles/user/ > /dev/null 2>&1
      home-manager switch -f ./home.nix
      popd > /dev/null 2>&1
    '')

    (writeShellScriptBin "update-system" ''
      pushd ~/.dotfiles/system/ > /dev/null 2>&1
      sudo nixos-rebuild switch -I nixos-config=./configuration.nix
      popd > /dev/null 2>&1
    '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/alice/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "nvim";
    GTK_THEME = "Catppuccin-Macchiato-Standard-Mauve-Dark";
  };
  
  gtk = {
    enable = true;
    theme = {
      name = theme_name;
      package = theme_package;
      # name = theme_name;
      # package = theme_package;
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

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;

      # `gnome-extensions list` for a list
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];
    };
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
    style.name =  "gtk2";
  };

  # home.file.".config/gtk-4.0/gtk.css".source = "${theme_package}/share/themes/${theme_name}/gtk-4.0/gtk.css";
  # home.file.".config/gtk-4.0/gtk-dark.css".source = "${theme_package}/share/themes/${theme_name}/gtk-4.0/gtk-dark.css";
  #
  # home.file.".config/gtk-4.0/assets" = {
  #   recursive = true;
  #   source = "${theme_package}/share/themes/${theme_name}/gtk-4.0/assets";
  # };
 
  
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = nvPlugins;
  };

  home.file.".config/nvim/lua/nixos-dir/managed.lua".text = let
    vimLazyPlugins = map (plugin: {
      # name = "${plugin.src.owner}/${plugin.src.repo}";
      name = "${plugin.src.repo}";
      dir = "${plugin.out}";
    }) nvPlugins;
    renderedPlugins = builtins.map
      # (p: ''{ "${p.name}", dir = "${p.dir}"}'')
      (p: ''pkgs["${p.name}"] = "${p.dir}"'')
      vimLazyPlugins;
  in ''
  local pkgs = {}
  ${builtins.concatStringsSep "\n" renderedPlugins}
  return pkgs
  '';
   
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
