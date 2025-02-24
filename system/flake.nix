{
  description = "NixOS configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, stylix }: {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./boot.nix
          ./configuration.nix
          ./de.nix
          ./hardware-configuration.nix
          ./laptop.nix
          ./tty.nix
          stylix.nixosModules.stylix
        ];
      };
      vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./de.nix
          ./hardware-configuration.nix
          ./vm.nix
          ./tty.nix
        ];
      };
      wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./wsl.nix
          ./configuration.nix
        ];
      };
    };
  };
}
