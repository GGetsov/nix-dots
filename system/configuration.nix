{ config, pkgs, lib, ... }:

{
  imports = [ # Include the results of the hardware scan.
  ];

  # nix.settings = {
  #   experimental-features = ["nix-command" "flakes"];
  #   substituters = [
  #     "https://nix-community.cachix.org"
  #     "https://hyprland.cachix.org"
  #   ];
  #   trusted-public-keys = [
  #     "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  #     "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
  #   ];
  # };

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
  ];

  programs.bash.promptInit = ''
  # Provide a nice prompt if the terminal supports it.
  if [ "$TERM" != "dumb" ]; then
    PROMPT_COLOR="1;31m"
    ((UID)) && PROMPT_COLOR="1;32m"
    PS1="\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
  fi
'';
}
