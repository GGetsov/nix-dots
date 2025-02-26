{
  description = "A flake managing everything hypr and all its dependencies";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # add ags config flake
    ags = {
      url = "/home/bruh/.config/nix-dots/users/bruh/src/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # latest hypridle from git to get inhibit sleep functionality - delete later
    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ags, ... }@inputs:
  {
    homeManagerModules.hypr = { pkgs, config, ... }:{
      imports = [
         (import ./. { inherit pkgs; inherit config; inherit inputs;})
          ags.homeManagerModules.ags
      ];
    };
  };
}
