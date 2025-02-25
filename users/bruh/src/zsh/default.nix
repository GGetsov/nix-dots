{ lib, config, pkgs, inputs, ... }:

{
  programs.zsh = {
    enable = true;
    prezto = {
      enable = true;
      caseSensitive = false;
    };
    # enableCompletion = true;
    # autosuggestion.enable = true;
    # syntaxHighlighting.enable = true;
    sessionVariables = {
      EDITOR = "nvim";
    };
    shellAliases = {
      ll = "ls -l";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    initExtra = ''
      #Start oh-my-posh
      eval "$(oh-my-posh init zsh -c ~/.config/nix-dots/users/bruh/src/config/oh-my-posh/config.toml)"
    '';
  };
}
