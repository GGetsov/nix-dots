{ config, pkgs, lib, ... }:

let
  nixos-boot = builtins.fetchTarball "https://github.com/Melkor333/nixos-boot/archive/main.tar.gz";
in  
{
  imports = [ ./nixos-boot ];
  boot.kernelParams = ["quiet"];
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
        # useOSProber = true;
    backgroundColor = "#181926";
    splashImage = ./grub-theme/splash_image.png;
		theme = pkgs.stdenv.mkDerivation {
			pname = "nixos-grub";
			version = "1.0";
			src = ./grub-theme;

			installPhase = "cp -r . $out";
		};
    extraEntries = ''
      menuentry 'Windows 11' --class windows{
        insmod part_gpt
        insmod fat
        insmod search_fs_uuid
        insmod chain
        search --fs-uuid --set=root 6403-CBEB
        chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      }
      submenu 'Reboot / Shutdown' --class shutdown {
          menuentry Reboot --class restart { reboot }
          menuentry Shutdown --class shutdown { halt }
      }
    '';
    };
}
