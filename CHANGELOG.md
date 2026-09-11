# Changelog

All notable changes to this repository will be documented in this file.

## [Unreleased]

### Removed
- Removed Langfuse tracing and SigNoz integrations from Pi, OpenCode, Claude Code, and Codex, including their MCP servers, plugins, environment variables, and local launchers.
- Removed the SigNoz MCP server (`http://127.0.0.1:8000/mcp`) from Pi's `ai/dot-pi/agent/mcp-servers.json`.

### Fixed
- `make setup` never worked on macOS. The Makefile uses `.ONESHELL`, which needs GNU Make 3.82+, and macOS ships 3.81 — every recipe line ran in its own shell and the multi-line recipes died with `syntax error: unexpected end of file`. The Makefile now asserts the feature is present and says to use `gmake`; `make` is in the Brewfile and the README uses `gmake` throughout.

### Added
- Added a `Brewfile` covering the tools `shell/` and `config/` actually reference by name, plus the language toolchains in daily use. Personal/media packages are deliberately left out so a work machine stays lean. Installed with `make brew`.
- Added `editors/vscode/` (`settings.json`, `keybindings.json`, `extensions.txt`) and `editors/iterm2/` (exported prefs plist, `Default.json`, `flexoki-light.itermcolors`), with `make vscode` and `make iterm2` targets. These live outside the stow packages because VS Code and iTerm2 keep config under `~/Library`, which stow's `--dotfiles` mode cannot target. The committed iTerm2 plist has window frames, `NoSync*` UI state, and update-checker timestamps stripped.
- Documented a new-machine bootstrap sequence and the editor targets in the README.

### Changed
- Made `shell/dot-zshrc` and `shell/dot-profile` machine-portable: installer-appended `/Users/lolwierd/...` absolute paths now go through `$HOME` / `path_prepend_if_dir`, the duplicate opencode/bun PATH exports were dropped, and the Google Cloud SDK include probes `~/google-cloud-sdk` then `~/Downloads/google-cloud-sdk` instead of hardcoding one machine's Downloads folder.
- Resolved `nvm.sh` at shell start instead of assuming `$NVM_DIR/nvm.sh`: Homebrew keeps it in the Cellar, so the lazy `node`/`npm`/`pnpm` wrappers silently loaded nothing on a brew-installed nvm.
- Added Homebrew's keg-only `rustup` bin directory to PATH on macOS, since `rustc`/`cargo` are not symlinked into `/opt/homebrew/bin`.
- Guarded the `powerlevel10k.zsh-theme` source in `shell/dot-zshrc`: it was unconditional, so a machine without the `~/powerlevel10k` clone got an error on every shell start. It now falls back to the Homebrew formula and stays silent if neither is present.
- Rebound `^f` to a new `cproj` picker (fzf over `~/Projects`) in place of `tmux-sessionizer`, and pointed `g`/`gy` at `agy`.
- Unset inherited Langfuse tracing variables in `shell/dot-zshenv` so stale exports from older sessions do not leak into new shells.
- Updated Codex to `gpt-5.6-sol` at medium reasoning with `guardian_subagent` approvals, `workspace-write` sandbox, and `on-request` approvals; dropped the blanket `/` trust entry and the blanket `python3` allow rule.
- Updated Pi defaults to the `hy3` model on the `introspective-paper` theme, re-enabled compaction, pinned `pi-web-access@0.14.0`, and added the codex-fast-mode and openai-server-compaction packages.

### Changed
- Disabled the Amp git commit co-author trailer (`amp.git.commit.coauthor.enabled: false`) in `~/.config/amp/settings.json`, now tracked in dotfiles and symlinked into place.

### Added
- Added a Troubleshooting section to the README covering what to do when stow reports a conflict (what a conflict looks like, why it happens, and resolution steps: back up, remove, re-run stow).
- Documented `make cleanup` target in README with full step-by-step description, restoration behavior, and caveats.
- Added Pi `terminal-title` extension: sets the terminal title to a status glyph (braille spinner while working, then check/cross) plus the session name or cwd basename.
- Added aerospace tiling WM config (`config/dot-config/aerospace/aerospace.toml`) with i3-style stacked (accordion) default layout, vim focus keys, layout cycling via `alt-space`, launch terminal via `alt-enter`, and service mode for utilities.

### Changed
- Cleaned up obsolete Codex feature flags and unsafe blanket trust/approval rules, enabled Apps and local thread-store compression, and kept memory generation disabled.
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
- Replaced the built-in `web.ts` extension (`websearch`/`webfetch` tools) with `pi-web-access` (nicobailon/pi-web-access), a full-featured web search and content extraction package with Exa, OpenAI, Brave, Tavily, Gemini, Perplexity, and Parallel providers. The old extension is disabled at `ai/dot-pi/agent/extensions/web.ts.disabled`.
- Added `ai/dot-pi/web-search.json` config symlinked to `~/.pi/web-search.json` for pi-web-access. The `EXA_API_KEY` env var provides credentials; no secrets committed to dotfiles.
- Switched Codex default model from `gpt-5.3-codex` to `gpt-5.4-mini` with `medium` reasoning effort and updated the bundled computer-use plugin path.
- Renamed the Excloud CLI skill from `exc-cli-resource-manager` to `excloud-cli` across `.agents/skills/` and `.codex/skills/`. The SKILL.md was rewritten for public consumption (discovery-first guidance, auth precedence, safety rails, verified output-format buckets, real error strings) and now lives upstream at https://git.excloud.in/excloud-in/excloud-skills — installable with `npx skills add https://git.excloud.in/excloud-in/excloud-skills.git`. The per-agent `agents/openai.yaml` display name was updated to match.

### Added
- Added a read-only SigNoz MCP launcher for Codex and Claude Code, with its API key loaded from macOS Keychain at runtime.
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
