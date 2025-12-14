{
  description = "Matt's NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # dotfiles = {
    #   url = "github:mat2cc/dotfiles/master";
    #   flake = false;
    # };

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }@inputs: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        # enable the following when we have multiple hosts
        # nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mattc = ./hosts/nixos/home.nix;

            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
      rpi4 = nixpkgs.lib.nixosSystem {
        # enable the following when we have multiple hosts
        # nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/rpi4/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mattc = ./hosts/nixos/home.nix;

            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
    darwinConfigurations."Matt's Macbook" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/darwin/configuration.nix
        # home-manager.darwinModules.home-manager
        # {
        #   home-manager.useGlobalPkgs = true;
        #   home-manager.useUserPackages = true;
        #   home-manager.users.mattc = ./home.nix;
        # }
      ];
    };
  };
}
