---
name: handoff
description: >-
  Save the current conversation context, active implementation plans, analysis
  results, next steps, and workspace git state as a per-task handoff baton in
  the shared agent-context repository and push it so work can be resumed on
  another machine (supporting multiple parallel handoffs per project). Use when
  the user invokes /handoff or asks to save/stash session context for another
  system.
---

# Handoff (Save Session Context Across Machines)

Invoking `/handoff` counts as explicit user approval to pull, commit, and push
the `agent-context` repository. It does **not** auto-push active project code
repositories unless the user also invokes `/ship`.

Handoffs use a **baton-pass** model: each handoff is stored in its own
`<project>/<slug>/` folder so multiple disparate tasks can coexist safely within
the same project, and `/resume` automatically consumes (removes) the baton once
picked up.

## Steps

1. **Resolve the `agent-context` repository path (case-insensitive)**:
   - Derive the user's home directory and parent repos directory from the active
     workspace path (e.g., `C:\Users\<user>\Repos` on Windows or
     `/home/<user>/repos` / `/home/<user>/Repos` on Linux).
   - Locate `agent-context` case-insensitively under `<home>/repos/agent-context`
     or `<home>/Repos/agent-context` (on Linux, check whichever casing exists).
   - If `agent-context` is not cloned yet on this machine, create `<home>/repos`
     if neither `repos` nor `Repos` exists, then clone
     `git@github.com:ltcovalt/agent-context.git` (falling back to
     `https://github.com/ltcovalt/agent-context.git`) into that directory.
   - Always use the resolved **literal absolute path** (no `$VAR` or `$(...)`
     shell expansions) in `git -C <agent-context-path> ...` commands so command
     approvals remain prefix-matchable.

2. **Pull latest `agent-context`**:
   - If `agent-context` was already cloned, run
     `git -C <agent-context-path> pull --rebase` so local handoffs are up to
     date before writing (skip if freshly cloned in Step 1).

3. **Inspect active workspace repositories & choose `<project>` and `<slug>`**:
   - For each active workspace repository, check the current branch, latest
     short commit hash (`git rev-parse --short HEAD`), uncommitted changes
     (`git status --short`), and unpushed commits
     (`git log @{u}..HEAD --oneline`).
   - Determine `<project>`:
     - Default to the primary (first) active workspace folder name in lowercase
       (e.g., `code-cad` for the `code-cad` + `code-cad-studio` workspace).
   - Determine `<slug>` (lowercase kebab-case `a-z0-9-`, max ~40 chars):
     - If the user passed a name/hint (e.g. `/handoff can-lid`), slugify it.
     - Otherwise, if this conversation was resumed from a `<slug>` and is still
       working on that same task, reuse that `<slug>`.
     - Otherwise, derive a concise, descriptive slug from the current task
       (e.g., `can-lid-model`, `windows-ci-fixes`, `export-modal-polish`).
     - If `<agent-context-path>/<project>/<slug>/HANDOFF.md` already exists for
       a **different** active task, append `-2` (or `-3`, etc.) so unrelated
       parallel handoffs are never overwritten.

4. **Copy unfinished plans & analysis artifacts**:
   - Check the current conversation's artifact directory (`<Artifact Directory Path>`)
     for any active implementation plans, analysis documents, or task notes that
     are still relevant to this task.
   - Copy each relevant artifact into
     `<agent-context-path>/<project>/<slug>/artifacts/<filename>.md` (and remove
     any stale files inside that same `<slug>/artifacts/` folder if updating an
     existing slug). Never touch sibling `<project>/<other-slug>/` folders.

5. **Write `<agent-context-path>/<project>/<slug>/HANDOFF.md`**:
   - Use `write_file` to write a concise, self-contained handoff document with a
     structured metadata header so `/resume` can disambiguate multiple handoffs
     at a glance:
     ```markdown
     # Handoff: <Short Human-Readable Title>
     Project: <project>
     Slug: <slug>
     Updated: <YYYY-MM-DD HH:MM TZ> (<OS / Hostname>)
     Summary: <One-line summary of the task and where it paused>

     ## Current Goal & Status
     - Concise summary of what was being worked on and where execution stopped.

     ## Workspace Snapshot
     | Repo | Branch | Commit | Working Tree | Unpushed |
     | :--- | :--- | :--- | :--- | :--- |
     | `<repo-name>` | `<branch>` | `<sha>` | clean / dirty | 0 / N commits |

     ## Completed in This Session
     - Key changes, commits, or findings completed so far.

     ## Next Steps
     - [ ] First concrete action to take when resuming
     - [ ] Follow-up actions / validation steps

     ## Key Decisions, Findings & Gotchas
     - Important design choices, root causes discovered, ruled-out approaches,
       or environment quirks the next session should not re-investigate.

     ## Active Artifacts
     - Links/paths to files in `artifacts/` (if any), with a 1-line summary of
       each (or `- None`).
     ```

6. **Commit and push `agent-context`**:
   - Run prefix-matchable git commands with the literal path:
     - `git -C <agent-context-path> add -A`
     - `git -C <agent-context-path> commit -m "handoff(<project>/<slug>): <short summary>"`
     - `git -C <agent-context-path> push`

7. **Report summary & warn on unsynced code**:
   - Confirm the handoff path (`<project>/<slug>`), commit hash, and any synced
     artifacts pushed to `agent-context`.
   - If any active workspace code repository has **uncommitted changes** or
     **unpushed commits**, highlight them clearly and ask if the user wants to
     run `/ship` (or push a `wip/...` branch) before leaving this machine.
