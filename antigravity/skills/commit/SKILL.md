---
name: commit
description: >-
  Review uncommitted changes across active workspace repositories, run any
  required repo validation checks, create clean local git commits without
  pushing, and report a concise commit summary. Use when the user invokes
  /commit or asks to commit changes locally.
---

# Commit (Local Only)

Create clean, well-scoped local git commit(s) for the current work **without
pushing** to any remote.

## Steps

1. **Inspect state**: Run `git status --short` and review `git diff` in each
   active workspace repository that has uncommitted changes.
2. **Validate before committing**: If the repo's `AGENTS.md` defines validation
   commands (e.g. typecheck, build, tests) and they have not already been run
   since the last edit, run them and ensure they pass before committing.
3. **Plan clean commits**:
   - Respect any repo-specific commit rules (e.g., per-model commit isolation
     or keeping rule/config edits in separate commits).
   - Stage only intended files—exclude untracked temporary files, build
     outputs, exported artifacts, or secrets.
   - Write concise, clear commit messages matching the repository's existing
     style (`git log -n 5 --oneline`).
4. **Commit locally**: Create the commit(s). Do **not** run `git push`.
5. **Summarize**: Report for each commit:
   - Repository and branch
   - Short commit hash and subject line
   - Files included (and note any intentionally unstaged files)
