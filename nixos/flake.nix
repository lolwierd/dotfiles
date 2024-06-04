{
  description = "NixOS Configuration for lolwierd";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      plasma-manager,
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
              home-manager.extraSpecialArgs = {
                inherit inputs;
                plasma-manager = inputs.plasma-manager;
              };
              home-manager.users.lolwierd.imports = [ ./home/gnome ];
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
              home-manager.extraSpecialArgs = {
                inherit inputs;
                plasma-manager = inputs.plasma-manager;
              };
              home-manager.users.lolwierd.imports = [ ./home/kde ];
            }
          ];
        };
      };
    };
}
