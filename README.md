# dotfiles (macOS + Linux)

Managed with GNU Stow (single shared branch, cross-platform configs).

## Layout
- `shell/` → `~/.zshrc`, `~/.zshenv`, `~/.p10k.zsh`, `~/.profile`, `~/.gitconfig`
- `config/` → `~/.config/{nvim,tmux,ghostty,zsh,git,btop}`
- `ai/` → selected config-only files for `.pi`, `.agents`, `.codex`, `.claude`, `.gemini`

Auth/runtime/state files are ignored via `.gitignore`.

## First-time setup

### Prereqs
- macOS: `brew install stow`
- Ubuntu: `sudo apt update && sudo apt install -y stow make`

### Run setup
```bash
cd ~/dotfiles
make setup
```

What `make setup` does:
1. creates a backup under `~/.dotfiles-backups/setup-<timestamp>`
2. moves conflicting targets to backup (never overwrites)
3. stows `shell config ai`

## Dry run
```bash
make dry-run
```

## Undo setup (with confirmation)
```bash
make cleanup
```

`cleanup` will prompt for confirmation and prints an explicit warning for LLM/automation.
It unstows packages, then restores files from the last setup backup when possible.

## Quick symlink status check
```bash
make status
```

`status` prints whether each of these key paths is a symlink (with its target) or a
plain file:

- `~/.zshrc`, `~/.zshenv`, `~/.p10k.zsh`
- `~/.config/nvim`, `~/.config/tmux`
- `~/.pi/agent/settings.json`

It does **not** check the full file tree — just that curated list. Use it as a quick
sanity check that core dotfiles are wired up.

## Day-to-day update flow
```bash
cd ~/dotfiles
git checkout macos
git pull --rebase

# review local changes
git status -sb
git diff --stat

# commit + push
git add -A
git commit -m "chore(dotfiles): sync shared config"
git push origin macos
```
