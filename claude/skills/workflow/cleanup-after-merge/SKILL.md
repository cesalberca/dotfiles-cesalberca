---
name: cleanup-after-merge
description: After a branch is merged, verify the merge, then (only after explicit confirmation) delete the local branch, remove its git worktree, and instruct the user to run /clear. Use when a PR/MR just merged and you want to clean up the local branch and worktree, or when the user says "cleanup after merge" or invokes /cleanup-after-merge.
allowed-tools: Bash(git:*) Bash(gh:*) AskUserQuestion Read
---

# cleanup-after-merge

Tidy up after a branch has landed: confirm it really merged, then remove the local branch and its
worktree. Every deletion is gated behind an explicit user confirmation.

## When to use

- A PR or MR for the current branch just merged and you want to clean up locally.
- The user says "clean up after merge" / "delete this merged branch" / `/cleanup-after-merge`.

Not for: deleting unmerged or work-in-progress branches, or pruning many branches at once.

## Workflow

### 1. Detect context

- Current branch: `git rev-parse --abbrev-ref HEAD`.
- Branch tip SHA (record it before anything else): `git rev-parse HEAD`.
- Default branch: `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the `origin/`), falling
  back to `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`, then to `main`/`master`.
- Worktree: `git worktree list --porcelain` to find whether this branch is checked out in a separate
  worktree, and its path.

### 2. Guard (abort early)

- If the current branch IS the default branch: stop. There is nothing to clean up.
- If the working tree is dirty (`git status --porcelain` is non-empty): stop and tell the user to
  commit or stash first.

### 3. Verify merged (primary)

```bash
gh pr view <branch> --json state,mergedAt -q '{state: .state, mergedAt: .mergedAt}'
```

Treat as merged iff `state == MERGED` (or `mergedAt` is non-null).

### 4. Verify merged (fallback, if gh is unavailable or no PR is found)

```bash
git fetch origin
git branch --merged origin/<default>      # does it list <branch>?
git cherry origin/<default> <branch>      # all lines start with "-" => every commit is upstream
```

`git cherry` covers squash and rebase merges, where the merge ancestry is lost and
`git branch --merged` looks falsely "unmerged".

### 5. Show status

Print a short summary: current branch, default branch, tip SHA, the merge result and which method
confirmed it, the worktree path (if any), and the exact deletions about to happen. If the merge was
NOT confirmed, say so explicitly.

### 6. Confirm (blocking, mandatory)

Ask via `AskUserQuestion`: "Delete branch `<branch>` and remove worktree `<path>`?" with Yes / No.
**Never proceed without an explicit Yes.** This gate is required even when the merge is confirmed.

### 7. Delete (only after Yes)

- If on the branch and not in a separate worktree: `git switch <default>` first (you cannot delete
  the checked-out branch).
- If a worktree exists for the branch: `git worktree remove <path>` (use `--force` only when the user
  confirmed and the worktree is clean).
- Delete the branch: `git branch -d <branch>` (safe: refuses if not merged). Escalate to
  `git branch -D` only when steps 3/4 confirmed the merge but `-d` still refuses (squash/rebase), AND
  the user's confirmation explicitly covered force-delete.
- Leave the remote branch alone unless the user asks (`git push origin --delete <branch>`); hosts
  usually delete it automatically on merge.

### 8. Clear the conversation

A skill cannot clear the conversation itself. End by telling the user:
"Cleanup done. Run `/clear` to reset the conversation."

## Safety

- Always confirm before any deletion (branch or worktree). No auto-yes, no exceptions.
- Never delete the default branch.
- Never delete a branch that is not verified merged unless the user explicitly overrides after the
  warning.
- Prefer `git branch -d` over `-D`; only force-delete on confirmed-merge plus explicit opt-in.
- Never `git worktree remove --force` without confirmation and a clean tree.
- Abort on a dirty working tree.

## Adding a learning

Use the `remember` skill.
