---
name: create-skill
description: Scaffold a new skill under .claude/skills/<name>/SKILL.md following the Agent Skills specification (agentskills.io). Use when the user asks to "create a skill", "add a skill", invokes /create-skill, or when the remember skill chains here because no existing skill fits.
allowed-tools: Bash(bash:*) Bash(chmod:*) Bash(mkdir:*) Read Write
---

# create-skill

## Layout

```
.claude/skills/<name>/
  SKILL.md            # required
  scripts/            # optional: executable code
  references/         # optional: extra docs, loaded on demand
  assets/             # optional: templates, schemas, images
```

`<name>` must equal the frontmatter `name:` and the parent directory. Lowercase, hyphens only, 1-64 chars, no leading, trailing, or consecutive hyphens.

## Frontmatter

```yaml
---
name: <kebab-name>                 # required
description: <max 1024 chars>      # required: what + when. Include trigger phrases.
allowed-tools: Bash(git:*) Read    # optional, space-separated, narrows tool access
license: UNLICENSED                # optional
compatibility: Requires <tool>     # optional, only if real env constraints exist
metadata:                          # optional
  author: <name>
---
```

The `description` is the single most important field. The Skill tool uses it to decide whether to surface this skill. Name the verbs ("scaffold", "migrate"), the targets, and what *not* to use it for.

## Body sections (recommended)

1. `# <name>` (H1 = skill name).
2. `## When to use`: triggers plus "Not for" exclusions.
3. `## Workflow`: checkbox list for multi-step tasks, prose for judgment calls.
4. `## Validation`: how the agent confirms its own work (tests, lint, build). Feedback loops are essential.
5. `## Example`: concrete input to concrete output. Not abstract.
6. `## Traps`: `rule -> symptom -> fix`, one line each.
7. `## Adding a learning`: point at the `remember` skill.

Move verbose detail into `references/<topic>.md` and link from the body. Agents load references on demand (progressive disclosure).

## Degrees of freedom

| Freedom | When | Format |
|---------|------|--------|
| High | Many valid approaches, context-dependent | Prose guideline |
| Medium | Preferred pattern, some variation OK | Pseudocode + parameters |
| Low | Fragile, must be consistent | Locked script under `scripts/` |

Match the format to the task. Do not lock down what should be a judgment call, and do not leave fragile steps open-ended.

## Common patterns

Reach for these when a skill matches the shape. They are optional, not mandatory.

### Structured capture block

For skills that ingest a user-supplied fact, decision, or finding before acting on it, capture it as a fenced block with named fields. This forces the agent to extract the parts that matter and surfaces what is missing. Example shape (from the `remember` skill):

```
LEARNING:
- What: <concise description>
- Why: <user's verbatim reason, do not paraphrase>
- Context: <when this applies>
- Example: <concrete example if applicable>
```

If a required field is missing (typically *Why*), ask the user once via `AskUserQuestion`. Do not invent values.

### Propose-before-apply

For skills that edit shared files (CLAUDE.md, other skills, configuration), insert an explicit `Propose` step between routing and applying. Block on user approval. The proposal shows: target file + section, action (Add / Update / Create), exact text to write, and a one-line rationale.

Skip approval only for trivial corrections (typos in existing bullets), and only when the skill's own Traps say so.

## Workflow

- [ ] 1. Confirm name (kebab-case, no `-skill` suffix). Check it does not collide with an existing skill.
- [ ] 2. Pick shape: doc-only, with-scripts (`scripts/`), or meta (operates on other skills).
- [ ] 3. `mkdir -p .claude/skills/<name>`. Add `scripts/` or `references/` if used.
- [ ] 4. Write `SKILL.md`. Aim under ~60 lines. Quote reference files instead of inlining templates.
- [ ] 5. For scripts: `set -euo pipefail`, locate repo root via `git rev-parse --show-toplevel`, then `chmod +x`.
- [ ] 6. Run the Validation checks below before considering the skill done.

## Validation

1. `name:` matches the directory name exactly.
2. `description:` is under 1024 chars and names triggers plus exclusions.
3. `SKILL.md` body under 500 lines (spec guideline, not an enforced limit).
4. Scripts are executable and exit 0 on the happy path.
5. Fresh-session smoke test: the skill is listed, `/<name>` loads, and a natural-language trigger surfaces it.

## Example

**Input:** "Create a skill that runs `gh pr view` and summarises the PR."

**Output:** `.claude/skills/summarise-pr/SKILL.md`

```yaml
---
name: summarise-pr
description: Summarise a GitHub PR by running `gh pr view <id>` and producing a short summary with bullets for what changed, what is risky, and what is left. Use when the user says "summarise PR <id>" or invokes /summarise-pr.
allowed-tools: Bash(gh:*)
---
```

Body has `## Workflow` (3-step checklist: fetch PR, parse, render), `## Example` (a real PR fixture to its expected summary), and `## Traps` (large diffs need pagination).

## Traps

- **Vague description, no auto-trigger.** "Helps with PDFs" fails. "Extracts text from PDFs, fills forms, merges files. Use when handling PDFs." succeeds.
- **`chmod +x` missing**, scripts silently fail on first run.
- **Body over 500 lines**, bloated context and slower routing, since the whole file loads on activation. Move detail to `references/`.
- **No "Not for" section**, the skill swallows requests it should not.
- **`name:` mismatch with the directory**, validation fails per spec.

## Placement in this dotfiles repo

Skills here are organized by category folder (`architecture/`, `workflow/`, `meta/`), but `install.sh` flat-links each skill into `~/.claude/skills/<name>` by its directory basename. So put a new skill under the right category folder and keep its directory name **globally unique across all categories**, otherwise install aborts on the collision.

## Adding a learning

Use the `remember` skill.
