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

`make dry-run` shows what GNU Stow *would* do — without making any changes.
It runs Stow in verbose, no-op mode (`-nv`) against the `shell`, `config`,
and `ai` packages:

```bash
make dry-run
```

### What it does

- Simulates creating symlinks from `~/dotfiles/` into `$HOME`
- Prints every action it would take (create, modify, or skip)
- Does **not** touch the filesystem — no backup, no symlinks, no moves
- Uses the same `--dotfiles` convention as `make setup`, so `dot-zshrc` → `.zshrc`

### When to use it

- **Before running `make setup` for the first time** — preview exactly which
  symlinks will be created and where.
- **After adding or removing files** from a package — verify the effect before
  re-stowing.
- **When debugging conflicts** — see which files would clash without risking
  your current setup.
- **In automated workflows** — a safe, read-only way to check state.

### Example output

```
$ make dry-run
stow --dotfiles -d /home/you/dotfiles -t /home/you -nv shell config ai
WILL CREATE: /home/you/.zshrc => dot-zshrc
WILL CREATE: /home/you/.zshenv => dot-zshenv
...
```

## Undo setup (with confirmation)
```bash
make cleanup
```

`cleanup` will prompt for confirmation and prints an explicit warning for LLM/automation.
It unstows packages, then restores files from the last setup backup when possible.

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
