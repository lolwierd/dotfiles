# AGENTS.md — dotfiles

Guidelines for AI agents operating in this repository.

---

## What This Repo Is

Personal dotfiles for `lolwierd`, managed with **GNU Stow** (`--dotfiles` flag).
Branch: `macos`. Symlinks are created into `$HOME`.

```
~/dotfiles/
├── shell/          # dot-zshrc → ~/.zshrc, dot-gitconfig → ~/.gitconfig, etc.
├── config/         # dot-config/nvim → ~/.config/nvim, tmux, ghostty, zsh, btop, git
└── ai/             # dot-agents/ → ~/.agents/, dot-pi/ → ~/.pi/, dot-claude/ → ~/.claude/
                    # dot-codex/ → ~/.codex/, dot-gemini/ → ~/.gemini/
```

The `dot-` prefix is Stow's convention for translating to a `.` prefix in the target:
`dot-zshrc` → `~/.zshrc`, `dot-config/nvim` → `~/.config/nvim`, etc.

---

## Golden Rule — Always Edit Inside `~/dotfiles/`

The live paths (`~/.zshrc`, `~/.config/nvim/`, `~/.agents/skills/`, etc.) are symlinks
(or contain symlinks) back into this repo. **Never edit them directly.**

```bash
# ✅ correct
edit ~/dotfiles/shell/dot-zshrc
edit ~/dotfiles/config/dot-config/nvim/init.lua
edit ~/dotfiles/ai/dot-agents/skills/commit/SKILL.md

# ❌ wrong — edits may be lost or create confusion
edit ~/.zshrc
edit ~/.config/nvim/init.lua
```

---

## Package Structure & Key Paths

| Source path (in repo)                         | Live path              |
|-----------------------------------------------|------------------------|
| `shell/dot-zshrc`                             | `~/.zshrc`             |
| `shell/dot-zshenv`                            | `~/.zshenv`            |
| `shell/dot-gitconfig`                         | `~/.gitconfig`         |
| `shell/dot-p10k.zsh`                          | `~/.p10k.zsh`          |
| `config/dot-config/nvim/`                     | `~/.config/nvim/`      |
| `config/dot-config/tmux/`                     | `~/.config/tmux/`      |
| `config/dot-config/ghostty/`                  | `~/.config/ghostty/`   |
| `config/dot-config/zsh/`                      | `~/.config/zsh/`       |
| `config/dot-config/git/`                      | `~/.config/git/`       |
| `config/dot-config/btop/`                     | `~/.config/btop/`      |
| `ai/dot-agents/skills/`                       | `~/.agents/skills/`    |
| `ai/dot-pi/agent/`                            | `~/.pi/agent/`         |
| `ai/dot-claude/CLAUDE.md`                     | `~/.claude/CLAUDE.md`  |
| `ai/dot-codex/`                               | `~/.codex/`            |
| `ai/dot-gemini/`                              | `~/.gemini/`           |

---

## Make Targets

```bash
make setup    # backup conflicts, then stow all packages
make dry-run  # preview what stow would do (no changes)
make cleanup  # unstow; optionally restore last backup — requires explicit user consent
make status   # check symlink status of key files
```

> **⚠️ Never run `make cleanup` without explicit user approval.** The Makefile itself
> warns agents to stop and ask first.

---

## Adding or Changing Configs

### Editing an existing file
Just edit the file inside `~/dotfiles/` — the symlink means the change is live instantly.

### Adding a new agent skill (e.g. `foo`)
```bash
mkdir -p ~/dotfiles/ai/dot-agents/skills/foo
# create SKILL.md and any supporting files
ln -s ~/dotfiles/ai/dot-agents/skills/foo ~/.agents/skills/foo
```

### Adding a new top-level dotfile (e.g. `~/.foo`)
```bash
cp ~/.foo ~/dotfiles/shell/dot-foo
rm ~/.foo
cd ~/dotfiles && stow --dotfiles -d . -t "$HOME" shell
```

### Adding a new `~/.config/bar` directory
```bash
mkdir -p ~/dotfiles/config/dot-config/bar
# create files inside
cd ~/dotfiles && stow --dotfiles -d . -t "$HOME" config
```

### Re-stowing after changes
The `ai` package has some known pre-existing real dirs that can conflict with a full
re-stow. Use targeted stows or manual symlinking instead:
```bash
stow --dotfiles -d . -t "$HOME" shell   # safe
stow --dotfiles -d . -t "$HOME" config  # safe
# for ai: manually ln -s new dirs (see "Adding a new agent skill" above)
```

---

## Changelog

**Always update `CHANGELOG.md` before committing any meaningful change.**

- Day-to-day: add entries under `## [Unreleased]`.
- Releases: move `[Unreleased]` content into a new versioned section
  (`## [X.Y.Z] - YYYY-MM-DD`), tag, and push.

Versioning: **patch** for fixes/tweaks, **minor** for new skills/features,
**major** for breaking restructure.

---

## Git Workflow

```bash
cd ~/dotfiles
git checkout macos
git pull --rebase
# make changes …
git add -A
git commit -m "feat(ai): add foo skill"
git push origin macos
```

---

## What NOT to Do

- ❌ Edit files at `~/.zshrc`, `~/.config/nvim/`, etc. — always go through `~/dotfiles/`
- ❌ Run `make cleanup` without explicit user permission
- ❌ `rm -rf` a skill directory that is a symlink target — use `unlink` or `rm` without `-rf`
- ❌ Commit auth tokens, API keys, or session files (they are gitignored)
- ❌ Run `stow --dotfiles … ai` without checking for pre-existing real dirs first

---

## Skill Reference

The `dotfiles` agent skill contains the full, always-up-to-date reference:

```
~/.agents/skills/dotfiles/SKILL.md
# (source: ~/dotfiles/ai/dot-agents/skills/dotfiles/SKILL.md)
```

Read it whenever you are unsure about the layout or the correct way to make a change.
