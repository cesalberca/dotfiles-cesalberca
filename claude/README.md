# claude

Claude Code config, symlinked into `~/.claude` on `dotfiles install`.

## What gets linked

| Source | Target |
|---|---|
| `settings.json` | `~/.claude/settings.json` |
| `hooks/no-em-dash.sh` | `~/.claude/hooks/no-em-dash.sh` |
| `hooks/no-em-dash-files.sh` | `~/.claude/hooks/no-em-dash-files.sh` |
| `hooks/no-arrows.sh` | `~/.claude/hooks/no-arrows.sh` |
| `hooks/no-arrows-files.sh` | `~/.claude/hooks/no-arrows-files.sh` |

Linking is done by `install.sh`, not the framework's `*.symlink` convention,
because the framework only links top-level files into `$HOME` and these targets
are nested under `~/.claude/`. Existing real files are backed up to
`*.bak.<timestamp>` before being replaced; re-running is idempotent.

## Hooks

- **`no-em-dash.sh`** (`UserPromptSubmit`) — injects a style rule every turn so
  the model never emits em (`—`) or en (`–`) dashes in output or generated files.
  stdout from a `UserPromptSubmit` hook is added to the turn's context, so the
  rule is re-asserted on every prompt.
- **`no-em-dash-files.sh`** (`PreToolUse`, `Write|Edit|MultiEdit`) —
  deterministic backstop: rewrites em/en dashes to a regular hyphen in content
  headed to disk, via `updatedInput`. Touches only new content
  (`content` / `new_string`), never `old_string`, so edits keep matching the
  file. Requires `jq`; no-ops if absent. Does not force-allow the write.
- **`no-arrows.sh`** (`UserPromptSubmit`) — same as `no-em-dash.sh` but for
  Unicode arrow glyphs (`→ ← ⇒ ↔` ...) in public-facing text: commit messages,
  PR titles/bodies, issues, release notes, docs, UI copy. Steers toward words
  or ASCII (`->`, `=>`). This is the layer that covers commit/PR text, since
  that is generated, not written through `Write`/`Edit`.
- **`no-arrows-files.sh`** (`PreToolUse`, `Write|Edit|MultiEdit`) —
  deterministic backstop: rewrites arrow glyphs to ASCII in file content
  (`→`→`->`, `⇒`→`=>`, `↔`→`<->`, `←`→`<-`). Same scope rules as
  `no-em-dash-files.sh`.

The `PreToolUse` / Bash entry in `settings.json` points at `rtk-rewrite.sh`,
which is installed and managed by `rtk` itself, not by this topic.
