# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
export NVM_LAZY_LOAD_EXTRA_COMMANDS=('e', 'ed')

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY

source ~/antigen.zsh
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle git
antigen bundle lukechilds/zsh-nvm
antigen bundle zsh-users/zsh-autosuggestions
# antigen bundle "MichaelAquilina/zsh-autoswitch-virtualenv"
antigen theme romkatv/powerlevel10k
antigen apply

export FZF_DEFAULT_COMMAND="ag --hidden --ignore .git -f -g \"\""

#For Flutter 
# export PATH="$PATH":"$HOME/.pub-cache/bin"
export PATH="$PATH":"$HOME/.local/bin"
export PATH="$PATH":"$HOME/.emacs.d/bin"
# export PATH="$PATH":"/home/ayaan/Android/Sdk/platform-tools/"
# export PATH="$PATH":"/home/ayaan/Android/Sdk/tools/bin"
# export PATH="/home/ayaan/.local/share/solana/install/active_release/bin:$PATH"

# export AWS_PROFILE=personal
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/home/ayaan/go/bin

export GO_PATH=/home/ayaan/go/bin
# export FLYCTL_INSTALL="/home/ayaan/.fly"
# export PATH="$FLYCTL_INSTALL/bin:$PATH"

bindkey '^R' history-incremental-search-backward

export TERM=xterm-256color
export EDITOR=nvim
export NVM_AUTO_USE_ACTIVE=true

alias vim="nvim"
alias vi="nvim"
alias zconf="vi ~/.zshrc"
alias t="tmux a -t 0 || tmux"
alias cabr="cargo build && cargo run"
alias car="cargo run"
alias cab="cargo build"
alias copy="tr -d '\n' | pbcopy"
alias ls="exa "
alias l="exa -al"
alias c="code"
alias kille="emacsclient -e '(save-buffers-kill-emacs)'"
alias ed="emacs --daemon"
setopt auto_cd

# Make everything vim. Fuck it going all in.
bindkey -v
# eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Generated for envman. Do not edit.
# [ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

 
eval "$(zoxide init zsh)"
export LC_ALL=en_IN.UTF-8
export LANG=en_IN.UTF-8
e(){
  if [ $# -eq 0 ]
    then
      emacsclient -nce  "(select-frame-set-input-focus (selected-frame))" > /dev/null
  else
    emacsclient -nc "$@"
 fi
}


# Added by serverless binary installer
# export PATH="$HOME/.serverless/bin:$PATH"

# export PNPM_HOME="/home/ayaan/.local/share/pnpm"
# export PATH="$PNPM_HOME:$PATH"

# Added by Amplify CLI binary installer
# export PATH="$HOME/.amplify/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# export PATH="$PATH:$HOME/.rvm/bin"
# source /home/ayaan/.rvm/scripts/rvm
# . $HOME/.asdf/asdf.sh
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
