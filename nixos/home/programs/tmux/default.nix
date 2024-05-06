{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    newSession = true;
    historyLimit = 10000;
    mouse = true;
    keyMode = "vi";
    prefix = "C-a";
    terminal = "xterm-256color";
    shell = "${pkgs.zsh}/bin/zsh";
    disableConfirmationPrompt = true;
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.yank;
	      extraConfig = "set -g @yank_selection_mouse 'clipboard'";
      }
      {
        plugin = pkgs.tmuxPlugins.tmux-fzf;
      }
    ];
    extraConfig = ''
      bind-key C-a last-window
      bind r source-file ~/.config/tmux/tmux.conf
      # Mome intuitive bindings for splitting
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      # switch panes using Alt without prefix
      bind -n M-h select-pane -L
      bind -n M-l select-pane -R
      bind -n M-k select-pane -U
      bind -n M-j select-pane -D
      bind-key -r f run-shell "tmux neww ~/.local/scripts/tmux-sessionizer"
      # skip "kill-pane 1? (y/n)" prompt
      bind-key x kill-pane
      # don't exit from tmux when closing a session
      set -g detach-on-destroy off
      set -g status-bg black
      set -g status-fg colour137
      set -g status-left '#[bold][ #S ]'
      set -g status-right '#[bold][ %d/%m %H:%M ]'
      set -g status-right-length 50
      set -g status-left-length 50
      set -g status-justify centre
      setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F '
      setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244] '
      set-option -sg escape-time 10
      set-option -g focus-events on
      set-option -sa terminal-overrides ',xterm-256color:RGB'
      set -g default-terminal "tmux-256color"
      set-option -sa terminal-overrides ",tmux-256color:Tc"
      # Undercurl
      # set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # underscore colours - needs tmux-3.0
      # bind-key "f" run-shell -b "${pkgs.tmuxPlugins.tmux-fzf}/share/tmux-plugins/tmux-fzf/scripts/session.sh switch"
    '';
  };
}
