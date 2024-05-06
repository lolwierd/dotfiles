{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      vivaldi = super.vivaldi.override {
        commandLineArgs =
          "--disable-features=AllowQt";
      };
    })
  ];
}
