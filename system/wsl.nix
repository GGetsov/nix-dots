{ config, lib, pkgs, ... }:

let 
  sources = import ./nix/sources.nix;
in
{
  imports = [
    # include NixOS-WSL modules
    (sources.NixOS-WSL + "/modules")
  ];

  wsl.enable = true;
  wsl.defaultUser = "bruh";

  programs.bash.loginShellInit = "";
  

 system.stateVersion = "unstable";
}
