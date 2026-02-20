# Shared zsh environment config.
#
# IMPORTANT: keep secrets out of git.
# Put private exports in: ~/.config/zsh/keys.local.zsh
# Example:
#   export OPENROUTER_API_KEY="..."
#   export EXPENSE_TRACKER_MCP_TOKEN="..."

[[ -f ~/.config/zsh/keys.local.zsh ]] && source ~/.config/zsh/keys.local.zsh
