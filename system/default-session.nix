{ pkgs }:

pkgs.writeShellScriptBin "launch-last-used-session" ''
    LAST=$(test -f "~/.cache/.hyprland_last")
    if test -f "$HOME/.cache/.hyprland_last" 
    then
        bash -c -l Hyprland
    else 
        ${pkgs.gnome.gnome-session}/bin/gnome-session
    fi
''
