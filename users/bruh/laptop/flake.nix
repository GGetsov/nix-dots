{
  description = "Home manager laptop config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { nixpkgs, home-manager, neovim-nightly-overlay, ... }@inputs:
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
          ];
      }; 
    };
  };
}
