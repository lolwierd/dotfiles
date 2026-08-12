# Dependabot Fixes Summary

**Branch:** `foreman/wk-0001-1-dependabot-fixes`
**Target:** `ai/dot-pi/agent/extensions/package-lock.json`

## Packages Patched

All 8 vulnerable packages were successfully patched. All semver ranges allowed the patched versions.

| Package | Old Version | New Version | Required Minimum | Parent (range) |
|---|---|---|---|---|
| `ip-address` | 10.1.0 | 10.3.1 | >= 10.3.1 | socks (`^10.0.1`) |
| `basic-ftp` | 5.3.0 | 5.3.1 | >= 5.3.1 | get-uri (`^5.0.2`) |
| `fast-xml-builder` | 1.1.5 | 1.1.7 | >= 1.1.7 | fast-xml-parser (`^1.1.5`) |
| `@protobufjs/utf8` | 1.1.0 | 1.1.1 | >= 1.1.1 | protobufjs (`^1.1.0`) |
| `protobufjs` | 7.5.5 | 7.6.5 | >= 7.6.5 | @google/genai (`^7.5.4`) |
| `ws` | 8.20.0 | 8.21.0 | >= 8.21.0 | @google/genai, @mistralai/mistralai (`^8.18.0`) |
| `fast-uri` | 3.1.0 | 3.1.5 | >= 3.1.5 | ajv (`^3.0.1`) |
| `undici` | 7.25.0 | 7.29.0 | >= 7.29.0 | @mariozechner/pi-ai (`^7.19.1`), cheerio (`^7.19.0`) |

### Transitive Dependency Updates

The following transitive dependencies were updated to maintain lockfile consistency with the new `protobufjs@7.6.5` and `@protobufjs/fetch@1.1.1` versions:

| Package | Old Version | New Version | Reason |
|---|---|---|---|
| `@protobufjs/codegen` | 2.0.4 | 2.0.5 | Required by protobufjs 7.6.5 (`^2.0.5`) |
| `@protobufjs/eventemitter` | 1.1.0 | 1.1.1 | Required by protobufjs 7.6.5 (`^1.1.1`) |
| `@protobufjs/fetch` | 1.1.0 | 1.1.1 | Required by protobufjs 7.6.5 (`^1.1.1`) |

## Packages NOT Patched

None. All 8 vulnerable packages were compatible with their parent semver ranges and were successfully updated.

## Method

Direct lockfile editing with integrity hashes verified against the npm registry. The `package.json` references `@earendil-works/pi-*` while the lockfile references `@mariozechner/pi-*`, so `npm install` could not be used — all edits were made directly to the JSON structure.
