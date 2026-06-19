---
name: remember
description: Capture a learning and persist it so future sessions benefit. Use when the user says "remember this", "from now on Y", "next time Z", or invokes /remember, or when a non-obvious convention, pitfall, or workaround surfaces mid-session that should outlive the conversation. Routes the learning to project CLAUDE.md, an existing skill, the user's auto-memory, or chains to create-skill when no fit exists.
allowed-tools: Bash(git:*) Bash(grep:*) Bash(rg:*) Read Edit Write
---

# remember

Capture a learning and route it to the one place future sessions will look.

## When to use

- User says "remember X" / "from now on Y" / "next time Z" / `/remember <fact>`.
- A non-obvious convention or pitfall surfaces mid-session.
- A workaround was needed that future runs should know about.

Not for: ambient session state ("we just did X"), one-off task instructions, or facts derivable from current code or git history. Push back politely when asked to save those.

## Workflow

### 1. Capture

Extract the learning as named fields:

```
LEARNING:
- What: <concise description of the pattern, solution, or pitfall>
- Why: <user's verbatim reason, do not paraphrase>
- Context: <when this applies: conditions, file types, scenarios>
- Example: <concrete code or command example, if applicable>
```

If the user did not supply a *Why*, ask once via `AskUserQuestion`. Do not invent one.

### 2. Route

Pick exactly one destination:

| Category | Destination | Criteria |
|----------|-------------|----------|
| Project guideline | project `CLAUDE.md` | General coding standards, style rules, banned APIs, cross-cutting invariants for this codebase |
| Skill-domain rule | an existing skill's `SKILL.md` | The learning refines that skill's workflow, frontmatter, domain, or adds an edge case |
| User preference | user auto-memory (see below) | About how the user works, not about this codebase |
| New reusable workflow | chain to the `create-skill` skill | A significant new capability with clear inputs and outputs |

Tie-breakers:
- Prefer a **skill over CLAUDE.md** when both fit (skills are scoped and discoverable).
- Prefer a **project skill over user memory** when the fact is about *this codebase*.
- One canonical home only. Never write the same fact in two places; cross-link instead.

User auto-memory lives at `~/.claude/projects/<project-slug>/memory/<type>_<topic>.md`, one fact per file with frontmatter (`name`, `description`, `metadata.type:` one of user/feedback/project/reference), plus a one-line pointer added to that directory's `MEMORY.md` index, e.g. `- [Title](file.md) - short hook`.

### 3. Propose

Show the exact change before applying:

```
## Proposed learning

Category: <category from the table>
Target: <file path + section heading>
Action: Add / Update / Create

### Change preview
<exact text to add or modify>

### Rationale
<one line on why this destination was chosen>
```

### 4. Apply

Only after the user confirms. Use `Edit` for existing files, `Write` only when creating a new memory file or chaining to `create-skill`. Skip approval only for trivial corrections (a typo in an existing bullet).

### 5. Report

One line: destination path + section + the bullet text (truncated to ~100 chars).

"Forget X" reverses the flow: grep the entry, propose its deletion, apply on approval.

## Validation

After applying:
1. `git diff <destination>` (or the file diff for user memory) shows only the bullet added, or only the bullet removed for "forget".
2. `rg "<distinctive phrase>"` over the destination scope matches exactly one location.
3. The confirmation line cites the same path and section the diff shows.

## Examples

### Example 1: Project guideline

**Input:** "Remember: always use `??` instead of `||` for nullish defaults, `||` swallows valid falsy values like 0 and ''."

```
LEARNING:
- What: Use ?? not || for default values
- Why: || swallows valid falsy values like 0 and ''
- Context: All code in this project
- Example: const value = input ?? defaultValue
```

**Route:** project `CLAUDE.md`, rules section. Append a bullet preserving the verbatim Why.

### Example 2: Skill-domain rule

**Input:** "Remember that the create-use-case skill should also generate the test file alongside the use case."

```
LEARNING:
- What: Generate the test file alongside a new use case
- Why: The TDD workflow needs the test before the implementation
- Context: Whenever create-use-case runs
- Example: CreateOrderUseCase.ts plus CreateOrderUseCase.test.ts
```

**Route:** the `create-use-case` skill's `SKILL.md`, workflow section.

### Example 3: User preference

**Input:** "Remember to always check 1Password is unlocked before committing."

```
LEARNING:
- What: Verify 1Password is unlocked before git commit
- Why: Signing fails silently if 1Password is locked, blocking the commit object write
- Context: Any commit attempt, the user signs all commits via 1Password
- Example: 1Password buffer error "failed to fill whole buffer"
```

**Route:** user auto-memory, `feedback` type, at `~/.claude/projects/<slug>/memory/feedback_signing.md`. Add a pointer to that dir's `MEMORY.md`.

## Traps

- **One canonical home.** Two destinations diverge over time. Cross-link instead of duplicating.
- **Do not paraphrase the *Why*.** The user's specificity is the value. "We got burned last quarter" stays verbatim.
- **Do not auto-create a skill for one-off facts.** If it applies once and never again, it is session state, not memory.
- **Honour the "what not to save" rules** from the global memory conventions (code patterns derivable from current state, git history, ephemeral state).
- **Always propose before applying.** Skip approval only for trivial typo fixes.

## Adding a learning

Apply this skill to itself: route a new rule about remembering into this skill's Route table.
