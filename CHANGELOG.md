# Changelog

All notable changes to this repository will be documented in this file.

## [Unreleased]

### Changed
- Switched Pi extension imports and dependencies from `@mariozechner/*` to `@earendil-works/*` packages.
- Updated Pi defaults to `openai-codex/gpt-5.5`, disabled compaction, and moved the oracle fallback to available configured models instead of API-key probing.
- Updated Pi `webfetch` / `websearch` tool rendering to show the requested URL or search query directly in the tool block.
- Updated Codex defaults for `gpt-5.5`, plugin paths, trusted projects, disabled memories/chronicle, and GitHub command allow rules.
- Updated Neovim config for neo-tree v4 compatibility, Scala Metals support, clipboard behavior, LSP formatting ownership, and current plugin lock updates.
- Documented Excloud CLI lifecycle `--wait` support for compute and volume commands.
- Added shell conveniences for Bun and Excloud Git SSH URL rewrites.
- Updated Pi `atelier-chrome` extension to track cache read/write tokens and show live in-flight usage during turns via `message_update` events.
- Moved the working directory (`cwd`) display from the Pi chrome footer into the prompt editor header for cleaner layout.
- Simplified the Pi chrome footer to a single line combining live session stats with provider/model status.
- Switched Codex default model from `gpt-5.3-codex` to `gpt-5.4-mini` with `medium` reasoning effort and updated the bundled computer-use plugin path.
- Renamed the Excloud CLI skill from `exc-cli-resource-manager` to `excloud-cli` across `.agents/skills/` and `.codex/skills/`. The SKILL.md was rewritten for public consumption (discovery-first guidance, auth precedence, safety rails, verified output-format buckets, real error strings) and now lives upstream at https://git.excloud.in/excloud-in/excloud-skills — installable with `npx skills add https://git.excloud.in/excloud-in/excloud-skills.git`. The per-agent `agents/openai.yaml` display name was updated to match.

### Added
- Added Pi `excloud-params` extension to dotfiles — applies custom sampling parameters (temperature 0.6, top_p 0.95, etc.) for Excloud-hosted models (`:excloud`).
- Added Pi `webfetch` and `websearch` extension tools, with OpenCode-style URL fetching plus Exa-backed live web search.
- Added a dotfiles-managed Pi skill copy at `ai/dot-pi/agent/skills/design-deck/`, synced from the installed `pi-design-deck` upstream package.
- Added `exc-cli-resource-manager` to dotfiles-managed agent skills so Excloud CLI guidance is versioned and syncable.
- Added `cloudflare-deploy` and `frontend-skill` to dotfiles-managed Codex skills so local Codex-only skills are backed up in dotfiles.
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
- Updated `exc-cli-resource-manager` with Kubernetes CLI guidance (`exc k8s health`, `exc k8s cluster create`, `exc k8s bootstrap controlplane get`) plus the `make refresh-k8sapi-schema` maintenance flow for regenerating CLI support from `k8sapi`.
- Expanded `exc-cli-resource-manager` with runtime `BASE_URL` override guidance for `exc k8s` commands plus `exc k8s cluster create -o <path>` kubeconfig file output, and synced the same skill into the Codex skill tree.
- Updated `visual-explainer` skill from v0.1.1 to v0.2.0 — adds slide deck support (`generate-slides` prompt, `slide-patterns` reference, `slide-deck` template), updated CSS patterns and Mermaid libraries.
- Synced live agent skills with dotfiles by restoring the missing `search` skill link and normalizing `exc-cli-resource-manager` to dotfiles-managed files.
- Moved `design-deck` ownership out of shared `.agents` / `.codex` skills and into Pi-only dotfiles state, with live sync at `~/.pi/agent/skills/design-deck`.
- Documented the current Codex skill-sync caveat: keep `~/.codex/skills` as real directories because symlink-based discovery has been flaky, while `~/.agents/skills` symlinks are working.
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
