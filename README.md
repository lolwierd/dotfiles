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

## Undo setup

```bash
make cleanup
```

### What it does

1. **Warns** — prints an explicit warning (including a special stop-signal for LLMs/automation).
2. **Prompts** — interactive `[y/N]` confirmation before making any changes.
3. **Unstows** — removes all symlinks created by `make setup` for `shell`, `config`, and `ai`.
4. **Restores** — reads the last setup backup pointer and restores your original files
   (those that were moved aside during `make setup`) back to their original locations.
   Targets that already exist in `$HOME` are skipped — nothing is overwritten.

### Caveats

- **⚠️ Never run this without explicit user approval.** The cleanup prompt itself includes
  a warning telling LLMs/automation to stop and ask first.
- Restoration only works if the backup directory from the last `make setup` still
  exists under `~/.dotfiles-backups/`.
- If you have run `make setup` multiple times, only the **most recent** backup is
  restored; older backups are left untouched.
- Any files you created or modified *after* the last setup (that were not part of
  the original backup) are left alone — cleanup never removes or overwrites them.
- Cleanup will skip restoration of any file whose target path already exists
  (e.g., if you re-created something manually after unstowing).

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
