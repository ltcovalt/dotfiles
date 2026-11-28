---
name: resume
description: >-
  Pull pending cross-machine handoff batons from the agent-context repository,
  disambiguate multiple parallel handoffs, detect stale handoffs via git
  ancestry, load active plans/artifacts into the current session, consume the
  picked-up baton from agent-context, and brief the user on exact next steps.
  Use when the user invokes /resume or asks to pick up where they left off.
---

# Resume (Pick Up a Session Handoff From Another Machine)

Invoking `/resume` pulls pending handoff batons from `agent-context`, loads the
selected handoff into the current conversation, and **consumes (removes) that
baton** from `agent-context` so finished sessions never leave stale files behind.

Invoking `/resume` counts as explicit user approval to pull, remove the consumed
handoff folder, commit, and push `agent-context` (every consumed handoff remains
recoverable from `agent-context` git history if ever needed).

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
     `git -C <agent-context-path> pull --rebase` (skip if freshly cloned in
     Step 1).

3. **Discover pending handoffs for the active project**:
   - Determine `<project>` from the active workspace folder name(s) (e.g.,
     `code-cad` for `code-cad` + `code-cad-studio`).
   - Scan `<agent-context-path>/handoffs/<project>/*/HANDOFF.md` as the primary
     location.
   - As a backwards-compatible fallback, also check legacy
     `<agent-context-path>/<project>/*/HANDOFF.md` **only** when a `HANDOFF.md`
     file is explicitly present inside `<slug>/` (never treat permanent project
     doc folders such as `<project>/strategy/` or `<project>/releases/` as
     handoffs).
   - **If 0 pending handoffs exist for `<project>`**:
     - Check whether any *other* projects have pending handoffs under
       `<agent-context-path>/handoffs/*/*/HANDOFF.md` (or legacy
       `<agent-context-path>/*/*/HANDOFF.md` where `HANDOFF.md` is explicitly
       present) and note them briefly if so.
     - Run `git -C <agent-context-path> log -n 3 --oneline -- handoffs/<project> <project>`
       and tell the user there are no active handoffs for `<project>`,
       mentioning that the most recent consumed handoff can be restored from
       git history upon request. Stop here.
   - **If the user supplied a hint** (e.g. `/resume can-lid`):
     - Match case-insensitively against `<slug>` or `# Handoff:` title. If
       exactly one matches, select it; otherwise disambiguate below.
   - **If 2 or more pending handoffs exist and selection is ambiguous**:
     - Read the header metadata (`# Handoff:`, `Slug:`, `Updated:`, `Summary:`,
       and `## Workspace Snapshot`) of every pending handoff in `<project>` and
       run the staleness check (Step 4) on each.
     - Use `ask_question` to present a concise multiple-choice picker where each
       option shows: `<Title> (<slug>) — <Summary> [<Host>, <Date>, <freshness>]`
       (and include a `"Discard stale handoff(s)"` option if any are stale).
     - Wait for the user's choice before loading or consuming anything. Leave
       all unselected sibling handoffs untouched in `agent-context`.

4. **Check active workspace git state & staleness**:
   - For each repository listed in the selected handoff's `## Workspace Snapshot`,
     check its current branch, `HEAD` (`git rev-parse --short HEAD`), and
     working tree (`git status --short`).
   - Determine freshness relative to the snapshot commit `<sha>`:
     - **Exact match**: `HEAD` equals `<sha>`.
     - **Behind**: `HEAD` is an ancestor of `<sha>` or `<sha>` is not yet
       present locally (offer to `git pull` / `git switch`).
     - **Ahead (potentially stale)**: `<sha>` is a strict ancestor of `HEAD`
       (`git merge-base --is-ancestor <sha> HEAD` succeeds and `HEAD != <sha>`).
       Check `git log --oneline <sha>..HEAD` to see what landed since.
   - **Staleness safety net**: If the handoff's tracked repo(s) are strictly
     **ahead** of the snapshot (indicating newer commits were already completed
     after the handoff was created), do **not** auto-consume yet — briefly show
     the handoff summary alongside the newer commits and ask whether to:
     - **Discard** the stale handoff (remove it from `agent-context`), or
     - **Resume anyway** (load context and consume it).

5. **Load context & copy active artifacts locally**:
   - Read the selected `HANDOFF.md` and every file under its `artifacts/` folder
     (if present) using `read_file`.
   - If `artifacts/` has active plans or analysis files, copy them into the
     current conversation's `<Artifact Directory Path>/` via `write_file` so
     they stay available locally after the baton is removed from `agent-context`.

6. **Consume the baton in `agent-context`**:
   - Delete **only** the matched `<slug>/` directory:
     - Primary path: `<agent-context-path>/handoffs/<project>/<slug>/` (if
       `handoffs/<project>/` becomes empty afterward, remove the empty
       `handoffs/<project>/` directory too).
     - Legacy fallback path: `<agent-context-path>/<project>/<slug>/` (only
       when matched via an explicit `HANDOFF.md` inside `<slug>/`).
   - Never delete sibling handoffs belonging to other parallel tasks, and
     **never** modify or delete permanent project docs or parent directories
     under top-level `<agent-context-path>/<project>/`.
   - Commit and push using literal paths:
     - `git -C <agent-context-path> add -A`
     - `git -C <agent-context-path> commit -m "resume(<project>/<slug>): picked up on <OS/Host>"`
     - `git -C <agent-context-path> push`

7. **Present a concise resume briefing**:
   - **Where you left off** (title, slug, goal, and last completed work)
   - **Loaded artifacts** (copied into the current session's artifact directory,
     if any)
   - **Repo sync check** (whether all active repos match the handoff commit and
     branch, offering `git pull` / `git switch` if behind)
   - **Baton status** (confirm the consumed handoff path — e.g.,
     `handoffs/<project>/<slug>` or legacy `<project>/<slug>` — was removed
     from `agent-context`, and mention if any other parallel handoffs remain
     queued for `<project>`)
   - **Proposed next step** (the first unchecked `- [ ]` item under
     `## Next Steps`, ready to begin immediately)
