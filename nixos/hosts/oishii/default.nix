{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/users.nix
    ../../modules/services.nix
    ../../modules/overlays
    ../../modules/kde.nix
  ];

  boot = {
    supportedFilesystems = [ "ntfs" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernel = {
      sysctl."net.ipv6.mld_qrv" = lib.mkDefault "1";
    };
  };

  networking = {
    hostName = "oishii";
    networkmanager = {
      enable = true;
    };
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
    };
  };

  environment.systemPackages = with pkgs; [
    emacs
    nixfmt-rfc-style
    comma
    lua-language-server
    knot-dns
    nix-index
    postgresql
    wayland-utils
    wl-clipboard
    wireguard-tools
    epson-escpr
    libtool
  ];

  # Idk if i should put it in home manager.
  environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # networking.firewall = {
  # allowedUDPPorts = [ 54834 ];
  # };
  # networking.wireguard.interfaces = {
  # wg0 = {
  # ips = [ "10.9.0.3/24" ];
  # listenPort = 54834;
  # privateKeyFile = "/etc/wireguard/private.key";
  # peers = [
  # {
  # publicKey = "4wDQtXzBzEwHRIUBiWg49qVadkcDjseDw07jV0I+Rj4=";
  # allowedIPs = [ "10.9.0.0/24" "10.0.0.0/24" ];
  # endpoint = "103.77.108.121:5210";
  # persistentKeepalive = 5;
  # }
  # ];
  # };
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
