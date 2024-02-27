{ config, pkgs, lib, ... }:

{
  console = {
    earlySetup = true;
    packages = [ pkgs.terminus_font ];
    font = "ter-128n";
    keyMap = "us";
    colors = [
      "24273a"
      "ed8796"
      "a6da95"
      "eed49f"
      "f5a97f"
      "8aadf4"
      "c6a0f6"
      "b8c0e0"
      "5b6078"
      "ed8796"
      "a6da95"
      "eed49f"
      "f5a97f"
      "8aadf4"
      "c6a0f6"
      "a5adcb"
    ];
  };
}
