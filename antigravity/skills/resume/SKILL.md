---
name: resume
description: >-
  Pull the latest cross-machine session context, unfinished implementation
  plans, and analysis artifacts from the agent-context repository, verify
  active workspace repository git state against the snapshot, and brief the
  user on the exact next steps. Use when the user invokes /resume or asks to
  pick up where they left off.
---

# Resume (Load Session Context From Another Machine)

Invoking `/resume` pulls the latest handoff context and artifacts from the
`agent-context` repository and gets the current conversation up to speed.

## Steps

1. **Resolve the `agent-context` repository path (case-insensitive)**:
   - Derive the user's home directory and parent repos directory from the active
     workspace path (e.g., `C:\Users\<user>\Repos` on Windows or
     `/home/<user>/repos` / `/home/<user>/Repos` on Linux).
   - Locate `agent-context` case-insensitively under `<home>/repos/agent-context`
     or `<home>/Repos/agent-context` (if not cloned yet on this machine, clone
     `git@github.com:ltcovalt/agent-context.git` or
     `https://github.com/ltcovalt/agent-context.git` into the existing
     `repos`/`Repos` directory).
   - Always use the resolved **literal absolute path** (no `$VAR` or `$(...)`
     shell expansions) in `git -C <agent-context-path> ...` commands so command
     approvals remain prefix-matchable.

2. **Pull latest `agent-context`**:
   - Run `git -C <agent-context-path> pull --rebase`.

3. **Locate and read the project handoff**:
   - Look for `<agent-context-path>/<project>/HANDOFF.md` matching the active
     workspace folder name(s) (e.g., `code-cad` for `code-cad` +
     `code-cad-studio`). If not immediately clear, list folders in
     `<agent-context-path>` and match against active workspace repo names.
   - Read `HANDOFF.md` and any linked files in
     `<agent-context-path>/<project>/artifacts/` using `read_file`.

4. **Check active workspace git state against the snapshot**:
   - In each active workspace repository, check current branch, latest commit
     (`git rev-parse --short HEAD`), and working tree status
     (`git status --short`).
   - Compare against the `## Workspace Snapshot` table in `HANDOFF.md`:
     - If a workspace repo is on a different branch or behind the commit listed
       in `HANDOFF.md`, note it clearly and offer to `git pull` / `git switch`
       so the code matches the handoff state.

5. **Present a concise resume briefing**:
   - Summarize in a few lines:
     - **Where you left off** (goal & last completed work)
     - **Loaded artifacts** (any active plan or analysis docs loaded from
       `artifacts/`)
     - **Repo sync check** (whether all active repos match the handoff commit
       and branch)
     - **Proposed next step** (the first unchecked `- [ ]` item under
       `## Next Steps`, ready to begin immediately)
