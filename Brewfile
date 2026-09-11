# Brewfile — the tools this repo's configs actually assume.
#
# Scope: what `shell/` and `config/` reference by name, plus the language
# toolchains used day to day. Deliberately excludes personal/media packages
# (calibre, ani-cli, IINA, Blender, …) so a work machine stays lean.
#
#   brew bundle --file=~/dotfiles/Brewfile

# --- dotfiles plumbing ---
brew "stow"                  # Makefile's symlink manager
brew "make"                  # macOS ships GNU Make 3.81; this Makefile needs 3.82+ (.ONESHELL)

# --- shell ---
brew "powerlevel10k"         # sourced by shell/dot-zshrc
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# --- editor / multiplexer ---
brew "neovim"                # $EDITOR, alias vi/n; config/dot-config/nvim
brew "tmux"                  # config/dot-config/tmux
brew "lua-language-server"   # nvim LSP
brew "stylua"                # nvim formatter
brew "luarocks"

# --- navigation and search (referenced by aliases/functions in dot-zshrc) ---
brew "fzf"                   # cproj, lg
brew "fd"                    # FZF_DEFAULT_COMMAND, lg
brew "ripgrep"
brew "zoxide"
brew "eza"                   # alias ls/l
brew "bat"
brew "btop"                  # config/dot-config/btop
brew "tree"

# --- git ---
brew "git"                   # newer than /usr/bin/git; config/dot-config/git
brew "git-delta"             # pager configured in shell/dot-gitconfig
brew "gh"
brew "lazygit"

# --- kubernetes (the k*/ks aliases in dot-zshrc) ---
brew "kubernetes-cli"
brew "kubectx"
brew "stern"
brew "helm"

# --- language toolchains ---
brew "go"
brew "rustup"
brew "nvm"                   # dot-zshrc lazy-loads node/npm/pnpm from $NVM_DIR
brew "uv"
brew "pnpm"

# --- misc CLI ---
brew "direnv"                # hooked in dot-zshrc
brew "jq"
brew "yq"
brew "wget"
brew "openssh"

# --- casks ---
# aerospace lives in a third-party tap. Homebrew 6 will not install from an
# untrusted tap, so run `brew trust nikitabobko/tap` once before `make brew`.
tap "nikitabobko/tap"

cask "ghostty"               # config/dot-config/ghostty
cask "nikitabobko/tap/aerospace"  # config/dot-config/aerospace
cask "font-meslo-lg-nerd-font"    # powerlevel10k glyphs
