{
  description = "NixOS Configuration for lolwierd";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nur,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        oishii = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            { nixpkgs.overlays = [ nur.overlay ]; }
            ./hosts/oishii
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hbk";
              home-manager.extraSpecialArgs = inputs;
              home-manager.users.lolwierd.imports = [ ./home ];
            }
          ];
        };
        kakkoii = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            { nixpkgs.overlays = [ nur.overlay ]; }
            ./hosts/kakkoii
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hbk";
              home-manager.extraSpecialArgs = inputs;
              home-manager.users.lolwierd.imports = [ ./home ];
            }
          ];
        };
      };
    };
}
