tmux bind-key v \\\; \
      send-keys nvim Enter

tmux bind-key V capture-pane -J \\\; \
    save-buffer "${TMPDIR:-/tmp}/tmux-buffer" \\\; \
    delete-buffer \\\; \
    new-window -n nvim -c "#{pane_current_path}" "sh -c 'nvim'"


