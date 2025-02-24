{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell
{
  nativeBuildInputs = with pkgs; [
    nil
    typescript-language-server
  ];

  shellHook = ''
    $EDITOR .
  '';
}
