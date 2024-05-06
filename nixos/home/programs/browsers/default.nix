{ config, pkgs, ... }:

{
  imports = [
    ./chromium.nix
    ./firefox.nix
  ];
}
