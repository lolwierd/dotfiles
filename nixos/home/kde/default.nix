{ pkgs, plasma-manager, ... }:

{
  imports = [
    plasma-manager.homeModules.plasma-manager
    ../programs
    ./kde.nix
  ];

  home.username = "lolwierd";
  home.homeDirectory = "/home/lolwierd";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # spotify
    slack
    vscode
    #discord
    jellyfin-media-player
    kdePackages.kdeconnect-kde
    filezilla
    # microsoft-edge
    # vivaldi
    gh
    lazygit
    lazydocker
    postman
    # lutris
    zed-editor
    jetbrains.goland
    jetbrains.datagrip
    windsurf

    # Need a version of these globally to make "things" easier.
    go
    go-outline
    gopls
    gopkgs
    go-tools
    goimports-reviser
    delve

    # wrangler
  ];

  # Nicely reload system units when changing configs
  # systemd.user.startServices = "sd-switch";

  # programs.plasma.enable = true;

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";
}
