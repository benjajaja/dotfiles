{
  description = "gipsy's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Previously fetched via builtins.getFlake
    iamb = {
      url = "github:ulyssa/iamb";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mdfried = {
      url = "github:benjajaja/mdfried/v0.14.6";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, iamb, mdfried, ... }@inputs:
    let
      system = "x86_64-linux";

      # Common module arguments passed to all configurations
      specialArgs = { inherit inputs iamb mdfried; };

      # Helper to create a NixOS system configuration
      mkHost = hostName: nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./hosts/${hostName}
          ./modules/common.nix
          ./modules/cachix.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.gipsy = import ./modules/home/home.nix;
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        # ThinkPad - Intel laptop
        motherbase = mkHost "thinkpad";

        # Slimbook - AMD/NVIDIA hybrid laptop
        lz = mkHost "slimbook";
      };
    };
}
