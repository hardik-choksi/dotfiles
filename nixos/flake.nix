{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    antigravity-nix = {
          url = "github:jacopone/antigravity-nix";
          inputs.nixpkgs.follows = "nixpkgs";
      };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, antigravity-nix, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit antigravity-nix; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [
            plasma-manager.homeModules.plasma-manager
          ];
          home-manager.backupFileExtension = "backup";
          home-manager.users.hardik = import ./home.nix;
        }
      ];
    };
  };
}
