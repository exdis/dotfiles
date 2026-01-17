{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mango = {
      url = "github:DreamMaoMao/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, mango, ... } @inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        inputs.stylix.nixosModules.stylix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.exdis = import ./home.nix;

          home-manager.extraSpecialArgs = { inherit inputs; };
        }
        ./modules/noctalia.nix
        mango.nixosModules.mango
        {
          programs.mango.enable = true;
        }
      ];
      specialArgs = { inherit inputs; };
    };
  };
}

