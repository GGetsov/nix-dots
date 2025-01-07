{ pkgs }:

# Use this instead if gtk themes don't apply or some other problem with ENV VARS.
# bash -c -l Hyprland

pkgs.writeShellScriptBin "launch-last-used-session" ''
  LAST=$(test -f "~/.cache/.hyprland_last")
  if test -f "$HOME/.cache/.hyprland_last" 
  then
    Hyprland 
  else 
    ${pkgs.gnome-session}/bin/gnome-session
  fi
''
