{
  description = "Home manager laptop config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hypr = {
      url = "/home/bruh/.config/nix-dots/users/bruh/src/hypr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    stylix.url = "github:danth/stylix";

    firefox = {
      url = "/home/bruh/.config/nix-dots/users/bruh/src/firefox";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { nixpkgs, home-manager, neovim-nightly-overlay, stylix, hypr, firefox, ... }@inputs:
  let 
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    machine = "laptop";

    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];

  in {
    homeConfigurations = {
      bruh = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {inherit machine; inherit inputs;};

        modules = [
          { nixpkgs.overlays = overlays; }
          ../src/home.nix
          ../src/gui.nix
          ../src/update-commands.nix

          hypr.homeManagerModules.hypr
          firefox.homeManagerModules.firefox
          stylix.homeManagerModules.stylix
          ];
      }; 
    };
  };
}
