{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell
{
  nativeBuildInputs = with pkgs; [
    nixd
  ];

  shellHook = ''
    nvim .
  '';
}
