{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    history = {
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
    };
    historySubstringSearch.enable = true;
    shellAliases = {
      vim = "nvim";
      vi = "nvim";
      zconf = "vi ~/.zshrc";
      nconf = "cd ~/.config/nvim && nvim .";
      dconf = "cd ~/dotfiles && nvim .";
      nixconf = "cd ~/dotfiles/nixos && nvim .";
      # Here for hisrtorical purposes 🫡
      # ns = "sudo rsync -acv ~/dotfiles/nixos/* /etc/nixos/ --exclude=hardware-configuration.nix && sudo nixos-rebuild switch";
      # nsu = "sudo rsync -acv ~/dotfiles/nixos/* /etc/nixos/ --exclude=hardware-configuration.nix && sudo nixos-rebuild switch --upgrade";
      ns = "sudo nixos-rebuild switch --flake ~/dotfiles/nixos";
      nsu = "sudo nixos-rebuild switch --flake ~/dotfiles/nixos --upgrade";
      t = "tmux-sessionizer";
      cabr = "cargo build && cargo run";
      car = "cargo run";
      cab = "cargo build";
      copy = "tr -d '\n' | pbcopy";
      ls = "exa ";
      l = "exa -al";
      s = "kitten ssh";
      n = "nvim .";
    };
    autocd = true;
    # autosuggestion.enable = true;
    # bindkey -v
    defaultKeymap = "viins";
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    initExtra = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      test -f ~/.p10k.zsh && source ~/.p10k.zsh
      export FZF_DEFAULT_COMMAND="ag --hidden --ignore .git -f -g \"\""
      export PATH=$PATH:/usr/local/go/bin
      export PATH=$PATH:~/.local/bin
      export PATH=$PATH:~/.local/scripts
      export PATH=$PATH:~/go/bin
      export PATH=$PATH:"$HOME/.emacs.d/bin"
      export TERM=xterm-256color
      export EDITOR=nvim
      export LC_ALL=en_IN.UTF-8
      export LANG=en_IN.UTF-8
      bindkey '^R' history-incremental-search-backward
      bindkey -s '^f' "tmux-sessionizer\n"
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # programs.starship = {
  # enable = true;
  # enableZshIntegration = true;
  # # Configuration written to ~/.config/starship.toml
  # settings = {
  # add_newline = false;
  # format = "$character";
  # right_format = "$all";
  # };
  # };
}
