{ config, pkgs, lib, ... }:

let
  sources = import ./nix/sources.nix;
in  
{
  imports = [
    # include Plymouth theme
    (sources.nixos-catppuccin-plymouth + "/.")
    # include GRUB theme
    (sources.nixos-grub + "/.")
  ];
  
  boot.plymouth = {
    enable = true;
  };

  boot.kernelParams = ["quiet" "loglevel=0" "splash"];
  boot.consoleLogLevel = 0;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.initrd.systemd.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
    configurationLimit = 8;
    # useOSProber = true;

    # backgroundColor = "#181926";
    # splashImage = ./grub-theme/splash_image.png;
    # splashImage = (sources.nixos-grub + "/src/splash_image.png");
    # theme = pkgs.stdenv.mkDerivation {
    #   pname = "nixos-grub";
    #   version = "1.0";
    #   src = (sources.nixos-grub + "/src/");
    #   installPhase = "cp -r . $out";
    # };
    # theme = (import (sources.nixos-grub + "/default.nix"));
    # theme = (pkgs.catppuccin-grub.override { flavor = "macchiato";});

    # in case Windows is not booting properly from GRUB menu place the following line in the between "insmod chain" and "chainloader ..." lines
    # search --fs-uuid --set=root 6403-CBEB
    extraEntries = ''
      menuentry 'Windows 11' --class windows{
        insmod part_gpt
        insmod fat
        insmod search_fs_uuid
        insmod chain
        chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      }
      submenu 'Reboot / Shutdown' --class shutdown {
          menuentry Reboot --class restart { reboot }
          menuentry Shutdown --class shutdown { halt }
      }
    '';
    };
}
