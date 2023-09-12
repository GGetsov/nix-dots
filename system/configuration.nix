# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs,  ... }:

let
  nixos-boot = builtins.fetchTarball "https://github.com/Melkor333/nixos-boot/archive/main.tar.gz";
in  
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nixos-boot
    ];

  # Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  boot.kernelParams = ["quiet"];
  boot.initrd.systemd.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.grub = {
		enable = true;
		device = "nodev";
		efiSupport = true;
		enableCryptodisk = true;
		theme = pkgs.stdenv.mkDerivation {
			pname = "nixos-grub";
			version = "1.0";
			src = ./grub-theme;

			installPhase = "cp -r . $out";
		};
  };
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/sda2";
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
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = ["JetBrainsMono"]; })
  ];


  virtualisation.virtualbox.guest = {
  	enable = true;
	  x11 = true;
  };

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    xkbOptions = "eurosign:e,caps:escape";
    layout = "us";
     
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    desktopManager.gnome.enable = true;
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      kitty
      firefox
      tree
      qbittorrent
      vlc
    ];
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
	git
    gcc.cc.libgcc
    gcc8
    nodejs_20
    neovim
    glib
    glib.dev
    home-manager
    gnome3.gnome-tweaks
    libsForQt5.qtstyleplugins
    unzip
    ripgrep #Telescope live-grep
    cmake #Telescope fzf
  ];

  programs.dconf.enable = true;

  # qt = { 
  #  enable = true; 
  #  style = pkgs.lib.mkForce "gtk2"; 
  #  platformTheme = pkgs.lib.mkForce "gtk2"; 
  # };

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
