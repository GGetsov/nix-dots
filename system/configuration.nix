# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib, ... }:

let
  nixos-boot = builtins.fetchTarball "https://github.com/Melkor333/nixos-boot/archive/main.tar.gz";
in  
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nixos-boot
    ];

  nixpkgs.config.allowUnfree = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = false;
    };
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;

    prime = {
      # sync.enable= true;
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  services.xserver.videoDrivers = ["nvidia"];

  # Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  boot.kernelParams = ["quiet"];
  boot.consoleLogLevel = 0;
  boot.initrd.systemd.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.grub = {
		enable = true;
		device = "nodev";
		efiSupport = true;
		enableCryptodisk = true;
    backgroundColor = "#181926";
    splashImage = ./grub-theme/splash_image.png;
		theme = pkgs.stdenv.mkDerivation {
			pname = "nixos-grub";
			version = "1.0";
			src = ./grub-theme;

			installPhase = "cp -r . $out";
		};
    extraEntries = ''
      submenu 'Reboot / Shutdown' --class shutdown {
          menuentry Reboot --class restart { reboot }
          menuentry Shutdown --class shutdown { halt }
      }
    '';
  };
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-label/CRYPTED";
      preLVM = true;
    };
  };

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Sofia";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  console = {
    earlySetup = true;
    packages = [ pkgs.terminus_font ];
    font = "ter-128n";
    keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
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

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = ["JetBrainsMono"]; })
  ];


  # virtualisation.virtualbox.guest = {
  # 	enable = true;
	 #  x11 = true;
  # };

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    xkbOptions = "eurosign:e,caps:escape";
    layout = "us";
    excludePackages = [ pkgs.xterm ];
     
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    desktopManager = {
      gnome.enable = true;
      xterm.enable = false;
    };
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bruh = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
	git
    neovim
    home-manager

    unzip
    ripgrep #Telescope live-grep
    cmake #Telescope fzf

    gnome3.gnome-tweaks
    gnome.gnome-terminal
  ];

  environment.gnome.excludePackages = lib.attrValues {
    inherit (pkgs) 
      gnome-console
      epiphany #browser
      gnome-text-editor
      gnome-photos
      gnome-tour
    ;
    inherit (pkgs.gnome)
      gnome-music
      totem #video player
      simple-scan #document scanner
      gnome-maps
      geary #email client
      yelp #help viewer
    ;
  };

  programs.dconf.enable = true;

  #programs.hyprland.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "unstable"; # Did you read the comment?

  nixpkgs = {
    overlays = [
      (self: super: {
        gnome = super.gnome.overrideScope' (selfg: superg: {
          gnome-shell = superg.gnome-shell.overrideAttrs (attrs: {
            postInstall = (attrs.postInstall or "") + ''
            glib-compile-resources ${./gnome-shell/gnome-shell-theme.gresource.xml} --sourcedir=${./gnome-shell} --target=$out/share/gnome-shell/gnome-shell-theme.gresource
            '';
          });
        });
      })
    ];
  };
}
