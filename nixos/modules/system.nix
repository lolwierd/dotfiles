{ pkgs, lib, ... }:

{
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  time.timeZone = "Asia/Kolkata";
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
    # (nerdfonts.override {
    #   fonts = [
    #     "FiraCode"
    #     "DroidSansMono"
    #   ];
    # })
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # DEPRECATED: Enable sound with pipewire.
  # sound.enable = true;
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
      experimental-features = [
        "nix-command"
        "flakes"
      ];
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Some legacy packages (eg. qtwebengine-5.15.19) are marked insecure in newer
  # nixpkgs. Permit specific insecure packages explicitly to allow building
  # configurations that still depend on them. Prefer removing or replacing
  # these packages when possible.
  nixpkgs.config.permittedInsecurePackages = [ "qtwebengine-5.15.19" ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };
  programs.nix-ld.enable = true;
  programs.zsh.enable = true;
  # programs.steam = {
  #   enable = true;
  #   remotePlay.openFirewall = true;
  #   dedicatedServer.openFirewall = true;
  # };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
    python3
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
    cmake
    coreutils
    zoxide
    wget
    iptables
    bind
    tcpdump
    stow
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
    btop
    iotop
    iftop
    lsof
    sysstat
    ethtool
    pciutils
    nix-output-monitor
    tailscale
    packer
    qemu
    cloud-utils
    ghostty
  ];

  # Not supported with flakes :(
  # system.copySystemConfiguration = true;
}
