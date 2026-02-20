---
name: memory
description: "Persistent memory across sessions using qmd. Use this skill to remember things about the user, recall past decisions, store learned preferences, and avoid repeating mistakes. Memory survives across sessions and is searchable."
---

# Memory

Persistent, searchable memory that survives across sessions. Powered by [qmd](https://github.com/tobi/qmd) — a local search engine backed by SQLite.

Memories are stored as markdown files in `~/.pi/agent/memory/` and indexed by qmd for fast keyword and semantic search.

## When to Use

### Automatically recall memory BEFORE:
- Starting any significant task (design, architecture, implementation) — search for relevant past decisions, preferences, or patterns
- Making choices about tools, libraries, style, or approach — the user may have expressed preferences before
- Working on a project you've touched before — search for project-specific context

### Automatically save memory AFTER:
- Learning something about the user (preferences, taste, opinions, how they like things done)
- Making a significant design or architecture decision (what was chosen and WHY)
- Discovering a mistake or anti-pattern to avoid next time
- Completing a project — log what was built, key decisions, and what worked/didn't
- The user corrects you or expresses a preference — that's high-signal, always save it
- Learning about the user's environment, tools, workflow, or constraints

### Save memory WHEN the user:
- Says "remember this" or similar
- Expresses a strong opinion or preference
- Corrects a mistake or gives feedback on output quality

## How It Works

Memory files live in: `~/.pi/agent/memory/`
qmd collection name: `memory`

Each memory is a markdown file with a descriptive filename. Files are organized by topic/category using subdirectories.

## Commands

### Search memory (RECALL)

Before starting work, search for relevant context:

```bash
# Keyword search — fast (<1s), use this as your default
qmd search "user preference dark mode" -c memory -n 10

# Semantic search — slower (~20s) but finds conceptually related things even without keyword matches
# Use only when keyword search returns nothing useful
qmd vsearch "what fonts has the user liked before" -c memory -n 10

# Get full content of a specific memory file
qmd get "memory/some-file.md" --full
```

**Always use `-c memory`** to scope searches to the memory collection.

**⚠️ Do NOT use `qmd query`** — it runs a local LLM for query expansion and hangs on this machine. Use `search` (keyword) or `vsearch` (semantic) instead.

### Save memory (STORE)

Write a markdown file, then update the index:

```bash
# 1. Write the memory file
cat > ~/.pi/agent/memory/CATEGORY/descriptive-name.md << 'MEMORY'
# Title

Content here...
MEMORY

# 2. Update the qmd index so it's searchable
qmd update
```

After saving several memories or when doing important saves, also regenerate embeddings for semantic search:

```bash
qmd embed
```

### List all memories

```bash
qmd ls memory
```

### Delete a memory

```bash
rm ~/.pi/agent/memory/path/to/file.md
qmd update
```

## Memory File Format

Each memory file should be clear, concise, and self-contained:

```markdown
# Short descriptive title

**Date:** YYYY-MM-DD
**Context:** What prompted this memory (optional but helpful)

The actual content. Be specific and concise. Include:
- What was learned/decided
- Why (the reasoning matters for future decisions)
- Any relevant details that would help future recall
```

## Directory Structure

Organize memories into categories. Create subdirectories as needed:

```
~/.pi/agent/memory/
├── user/                    # About the user
│   ├── preferences.md       # General preferences
│   ├── design-taste.md      # Design/aesthetic preferences
│   └── workflow.md          # How they like to work
├── decisions/               # Significant decisions made
│   ├── project-name/        # Per-project decisions
│   │   ├── architecture.md
│   │   └── design.md
│   └── ...
├── projects/                # Project logs and context
│   ├── project-name.md      # What was built, key details
│   └── ...
├── patterns/                # Learned patterns (good and bad)
│   ├── what-works.md
│   └── mistakes-to-avoid.md
├── tools/                   # Tool preferences, setup details
│   └── ...
└── ...                      # Create new categories as needed
```

## Rules

1. **Search before you build.** Before starting any significant work, run at least one search to check for relevant memories. This takes 2 seconds and prevents repeating past mistakes.
2. **Save after you learn.** Whenever you learn something worth remembering, save it immediately. Don't wait until the end of the session.
3. **Be specific in filenames.** `design-taste.md` is better than `notes.md`. `2026-02-19-website-rebuild.md` is better than `website.md`.
4. **Include the WHY.** When saving decisions, always include the reasoning. "Used Playfair Display" is useless. "Used Playfair Display because the project needed a confident editorial voice for a personal portfolio" is useful.
5. **Update, don't duplicate.** If a memory file already exists for a topic, update it rather than creating a new one. Use `qmd get` to read the existing file first.
6. **Keep memories concise.** Each file should be a focused note, not a novel. Long rambling memories are hard to search and recall.
7. **Always run `qmd update` after writing.** Memories aren't searchable until indexed.
