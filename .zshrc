# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/antigen.zsh
antigen bundle git
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen theme romkatv/powerlevel10k
antigen apply

export FZF_DEFAULT_COMMAND="ag --hidden --ignore .git -f -g \"\""
# If you come from bash you might have to change your $PATH.
export PATH=/Library/PostgreSQL/13/bin:$PATH
export PATH=/Users/ayaan/opt/miniconda3/bin:$PATH
export PATH=$HOME/bin:/usr/local/bin:/usr/local/mysql/bin:$PATH
export PATH=$HOME/Library/flutter/bin:$PATH
export PATH=$HOME/Library/Android/sdk/platform-tools:$PATH
export PATH=/Users/ayaan/Library/Android/sdk/build-tools/29.0.2:$PATH
export PATH=/Applications/Julia-1.5.app/Contents/Resources/julia/bin/:$PATH
export PATH=$HOME/.emacs.d/bin:$PATH
export PATH=$HOME/.composer/vendor/bin:$PATH
export PATH=/Users/ayaan/.local/bin:$PATH

#For Flutter 
export PATH="$PATH":"$HOME/.pub-cache/bin"
# Path to your oh-my-zsh installation.
export ZSH="/Users/ayaan/.oh-my-zsh"
export TERM=xterm-256color
export EDITOR=nvim
# To tell emacsclient to open emacs in daemon mode if not already running
export ALTERNATE_EDITOR=""

export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_PATH=$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator
export JAVA_HOME="/Applications/Android Studio.app/Contents/jre/jdk/Contents/Home"
source /usr/local/etc/profile.d/z.sh

# Example aliases
alias zshconfig="mate ~/.zshrc"
alias scheme="chez"
alias vim="nvim"
alias vi="nvim"
alias cabr="cargo build && cargo run"
alias car="cargo run"
alias cab="cargo build"
alias copy="tr -d '\n' | pbcopy"
alias dons="cat ~/imp | copy"
alias ls="exa --icons"
alias l="exa --icons -al"
alias c="code ."
alias e=" open -a Emacs"
setopt auto_cd
# alias ohmyzsh="mate ~/.oh-my-zsh"
export LDFLAGS="-L/usr/local/opt/openblas/lib"
export CPPFLAGS="-I/usr/local/opt/openblas/include"
export PKG_CONFIG_PATH="/usr/local/opt/openblas/lib/pkgconfig"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
. "$NVM_DIR"/nvm.sh

# To load nvm
# Defer initialization of nvm until nvm, node or a node-dependent command is
# run. Ensure this block is only run once if .bashrc gets sourced multiple times
# by checking whether __init_nvm is a function.
# Does not work with doom emacs
# if [ -s "$HOME/.nvm/nvm.sh" ] && [ ! "$(type __init_nvm)" = function ]; then export NVM_DIR="$HOME/.nvm"
  # [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  # declare -a __node_commands=('nvm' 'node' 'npm' 'yarn' 'gulp' 'grunt' 'webpack')
  # function __init_nvm() {
    # for i in "${__node_commands[@]}"; do unalias $i; done
    # . "$NVM_DIR"/nvm.sh
    # unset __node_commands
    # unset -f __init_nvm
  # }
# for i in "${__node_commands[@]}"; do alias $i='__init_nvm && '$i; done
# fi

# eval "$(starship init zsh)"

[ -f "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env" ] && source "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env"
#
# Make everything vim. Fuck it going all in.
bindkey -v
if [ -e /Users/ayaan/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/ayaan/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
source ~/functions.zsh
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/ayaan/.sdkman"
[[ -s "/Users/ayaan/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/ayaan/.sdkman/bin/sdkman-init.sh"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
lg()
{
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

    lazygit "$@"

    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
            cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
            rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    fi
}

eval $(thefuck --alias fuc)

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/ayaan/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/ayaan/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/ayaan/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/ayaan/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
