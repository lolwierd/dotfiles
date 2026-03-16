---
name: search
description: Search the web using DuckDuckGo (via ddgr) or AI search engines (via surf). Use this to find information, documentation, or answers to questions.
---

# Web Search

Use this skill to find information online. Start with `ddgr` for simple queries. If results are insufficient or you need a synthesized answer, pivot to AI search via `surf`.

## 1. Basic Search (ddgr)

Fast, lightweight search for simple lookups or finding documentation URLs.

```bash
uvx ddgr --json --noprompt -n 5 "your search query"
```

**Details**:
- Returns JSON list of `title`, `url`, and `abstract`.
- `-n 5`: Limits to 5 results.

## 2. Advanced AI Search (surf)

Use this when `ddgr` is insufficient, or when you need a complex answer, code examples, or research.
**Prerequisite**: You must be logged into the respective service in your local Chrome browser.

**Preference Order**:
1.  **Gemini** (Fast, good for general info):
    ```bash
    surf gemini "your query"
    ```
2.  **Perplexity** (Best for deep research/citations):
    ```bash
    surf perplexity "your query"
    ```
3.  **ChatGPT** (Fallback):
    ```bash
    surf chatgpt "your query"
    ```

**Note**: These commands use the browser's session. If they fail with "login required", please ask the user to log in to the service in Chrome.

## Reading Pages

If you have a URL from `ddgr` and need to read the content:

```bash
curl -L "https://example.com" | head -n 100
# OR if you need a rendered view:
surf navigate "https://example.com"
surf page.text
```
