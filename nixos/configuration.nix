# Edit this configuration file to define what should be installed oncon
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernel.sysctl."net.ipv6.mld_qrv" = lib.mkDefault "1";

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
    };
  };

  networking = {
    hostName = "oishii";
    networkmanager = {
      enable = true;
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # GNOME 45 DE.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Plasma 6 DE.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
      options = "caps:swapescape";
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lolwierd = {
    uid = 1000;
    hashedPassword = "$6$9ferZG9Rd0VX.xF9$vossOtzoH6.REKjwJmlu21sleSiCXfGvOaeRGdHazSxcUT1C5hmpd3nVawLH4QHVrjs2XjSC2NyYeNjB1fVDz0";
    description = "oishii";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "lolwierd";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  # systemd.services."getty@tty1".enable = false;
  # systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (self: super: {
      vivaldi = super.vivaldi.override {
        commandLineArgs =
          "--disable-features=AllowQt";
      };
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    emacs
    git
    eza
    dig
    zip
    unzip
    zsh
    inetutils
    gnumake
    gcc
    tmux
    htop
    btop
    fzf
    ripgrep
    fd
    clang
    libtool
    cmake
    coreutils
    zoxide
    neovim
    wget
    tailscale
    iptables
    bind
    tcpdump
    stow
    lua-language-server
    mtr
    iperf3
    dnsutils
    ldns
    aria2
    socat
    nmap
    ipcalc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    nix-output-monitor
    btop
    iotop
    iftop
    lsof
    sysstat
    ethtool
    pciutils
    comma
    knot-dns
    nix-index
    postgresql
    wayland-utils
    wl-clipboard
    wireguard-tools
    epson-escpr
  ];

  environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.nix-ld.enable = true;
  programs.zsh.enable = true;
  # programs.steam = {
    # enable = true;
    # remotePlay.openFirewall = true;
    # dedicatedServer.openFirewall = true;
  # };
  
  virtualisation.docker.enable = true;

  services.tailscale.enable = true;
  services.pcscd.enable = true;
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      IdleAction=suspend-then-hibernate
      IdleActionSec=2m
    '';
  };
  systemd.sleep.extraConfig = "HibernateDelaySec=1h";

  # builtin service does not work cause it starts before the graphical session. So the emacsclients cannot connect.
  systemd.user.services.emacs = {
    description = "Emacs: the extensible, self-documenting text editor";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.bash}/bin/bash -c 'source ${config.system.build.setEnvironment}; exec ${pkgs.emacs}/bin/emacs --daemon'";
      ExecStop = "${pkgs.emacs}/bin/emacsclient --eval (kill-emacs)";
      Restart = "always";
    };
    environment = {
      SSH_AUTH_SOCK = "%h/.gnupg/S.gpg-agent.ssh";
      GTK_DATA_PREFIX = config.system.path;
      GTK_PATH = "${config.system.path}/lib/gtk-3.0:${config.system.path}/lib/gtk-2.0";
      INFOPATH = "%h/.nix-profile/info:%h/.nix-profile/share/info:/nix/var/nix/profiles/default/info:/nix/var/nix/profiles/default/share/info:/run/current-system/sw/info:/run/current-system/sw/share/info:";
      PHARO_VM = "%h/.nix-profile/bin/pharo-vm-nox";
      TERMINFO_DIRS = "/run/current-system/sw/share/terminfo";
      NIX_CONF_DIR = "/etc/nix";
      NIX_OTHER_STORES = "/run/nix/remote-stores/*/nix";
      NIX_PATH = "nixpkgs=%h/nixpkgs:nixos=%h/nixpkgs/nixos:nixos-config=/etc/nixos/configuration.nix";
      NIX_PROFILES = "${pkgs.lib.concatStringsSep " " config.environment.profiles}";
      NIX_REMOTE = "daemon";
      NIX_USER_PROFILE_DIR = "/nix/var/nix/profiles/per-user/%u";
    };
  };



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

  # Not supported with flakes :(
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  
}
