{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell
{
  nativeBuildInputs = with pkgs; [
    nil
  ];

  shellHook = ''
    $EDITOR .
  '';
}
