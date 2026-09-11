# dotfiles (macOS + Linux)

Managed with GNU Stow (single shared branch, cross-platform configs).

## Layout
- `shell/` → `~/.zshrc`, `~/.zshenv`, `~/.p10k.zsh`, `~/.profile`, `~/.gitconfig`
- `config/` → `~/.config/{nvim,tmux,ghostty,zsh,git,btop}`
- `ai/` → selected config-only files for `.pi`, `.agents`, `.codex`, `.claude`, `.gemini`
- `editors/` → VS Code and iTerm2 config (not stow packages — see below)
- `Brewfile` → the tools these configs assume

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

## New machine (macOS)

```bash
brew install stow
git clone git@github.com:lolwierd/dotfiles.git ~/dotfiles
cd ~/dotfiles
make brew      # install the Brewfile
make setup     # backup conflicts, then stow shell config ai
make vscode    # link VS Code settings + install extensions
make iterm2    # import iTerm2 prefs (quit iTerm2 first)
```

Machine-local secrets are **not** in this repo. Create
`~/.config/zsh/keys.local.zsh` by hand and export what you need there.

## Editors

VS Code and iTerm2 store their config under `~/Library`, which stow's
`--dotfiles` mode cannot target, so `editors/` is linked and imported by
explicit make targets rather than stowed:

- `make vscode` symlinks `editors/vscode/{settings,keybindings}.json` into
  `~/Library/Application Support/Code/User/` (backing up any real file first)
  and installs everything in `editors/vscode/extensions.txt`.
- `make iterm2` copies `editors/iterm2/` into `~/.config/iterm2/` and runs
  `defaults import com.googlecode.iterm2`. **Quit iTerm2 first** — it rewrites
  its plist on exit and will clobber the import. The committed plist has
  window frames, `NoSync*` UI state, and update-checker timestamps stripped.

To capture new editor config back into the repo, copy the live files over
`editors/…` and commit; there is no automatic export.

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
