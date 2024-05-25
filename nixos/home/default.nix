{ pkgs, ... }:

{

  imports = [ ./programs ];

  home.username = "lolwierd";
  home.homeDirectory = "/home/lolwierd";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    spotify
    slack
    vscode
    discord
    jellyfin-media-player
    plex-media-player
    kdePackages.kdeconnect-kde
    filezilla
    microsoft-edge
    vivaldi
    gh
    postman
    lazygit
    lazydocker

    # Need a version of these globally to make "things" easier.
    go
    go-outline
    gopls
    gopkgs
    go-tools
    goimports-reviser
    delve
  ];

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

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
