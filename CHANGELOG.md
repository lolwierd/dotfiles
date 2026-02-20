# Changelog

All notable changes to this repository will be documented in this file.

## [1.0.0] - 2026-02-20

### Added
- Added a GNU Stow-based package layout with `shell/`, `config/`, and `ai/` packages for reproducible macOS setup.
- Added Make targets for setup and lifecycle management: `make setup`, `make dry-run`, `make cleanup`, and `make status`.
- Added safe setup behavior that backs up conflicting files before stowing and supports restore during cleanup.
- Added curated config sets for `zsh`, `git`, `nvim`, `tmux`, `ghostty`, and `btop` under stow-managed paths.
- Added an `ai/` package with config-only setups for Pi, Codex, Claude, Gemini, and reusable agent skills/extensions.

### Changed
- Migrated existing dotfiles to a stow-first repository structure focused on macOS.
- Updated documentation with first-time setup, dry-run, cleanup, and day-to-day update workflow.
- Improved `.gitignore` coverage for auth/runtime/state files across AI tooling to avoid committing secrets.
