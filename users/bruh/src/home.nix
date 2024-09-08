{ lib, config, pkgs, inputs, ... }:

let 
  nvimPlugins = with pkgs.vimPlugins; [
    telescope-fzf-native-nvim
    nvim-treesitter.withAllGrammars
  ];
in
{
  imports = [
    ./src/zsh.nix
  ];
  home = {
    username = "bruh";
    homeDirectory = "/home/bruh";
    stateVersion = "23.05"; # Please read the comment before changing.
  };
  
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  programs.bash = {
    enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    tree
    oh-my-posh
    syncthing
  ];

  programs.git = {
    enable = true;
    userName = "GGetsov";
    userEmail = "g.getsov.dev@gmail.com";
    extraConfig = {
      init.defaultBranch = "main"; 
    };
  };
    
   programs.neovim = {
     enable = true;
     package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
     viAlias = true;
     vimAlias = true;
     plugins = nvimPlugins;
     extraPackages = with pkgs; [
       ripgrep #Telescope live-grep
       cmake #Telescope fzf
     ];
   };
  
  xdg = {
    enable = true;
    configFile = {
      "hypr".source = ./config/hypr;
      "kitty/kitty.conf".source = ./config/kitty/kitty.conf;
      "rofi".source = ./config/rofi;
      "autostart".source = ./config/gnome-autostart;

      #treesitter setup all parsers bc lazy deletes them or something
      "nvim/parser".source = "${pkgs.symlinkJoin {
        name = "treesitter-parsers";
        paths = (pkgs.vimPlugins.nvim-treesitter.withAllGrammars).dependencies;
      }}/parser";
    };
  };
    
  home.file = {
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
