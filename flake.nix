{
  description = "gipsy's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mdfried = {
      url = "github:benjajaja/mdfried?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable, 
    home-manager,
    mdfried,
    claude-code,
    ...
  }@inputs:
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      # Common module arguments passed to all configurations
      specialArgs = { inherit inputs mdfried claude-code pkgs-unstable; };

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
