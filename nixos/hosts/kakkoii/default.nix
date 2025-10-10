{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/users.nix
    ../../modules/services
    ../../modules/overlays
    ../../modules/kde
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
    hostName = "kakkoii";
    interfaces = {
      enp2s0 = {
        ipv4.addresses = [
          {
            address = "192.168.29.150";
            prefixLength = 24;
          }
        ];
      };
    };
    defaultGateway = "192.168.29.1";
    nameservers = [ "8.8.8.8" ];
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-tools
        vkd3d
        mesa
      ];
    };
  };
  # fileSystems."/mnt/data" = {
  #   device = "/dev/disk/by-uuid/12ad36de-4c5a-4c05-b657-11aecabb197f";
  #   fsType = "ext4";
  #   options = [
  #     "nofail"
  #     "noatime"
  #     "nosuid"
  #     "nodev"
  #     "rw"
  #   ];
  # };

  # fileSystems."/mnt/backup" = {
  #   device = "/dev/disk/by-uuid/9d1e73e4-88a9-46be-813c-a86cef744a7d";
  #   fsType = "ext4";
  #   options = [
  #     "nofail"
  #     "noatime"
  #     "nosuid"
  #     "nodev"
  #     "rw"
  #   ];
  # };

  # services.samba = {
  #   enable = true;
  #   package = pkgs.samba4Full; # Includes necessary VFS modules like 'fruit'
  #   openFirewall = true;
  #   securityType = "user";
  #   settings = {
  #     global = {
  #       "workgroup" = "WORKGROUP";
  #       "server string" = "Time Machine Backup Server";
  #       "netbios name" = "kakkoii";
  #       "security" = "user";
  #       "map to guest" = "bad user";
  #       "vfs objects" = "catia fruit streams_xattr";
  #       "fruit:aapl" = "yes";
  #       "fruit:time machine" = "yes";
  #     };
  #     "TimeMachine" = {
  #       "path" = "/mnt/backup";
  #       "valid users" = "lolwierd";
  #       "read only" = "no";
  #       "guest ok" = "no";
  #       "browseable" = "yes";
  #       "create mask" = "0600";
  #       "directory mask" = "0700";
  #       "force user" = "lolwierd";
  #     };
  #   };
  # };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  systemd.services.samba = {
    after = [ "mnt-backup.mount" ];
    requires = [ "mnt-backup.mount" ];
  };

  services.ratbagd.enable = true;

  services.openssh.enable = true;

  systemd.services.console-app = {
    description = "Console web terminal service";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      ${pkgs.nodejs}/bin/npm install --include=dev
      ${pkgs.nodejs}/bin/npm run build
    '';
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/home/lolwierd/console";
      User = "lolwierd";
      Environment = [
        "NODE_ENV=production"
      ];
      EnvironmentFile = "/etc/console-app.env";
      ExecStart = "${pkgs.nodejs}/bin/node dist/server/server.js";
      Restart = "on-failure";
    };
  };


  environment.systemPackages = with pkgs; [
    emacs
    nixfmt-rfc-style
    nixd
    comma
    lua-language-server
    # knot-dns
    nix-index
    postgresql
    wayland-utils
    wl-clipboard
    wireguard-tools
    # epson-escpr
    # libtool
    # libratbag
    piper
    # caddy
    # containerlab
    # wireshark-cli
    # gns3-gui
    # gns3-server

    # gnome.gnome-tweaks
    # gnomeExtensions.appindicator
  ];

  # services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  services.pulseaudio.enable = false;
  # services.logind.extraConfig = ''
  # IdleAction=ignore
  # IdleActionSec=0
  # '';
  # programs.steam = {
  #   enable = true;
  #   remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #   dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  #   localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  # };

  # Idk if i should put it in home manager.
  environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source =
    "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # Or disable the firewall altogether.
  networking.firewall.enable = false;

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
  system.stateVersion = "24.05"; # Did you read the comment?
}
