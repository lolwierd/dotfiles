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

## Troubleshooting

### `stow` reports a conflict

When running `make setup` (or `stow` directly) you may see something like:

```
stow: WARNING: existing target /home/you/.zshrc is not owned by stow: .zshrc
…
stow: ERROR: stow: Some targets failed: .zshrc …
```
or, from `make dry-run`:

```
LINK … clashes with existing file ~/.zshrc
```

**Why it happens.** Stow manages files by creating symlinks at the target path
(`~/.zshrc`, `~/.config/nvim`, …). If a real file or directory already exists
there and is not already a symlink back into this repo, stow refuses to overwrite
it and reports a conflict. This usually means a previous setup left a real file in
place (e.g. a stock `~/.zshrc` from the OS or an editor run), not that anything is
broken.

**Fix.** For each conflicting target, back up the existing file, remove it, then
re-run stow:

```bash
# 1. back up the existing target (path from the conflict message, e.g. ~/.zshrc)
mv ~/.zshrc ~/.zshrc.pre-stow.bak

# 2. remove it (skip if you only backed it up via mv above)
# rm -f ~/.zshrc

# 3. re-run stow
make setup                 # or: stow --dotfiles -d ~/dotfiles -t ~ shell config ai
```

For directory conflicts (e.g. `~/.config/nvim` already exists as a real dir),
back up and remove the whole directory the same way:

```bash
mv ~/.config/nvim ~/.config/nvim.pre-stow.bak
make setup
```

`make setup` already does this automatically for the known targets (it moves
conflicts into `~/.dotfiles-backups/setup-<timestamp>/`), so most fresh conflicts
are resolved simply by re-running it. If a conflict still appears afterward, it is
on a target not covered by the Makefile — handle it manually with the steps above,
then re-run `make setup`.

### Tips
- Run `make dry-run` first to preview what stow would link and what would clash,
  without changing anything.
- Do **not** `rm -rf` a path that is already a symlink into the repo; just let
  stow reconcile it.
- Backups made by `make setup` can be restored later with `make cleanup`
  (requires explicit confirmation).

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
