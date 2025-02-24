{
  description = "A flake managing ags config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # add ags
    ags.url = "github:Aylur/ags";
  };

  outputs = { nixpkgs, ags, ... }@inputs:
  {
    homeManagerModules.ags = { pkgs, config, ... }:{
      imports = [
         (import ./. { inherit pkgs; inherit config; inherit inputs;})
      ];
    };
  };
}
