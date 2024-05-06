{ ... }:

{
  imports = [
    ./browsers
    ./git
    ./nvim
    ./kitty
    ./doom
    ./shell
    ./tmux
  ];

  programs.home-manager.enable = true;

  programs.nix-index.enable = true;
}
