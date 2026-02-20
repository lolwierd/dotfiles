---
name: search
description: Search the web using DuckDuckGo (via ddgr). Use this to find information, documentation, or answers to questions.
---

# Web Search (ddgr)

Use this skill to perform web searches when you need to find information online.

## Usage

To search DuckDuckGo, run this command via the `bash` tool:

```bash
uvx ddgr --json --noprompt -n 5 "your search query"
```

## Details

- **Flags**:
  - `--json`: Returns results in JSON format (easier for you to parse).
  - `--noprompt`: Required for non-interactive execution.
  - `-n <number>`: Limit results (recommend 3-5).

- **Output**:
  - You will receive a JSON list of results containing `title`, `url`, and `abstract`.
  - Use this information to answer the user's question or refine your search.

## Reading Pages

If the abstract isn't enough, try reading the full page content using `curl` (raw HTML) or a text browser if available:

```bash
curl -L "https://example.com" | head -n 100
```
