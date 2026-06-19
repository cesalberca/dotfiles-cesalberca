---
name: validate
description: Run a project's full validation suite (build, typecheck, test, lint, format) in dependency order via a single shipped script that auto-detects the toolchain. Fast-fails on the first break. Use before opening a PR or merging, after a non-trivial change (migration, refactor, dependency bump, rebase), or when another skill says to validate.
allowed-tools: Bash(bash:*) Bash(npm:*) Bash(pnpm:*) Bash(yarn:*) Bash(bun:*) Read
---

# validate

Ships one executable script at `scripts/validate.sh`. It locates the repo root via
`git rev-parse --show-toplevel`, auto-detects the package manager and which `package.json` scripts
exist, runs each validation step in dependency order, fast-fails on the first break, and prints a
coloured `> / ok / FAIL` line per step so the output is scannable.

## When to use

- After a non-trivial change (migration, refactor, dependency bump) before opening a PR.
- After resolving a merge conflict or rebasing.
- Before tagging a release.
- When another skill instructs you to validate.

Not for: tiny edits a pre-commit hook already covers.

## Run

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/validate.sh
```

Flags:
- `--all` runs every step and reports all failures at the end (default is fast-fail on first break).
- `--with-e2e` includes the end-to-end test step (off by default: slow, often needs a running app).
- `--no-frozen` allows lockfile churn on install (default is a frozen/`ci` install).

## How detection works

- **Package manager** by lockfile: `bun.lock*` -> bun, `pnpm-lock.yaml` -> pnpm, `yarn.lock` -> yarn,
  `package-lock.json` -> npm, else npm if a `package.json` exists.
- **Steps** by first matching `package.json` script; a missing step is skipped, not failed:

| # | Step | Script picked (first that exists) |
|---|------|-----------------------------------|
| 1 | install | `npm ci` or `<pm> install --frozen-lockfile` |
| 2 | build | `build` |
| 3 | typecheck | `typecheck`, `check:ci`, `compile`, `tsc` |
| 4 | test | `test:unit`, then `test` |
| 5 | e2e (only with `--with-e2e`) | `test:e2e`, `e2e` |
| 6 | lint | `lint:all`, `lint` |
| 7 | format | `format:check`, `fmt:check` |

## Output contract (skill-to-skill)

When another skill calls this:
- Exit `0` + the final `PASS - all validations green` line means **PASS**.
- Any non-zero exit means **FAIL**; the last `FAIL:` line names the step that broke.

Callers should act on `FAIL` by re-reading the offending step's config or files, not by blindly
re-running the same command.

## Adding or adjusting a step

Edit `scripts/validate.sh`: add another `run_script "<label>" <candidate scripts...>` line in the
correct dependency position, or extend a candidate list. Update the table above.
