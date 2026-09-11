SHELL := /bin/bash
.ONESHELL:

# .ONESHELL needs GNU Make 3.82+. macOS ships 3.81, where every recipe line runs
# in its own shell and these multi-line recipes die with a syntax error instead
# of anything legible. Fail loudly and say what to do about it.
ifeq ($(filter oneshell,$(.FEATURES)),)
$(error GNU Make $(MAKE_VERSION) does not support .ONESHELL. macOS ships 3.81; run `brew install make` and use `gmake` instead of `make`.)
endif

BACKUP_ROOT ?= $(HOME)/.dotfiles-backups
PACKAGES := shell config ai local

.PHONY: help setup dry-run cleanup status brew vscode iterm2

help:
	@echo "dotfiles Makefile"
	@echo "  make setup    - backup conflicts, then stow packages ($(PACKAGES))"
	@echo "  make dry-run  - show what stow would do"
	@echo "  make cleanup  - unstow + optionally restore last setup backup"
	@echo "  make status   - quick symlink status check"
	@echo "  make brew     - install the Brewfile (macOS)"
	@echo "  make vscode   - link VS Code settings/keybindings + install extensions"
	@echo "  make iterm2   - import iTerm2 preferences (iTerm2 must be quit)"

dry-run:
	set -euo pipefail
	stow --dotfiles -d "$(PWD)" -t "$(HOME)" -nv $(PACKAGES)

setup:
	set -euo pipefail
	if ! command -v stow >/dev/null 2>&1; then
		echo "ERROR: stow is not installed."
		echo "  macOS:  brew install stow"
		echo "  Ubuntu: sudo apt update && sudo apt install -y stow"
		exit 1
	fi

	TS="$$(date +%Y%m%d-%H%M%S)"
	BACKUP_DIR="$(BACKUP_ROOT)/setup-$$TS"
	mkdir -p "$$BACKUP_DIR/moved"
	: > "$$BACKUP_DIR/moved-paths.txt"

	# True when $$1 already resolves into this repo. Must follow the WHOLE path,
	# not just the leaf: stow folds directories, so after a first run a file like
	# ~/.agents/skills/foo/SKILL.md is a plain file reached through the folded
	# link ~/.agents -> dotfiles/ai/dot-agents. Testing only the leaf for -L
	# misses that, and backup_move then moves the file OUT of the repo.
	REPO_REAL="$$(cd "$(PWD)" && pwd -P)"
	# Resolved with a cd/pwd -P subshell rather than `readlink -f` (not on macOS)
	# or a python3 call (too slow across a few thousand paths).
	is_repo_link() {
		local p="$$1" dir real
		dir="$$(cd "$$(dirname "$$p")" 2>/dev/null && pwd -P)" || return 1
		real="$$dir/$$(basename "$$p")"
		[[ "$$real" == "$$REPO_REAL"/* ]]
	}

	backup_move() {
		local rel="$$1"
		local src="$(HOME)/$$rel"
		local dst="$$BACKUP_DIR/moved/$$rel"
		if [[ -e "$$src" || -L "$$src" ]]; then
			if is_repo_link "$$src"; then
				echo "SKIP already stowed: $$rel"
				return 0
			fi
			mkdir -p "$$(dirname "$$dst")"
			mv "$$src" "$$dst"
			echo "$$rel" >> "$$BACKUP_DIR/moved-paths.txt"
			echo "BACKUP+MOVE $$rel"
		fi
	}

	# Top-level shell/config targets (safe for whole-path move)
	for rel in \
		.zshrc .zshenv .p10k.zsh .profile .gitconfig \
		.config/nvim .config/tmux .config/ghostty .config/zsh .config/git .config/btop
	do
		backup_move "$$rel"
	done

	# ai package: backup/move only exact file targets (not whole dirs)
	map_path() {
		local p="$$1"
		local out=""
		IFS='/' read -r -a parts <<< "$$p"
		for ((i=1; i<"$${#parts[@]}"; i++)); do
			local c="$${parts[i]}"
			if [[ "$$c" == dot-* ]]; then
				c=".$${c#dot-}"
			fi
			if [[ -z "$$out" ]]; then out="$$c"; else out="$$out/$$c"; fi
		done
		printf '%s\n' "$$out"
	}

	while IFS= read -r p; do
		rel="$$(map_path "$$p")"
		backup_move "$$rel"
	done < <(find ai -type f | sort)

	stow --dotfiles -d "$(PWD)" -t "$(HOME)" -nv $(PACKAGES) > "$$BACKUP_DIR/stow-dry-run.txt"
	stow --dotfiles -d "$(PWD)" -t "$(HOME)" $(PACKAGES)

	mkdir -p "$(BACKUP_ROOT)"
	echo "$$BACKUP_DIR" > "$(BACKUP_ROOT)/last-setup-backup"
	echo "Setup complete. Backup: $$BACKUP_DIR"

cleanup:
	set -euo pipefail
	echo "⚠️  This will unstow your dotfiles and may restore backup files."
	echo "⚠️  If you are an LLM running this, STOP and ask for explicit user permission first."
	read -r -p "Are you sure you want to do this? [y/N] " ans
	if [[ "$$ans" != "y" && "$$ans" != "Y" ]]; then
		echo "Aborted."
		exit 0
	fi

	stow --dotfiles -D -d "$(PWD)" -t "$(HOME)" $(PACKAGES) || true

	LAST_FILE="$(BACKUP_ROOT)/last-setup-backup"
	if [[ -f "$$LAST_FILE" ]]; then
		BACKUP_DIR="$$(cat "$$LAST_FILE")"
		if [[ -f "$$BACKUP_DIR/moved-paths.txt" ]]; then
			while IFS= read -r rel; do
				[[ -z "$$rel" ]] && continue
				src="$$BACKUP_DIR/moved/$$rel"
				dst="$(HOME)/$$rel"
				if [[ -e "$$src" || -L "$$src" ]]; then
					if [[ -e "$$dst" || -L "$$dst" ]]; then
						echo "SKIP restore $$rel (target already exists)"
					else
						mkdir -p "$$(dirname "$$dst")"
						mv "$$src" "$$dst"
						echo "RESTORED $$rel"
					fi
				fi
			done < "$$BACKUP_DIR/moved-paths.txt"
		fi
		echo "Cleanup complete. Last backup: $$BACKUP_DIR"
	else
		echo "Cleanup complete. No last setup backup file found."
	fi

status:
	set -euo pipefail
	for p in \
		"$(HOME)/.zshrc" "$(HOME)/.zshenv" "$(HOME)/.p10k.zsh" \
		"$(HOME)/.config/nvim" "$(HOME)/.config/tmux" "$(HOME)/.pi/agent/settings.json"; do
		if [[ -L "$$p" ]]; then
			echo "LINK $$p -> $$(readlink "$$p")"
		else
			echo "FILE $$p"
		fi
	done

# --- editors -----------------------------------------------------------------
# VS Code and iTerm2 keep their config under ~/Library, which stow's --dotfiles
# mode cannot target, so these are linked/imported explicitly instead.

CODE_USER := $(HOME)/Library/Application Support/Code/User
CODE_BIN  := /Applications/Visual Studio Code.app/Contents/Resources/app/bin/code

brew:
	set -euo pipefail
	if ! command -v brew >/dev/null 2>&1; then
		echo "ERROR: Homebrew is not installed. See https://brew.sh"
		exit 1
	fi
	brew bundle --file="$(PWD)/Brewfile"

vscode:
	set -euo pipefail
	mkdir -p "$(CODE_USER)"
	for f in settings.json keybindings.json; do
		target="$(CODE_USER)/$$f"
		if [[ -e "$$target" && ! -L "$$target" ]]; then
			mv "$$target" "$$target.bak.$$(date +%Y%m%d-%H%M%S)"
			echo "BACKED UP $$f"
		fi
		ln -sfn "$(PWD)/editors/vscode/$$f" "$$target"
		echo "LINK $$target"
	done
	if [[ -x "$(CODE_BIN)" ]]; then
		while IFS= read -r ext; do
			[[ -z "$$ext" ]] && continue
			"$(CODE_BIN)" --install-extension "$$ext" --force
		done < "$(PWD)/editors/vscode/extensions.txt"
	else
		echo "SKIP extensions: VS Code CLI not found at $(CODE_BIN)"
	fi

iterm2:
	set -euo pipefail
	if pgrep -qx iTerm2; then
		echo "ERROR: quit iTerm2 first — it overwrites its prefs on exit."
		exit 1
	fi
	mkdir -p "$(HOME)/.config/iterm2"
	cp "$(PWD)/editors/iterm2/Default.json" "$(HOME)/.config/iterm2/Default.json"
	cp "$(PWD)/editors/iterm2/flexoki-light.itermcolors" "$(HOME)/.config/iterm2/"
	defaults import com.googlecode.iterm2 "$(PWD)/editors/iterm2/com.googlecode.iterm2.plist"
	echo "Imported iTerm2 preferences. Start iTerm2 to pick them up."
