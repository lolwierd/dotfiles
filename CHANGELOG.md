# Changelog

All notable changes to this repository will be documented in this file.

## [Unreleased]

### Added
- Added `manuscript` agent skill for treatise-style / codex-inspired visual design work with paper, serif typography, margin notes, and SDF-generated ornamental friezes.
- Added `design-deck` agent skill to `.agents` and `.codex` for visual option comparison workflows.
- Installed `pi-design-deck` package (git) for Pi — adds `/deck`, `/deck-plan`, and `/deck-discover` slash commands.
- Added `visual-explainer` skill to `.codex` (previously only in `.agents`).
- Added stronger ignore rules for sensitive/runtime files in public dotfiles, including `rig.json`, `.env*`, cert/key files, and expanded `.pi`/`.claude`/`.codex`/`.gemini` runtime paths.
- Added a Pi `oracle` extension inspired by Amp's built-in oracle tool for deep debugging, code review, architecture advice, and implementation planning with optional file attachments.
- Upgraded the Pi `oracle` extension to run as an isolated read-only subagent, allowing it to inspect the codebase with `read`/`grep`/`find`/`ls` before giving advice.
- Hardened the Pi `oracle` extension with proper cancellation handling, safer completion checks, stable file-error classification, explicit reporting of skipped file inputs, a subagent timeout, and stricter workspace-bound path validation.
- Added richer Pi `oracle` tool rendering with a compact/expanded subagent transcript view, visible tool-call timeline, inspected files list, configurable `oracle.defaultModel` and `oracle.defaultThinkingLevel` settings in Pi settings, skill discovery inside oracle subagent sessions, and stricter isolation/guardrails for oracle tool execution.

### Changed
- Updated `visual-explainer` skill from v0.1.1 to v0.2.0 — adds slide deck support (`generate-slides` prompt, `slide-patterns` reference, `slide-deck` template), updated CSS patterns and Mermaid libraries.
- Forced UTF-8 locale defaults in `zshenv` and tmux (`LANG` / `LC_CTYPE`) so remote tmux sessions render Unicode reliably.
- Updated `atelier-chrome` to show provider/model explicitly in the Pi chrome and improved thinking/status color treatment in the footer.
- Expanded the `search` skill to use both `ddgr` and `surf` for lightweight web search plus AI-assisted search.
- Updated shared Pi/Codex/Gemini defaults and extension dependencies to newer local preferences, model lists, and package metadata.
- Made shared shell config cross-platform (macOS + Linux) by guarding platform-specific PATH entries and optional tools (`brew`, `pbcopy`, `zoxide`, `direnv`).
- Updated setup docs/messages to include Ubuntu prerequisites (`stow`, `make`) while keeping one shared branch workflow.
- Made `dot-zshenv` and `dot-profile` robust when `~/.cargo/env` is absent.

## [1.1.0] - 2026-02-20

### Added
- Added `surf` browser automation skill: replaces the custom CDP scripts with the `surf` CLI for browser control, screenshots, form filling, network inspection, and AI assistant queries (ChatGPT, Gemini, Perplexity, Grok).
- Added `dotfiles` agent skill: explains the GNU Stow layout, `dot-` prefix convention, and the correct process for adding or editing any config file through dotfiles.
- Added `visual-explainer` agent skill: turns complex terminal output, architecture discussions, diffs, and plans into self-contained styled HTML pages opened in the browser.
- Added `design` agent skill for UI/visual design tasks (renamed from `frontend-design`).
- Added five Pi prompt templates from `visual-explainer`: `/generate-web-diagram`, `/diff-review`, `/plan-review`, `/project-recap`, and `/fact-check`.
- Added live session and turn duration indicators to the Pi `atelier-chrome` extension (footer and prompt header).
- Added explicit Pi `enabledModels` defaults for Codex, Claude Opus/Sonnet, and Gemini 3 Pro preview.
- Added Codex command allowlist rules for `swift test` and `qmd collection add` workflows.

### Changed
- Switched Pi default provider and model from `openai-codex / gpt-5.3-codex` to `anthropic / claude-sonnet-4-6`.
- Updated Codex trusted projects to include `~/Projects/personal/cb-manager`.
- Replaced footer queue status with session runtime in the Pi `atelier-chrome` status line.
- Normalised all agent skill symlinks to stow-managed relative symlinks; removed manually-created absolute symlinks.

### Removed
- Removed `web-browser` CDP skill and all associated Node scripts (`cdp.js`, `nav.js`, `screenshot.js`, etc.); browser automation now handled by `surf`.

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
