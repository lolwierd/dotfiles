{ ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  # home.file.".config/nvim" = {
  #   source = ./config;
  #   recursive = true;
  # };
}
