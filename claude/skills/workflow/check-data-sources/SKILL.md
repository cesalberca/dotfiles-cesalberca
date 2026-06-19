---
name: check-data-sources
description: Probe each external data source or integration (API, DB, third-party service) against the current environment and report whether it runs live or falls back to fixtures, without leaking secrets. Use to verify credentials after an env change, or to explain why a feature is serving fixture data.
allowed-tools: Bash(bash:*) Bash(node:*) Read
---

# check-data-sources

Confirm which external sources are wired live and which fell back to fixtures, so a fallback is never
silent. The concrete probes are project-specific, so this skill documents the pattern rather than
shipping a fixed script. Pair it with the `wire-dependencies` skill, which decides live-vs-fixture
mode at the composition root.

## When to use

- After changing `.env` / credentials, to confirm each source authenticates.
- When a feature serves stale or fixture data and you need to know which source fell back.

Not for: full integration test suites (use the `validate` skill for that).

## Pattern

For each external source the project depends on:

1. Read its credentials / config from the environment (never hardcode, never print them).
2. Do a minimal, read-only probe (a cheap GET, a `SELECT 1`, a "list one record" call). No writes.
3. Classify the result: `live` (probe succeeded) or `fixture` (missing creds or probe failed and the
   code falls back).
4. Print one row per source:

```
source          mode      detail
--------------  --------  ----------------------------------
<name>          live      200 OK, 1 record
<name>          fixture   no API key set, using fixtures
```

## Rules

- Never print secrets, tokens, or full connection strings. Redact to a tail fragment if needed.
- Exit `0` even when some sources are on fixtures: fallback is a valid mode, not a failure.
- Emit a clear `WARN` line for any source that fell back, so a silent fixture is impossible to miss.
- Keep probes read-only and cheap; this is a health check, not a load test.

## Implementing it for a project

If the project has many sources, add a small script under `scripts/` that loops the sources and
applies the pattern above, then point this skill's Run section at it. Until then, perform the probes
by hand following the pattern.

## Adding a learning

Use the `remember` skill.
