---
name: dotfiles
description: Understand and modify lolwierd's dotfiles. Read this skill when asked to add a config file, install a skill/extension/theme, edit shell config, or anything that touches ~/.zshrc, ~/.config/*, ~/.agents/*, ~/.pi/*, ~/.claude/*, ~/.codex/*, ~/.gemini/* etc. Explains GNU Stow layout, dot- prefix convention, and the correct way to make changes that survive across machines.
---

# Dotfiles — How They Work

**Location:** `~/dotfiles/` (git-managed, branch `macos`)  
**Tool:** GNU Stow with `--dotfiles` flag  
**Packages:** `shell`, `config`, `ai`

## The dot- Prefix Convention

Stow's `--dotfiles` flag translates `dot-` prefixes to `.` when creating symlinks:

```
dotfiles/shell/dot-zshrc        → ~/.zshrc
dotfiles/config/dot-config/nvim → ~/.config/nvim
dotfiles/ai/dot-agents/skills/  → ~/.agents/skills/
dotfiles/ai/dot-pi/agent/       → ~/.pi/agent/
dotfiles/ai/dot-claude/         → ~/.claude/
dotfiles/ai/dot-codex/          → ~/.codex/
dotfiles/ai/dot-gemini/         → ~/.gemini/
```

## Package Layout

```
~/dotfiles/
├── shell/                        # → targets in ~/  (dotfiles)
│   ├── dot-zshrc                 # → ~/.zshrc
│   ├── dot-zshenv                # → ~/.zshenv
│   ├── dot-p10k.zsh              # → ~/.p10k.zsh
│   ├── dot-profile               # → ~/.profile
│   └── dot-gitconfig             # → ~/.gitconfig
│
├── config/                       # → targets in ~/.config/
│   └── dot-config/
│       ├── nvim/                 # → ~/.config/nvim/
│       ├── tmux/                 # → ~/.config/tmux/
│       ├── ghostty/              # → ~/.config/ghostty/
│       ├── zsh/                  # → ~/.config/zsh/
│       ├── git/                  # → ~/.config/git/
│       └── btop/                 # → ~/.config/btop/
│
└── ai/                           # → various AI tool configs
    ├── dot-agents/               # → ~/.agents/
    │   └── skills/               # → ~/.agents/skills/
    │       ├── commit/SKILL.md
    │       ├── surf/SKILL.md     # ← symlinked as whole dir
    │       └── ...
    ├── dot-pi/                   # → ~/.pi/
    │   └── agent/
    │       ├── settings.json
    │       ├── extensions/
    │       ├── keybindings.json
    │       ├── prompts/
    │       └── themes/
    ├── dot-claude/CLAUDE.md      # → ~/.claude/CLAUDE.md
    ├── dot-codex/                # → ~/.codex/
    └── dot-gemini/               # → ~/.gemini/
```

## How Symlinks Work Here

Stow normally links at the **file level** (creates real dirs, symlinks files). But when a directory has no conflicts in `~`, stow may "fold" it and symlink the **whole directory**.

In this repo, some skill dirs are whole-dir symlinks (surf, visual-explainer); others are real dirs with individual file symlinks. Both work fine.

**Check what's a symlink vs real dir:**
```bash
ls -la ~/.agents/skills/
ls -la ~/.pi/agent/
```

## How to Add or Change a Config File

### Rule: ALWAYS edit inside `~/dotfiles/`, never the live `~/.` path directly.

The live paths are symlinks (or contain symlinks) — editing the dotfiles source is the correct way to make persistent, version-controlled changes.

### Adding a new skill (e.g. `foo`)

```bash
# 1. Create it in dotfiles
mkdir -p ~/dotfiles/ai/dot-agents/skills/foo
# write SKILL.md there

# 2. Symlink it (match the pattern of surf/visual-explainer)
ln -s ~/dotfiles/ai/dot-agents/skills/foo ~/.agents/skills/foo

# 3. Commit
cd ~/dotfiles && git add -A && git commit -m "feat(ai): add foo skill"
```

### Editing an existing config (e.g. zshrc, nvim, tmux)

```bash
# Edit the source directly in dotfiles — the symlink means changes are live instantly
nvim ~/dotfiles/shell/dot-zshrc
nvim ~/dotfiles/config/dot-config/nvim/init.lua
nvim ~/dotfiles/config/dot-config/tmux/tmux.conf

# Commit when done
cd ~/dotfiles && git add -A && git commit -m "chore(shell): ..."
```

### Editing AI tool configs

```bash
# pi settings / extensions / keybindings / themes
~/dotfiles/ai/dot-pi/agent/settings.json
~/dotfiles/ai/dot-pi/agent/keybindings.json
~/dotfiles/ai/dot-pi/agent/extensions/

# Claude system prompt
~/dotfiles/ai/dot-claude/CLAUDE.md

# Codex
~/dotfiles/ai/dot-codex/

# Gemini
~/dotfiles/ai/dot-gemini/GEMINI.md
```

### Adding a new top-level dotfile (e.g. `~/.foo`)

```bash
# Put it in the shell package with dot- prefix
cp ~/.foo ~/dotfiles/shell/dot-foo
rm ~/.foo
cd ~/dotfiles && stow --dotfiles -d . -t "$HOME" shell
git add -A && git commit -m "feat(shell): track .foo"
```

### Adding a new ~/.config/* dir (e.g. `~/.config/bar`)

```bash
mkdir -p ~/dotfiles/config/dot-config/bar
# copy or create files inside
cd ~/dotfiles && stow --dotfiles -d . -t "$HOME" config
git add -A && git commit -m "feat(config): track bar config"
```

## Re-stowing After Changes

The `ai` stow package currently has some pre-existing real directories that cause conflicts when running full `make setup`. Use targeted stows for specific packages:

```bash
cd ~/dotfiles

# Shell and config packages stow cleanly:
stow --dotfiles -d . -t "$HOME" shell
stow --dotfiles -d . -t "$HOME" config

# For ai package, manually symlink new dirs instead (see "Adding a new skill" above)
# Full stow of ai package has known conflicts from pre-stow real dirs in web-browser/
```

## Day-to-Day Git Flow

```bash
cd ~/dotfiles
git checkout macos
git pull --rebase

# make your change, then:
git add -A
git commit -m "chore(dotfiles): ..."
git push origin macos
```

## Useful Commands

```bash
# Dry-run to see what stow would do
make dry-run

# Check symlink status of key files
make status

# Verify a specific path
ls -la ~/.agents/skills/surf    # should show symlink → dotfiles/
readlink ~/.agents/skills/surf
```

## What NOT to Do

- ❌ Don't edit files directly at `~/.zshrc`, `~/.config/nvim/`, etc. — always go through `~/dotfiles/`
- ❌ Don't run `make cleanup` without explicit user permission (it unstows everything)
- ❌ Don't `rm -rf ~/.agents/skills/surf` — remove the symlink with `rm` (not `-rf` on target), or `unlink`
- ❌ Don't commit auth tokens, API keys, or session files — they're gitignored
