{
  description = "A flake managing everything hypr and all its dependencies";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, firefox-addons, ... }@inputs:
  {
    homeManagerModules.firefox = { pkgs, config, ... }:{
      imports = [
         (import ./. { inherit pkgs; inherit config; inherit inputs;})
      ];
    };
  };
}
