{ config, pkgs, lib, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  networking.hostName = "nixos";

  # Set your time zone.
  time.timeZone = "Europe/Sofia";
  
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
  ];
}
