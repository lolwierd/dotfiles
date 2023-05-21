# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
export NVM_LAZY_LOAD_EXTRA_COMMANDS=('e', 'ed')
export NVM_AUTO_USE_ACTIVE=true

source ~/powerlevel10k/powerlevel10k.zsh-theme
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
export FZF_DEFAULT_COMMAND="ag --hidden --ignore .git -f -g \"\""

export PATH="$PATH":"$HOME/.local/bin"
export PATH="$PATH":"$HOME/.emacs.d/bin"
export PATH="$PATH":"$HOME/go/bin"
export PATH="$PATH":"/opt/homebrew/opt/mysql-client/bin"
export PATH="$PATH":"$HOME/.emacs.d/bin"
export TERM=xterm-256color
export EDITOR=nvim
#
# Set bat as manpager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"


alias vim="nvim"
alias vi="nvim"
alias zconf="vi ~/.zshrc"
alias nconf="cd ~/.config/nvim && nvim ."
alias t="tmux a -t 0 || tmux"
alias cabr="cargo build && cargo run"
alias car="cargo run"
alias cab="cargo build"
alias copy="tr -d '\n' | pbcopy"
alias ls="exa "
alias l="exa -al"
alias c="code"
alias n="nvim ."
alias kille="emacsclient -e '(save-buffers-kill-emacs)'"
alias ed="emacs --daemon"
alias python="/opt/homebrew/opt/python@3.9/libexec/bin/python3"
setopt auto_cd


eval "$(zoxide init zsh)"

e(){
  if [ $# -eq 0 ]
    then
      emacsclient -nce  "(select-frame-set-input-focus (selected-frame))" > /dev/null
  else
    emacsclient -nc "$@"
 fi
}

bindkey -v

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# export DIRENV_LOG_FORMAT=
eval "$(direnv hook zsh)"
# export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
# export CPPFLAGS="-I/opt/homebrew/opt/openjdk@17/include"
# export JAVA_HOME=`/usr/libexec/java_home`

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

