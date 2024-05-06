{ ... }:

{
  imports = [
    ./browsers
    ./git
    ./nvim
    ./shell
    ./tmux
  ];

  programs.home-manager.enable = true;

  programs.nix-index.enable = true;
}
