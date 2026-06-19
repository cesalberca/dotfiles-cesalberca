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
| `skills/<category>/<skill>/` | `~/.claude/skills/<skill>/` |

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

## Skills

Reusable, project-agnostic [Agent Skills](https://agentskills.io) live under
`skills/`, organised by category for readability:

```
skills/
  architecture/   # clean-architecture / DDD slice builders
  workflow/       # dev-process actions
  meta/           # skills about skills and memory
```

Claude discovers personal skills only FLAT at `~/.claude/skills/<skill>/`, so
`install.sh` symlinks each skill into `~/.claude/skills/` by its directory
basename, ignoring the category folder. Therefore **every skill directory name
must be globally unique across categories** or install aborts with an error.
Any shipped `scripts/*.sh` is made executable on install.

| Category | Skill | What it does |
|---|---|---|
| architecture | `architecture-guardrails` | Enforce layer/module boundaries via package `exports` + a dependency linter. |
| architecture | `create-domain-model` | Author a pure, framework-free domain model (value objects, entities, services). |
| architecture | `create-repository-contract` | Define a domain-owned repository interface. |
| architecture | `create-use-case` | Author an application use case returning a plain serializable DTO. |
| architecture | `create-infrastructure` | Implement a repository with a real adapter + an in-memory adapter. |
| architecture | `create-delivery` | Build the delivery/UI layer that calls a use case via DI. |
| architecture | `wire-dependencies` | Wire a feature into the DI container / composition root. |
| architecture | `tdd-slice` | Drive a feature test-first across domain, use-case, integration, E2E. |
| workflow | `validate` | Auto-detect the toolchain and run build/typecheck/test/lint/format. Ships `scripts/validate.sh`. |
| workflow | `cleanup-after-merge` | After a merge, verify it, then (on confirm) delete the branch + worktree and prompt `/clear`. |
| workflow | `check-data-sources` | Probe each external integration and report live vs fixture, without leaking secrets. |
| meta | `create-skill` | Scaffold a new skill per the Agent Skills spec. |
| meta | `remember` | Capture a learning and route it to CLAUDE.md, a skill, user memory, or `create-skill`. |

`remember` and `create-skill` form the meta loop: `remember` chains to
`create-skill` when a learning needs a brand new skill.
