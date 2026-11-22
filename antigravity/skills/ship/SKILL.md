---
name: ship
description: >-
  Commit any uncommitted workspace changes (following repo validation and
  commit rules), push unpushed commits to the remote tracking branch, and
  report a concise summary of everything pushed. Use when the user invokes
  /ship or asks to commit and push.
---

# Ship (Commit & Push)

Invoking `/ship` counts as explicit user approval to push to the remote.

## Steps

1. **Inspect state**: In each active workspace repository, check
   `git status --short` and unpushed commits (`git log @{u}..HEAD --oneline`,
   falling back cleanly if no upstream is set yet).
2. **Commit any uncommitted work**:
   - If there are uncommitted changes, first ensure any repo validation checks
     defined in `AGENTS.md` have passed since the last edit.
   - Stage only intended files (no temporary files, build/export artifacts, or
     secrets) and split into clean, well-scoped commits following repo rules
     (e.g., per-model commit isolation, matching `git log -n 5 --oneline`
     style).
3. **Push safely**:
   - Push to the current branch's remote (`git push`). Never force-push or
     rewrite shared history unless explicitly instructed.
   - If the push is rejected (e.g., non-fast-forward) or no upstream is
     configured, stop and report the exact state before taking further action.
4. **Summarize**: Report a concise summary of what was pushed:
   - Repository and target branch/remote
   - Each pushed commit (short hash, subject line, and files changed)
