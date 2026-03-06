---
description: Save session progress — update scaffold files and commit
argument-hint: [--audit]
---

**Precondition:** Verify that CLAUDE.md, `.scaffold/state.md`, and
`.scaffold/roadmap.md` exist. If any are missing, stop and say:
"Scaffold files missing — run /scaffold:setup first."

---

## Pre-persist Verification

Before updating scaffold files, check that claims about this session's work
are accurate:

1. **If code was changed and test/lint/build commands exist** (check package.json
   scripts, Makefile, pytest, cargo test, go test, etc.):
   - Run them. If they fail, report results to the user.
   - Do NOT record work as "done" in roadmap if tests are failing.
   - Let the user decide: fix now, or checkpoint with issues noted in state.md.

2. **Evidence-based updates:**
   - Moving a task to `[x]` in roadmap requires evidence it works (test output,
     observed behavior, or user confirmation).
   - Removing an item from "Blockers" requires evidence the blocker is resolved.
   - "It should work" or "I didn't change anything that would break it" is NOT
     evidence. Run verification if possible.

3. **If verification is not possible** (no tests, can't run the app, etc.):
   - Note this honestly in state.md: "Completed X — not yet verified (no tests)"
   - Do NOT claim verified completion.

If verification reveals issues, present them before proceeding with the
checkpoint. Let the user decide whether to fix now or note and move on.

---

## Check for Quick Fixes

If `.scaffold/state.md` has a Quick Fixes table with entries since the last
checkpoint, check whether any completed quick fixes also completed a roadmap
task. If so, mark that task `[x]` in `.scaffold/roadmap.md` with the
completion date from the quick fix. This reconciles quick work with the
main roadmap.

---

## Check for Plan File

Look for a plan file in `.scaffold/plans/`. Match by project root path in the
plan file's Project section, then take the most recent by date. If one exists
for this project, read it for additional routing sources:

- **Deferred Items section** → route each item to the appropriate roadmap phase
  or Backlog as specified in the plan file
- **Decisions for decisions.md section** → route each decision to decisions.md
  with the context captured during planning
- **Investigation tasks with `Output to` fields** → verify that the output
  files exist in `.scaffold/investigations/`. If they do, note them in the
  checkpoint summary. Do not route or delete them — investigation files are
  durable reference material.

These items were captured during planning and survive context clear via the
plan file. The conversation may not contain them.

---

## Update Scaffold Files

Review everything we did and discussed this session. Then update files:

### 1. `.scaffold/roadmap.md` (always update)

- Mark completed tasks `[x]` with completion date: `- [x] Task name (YYYY-MM-DD)`
- Update or remove `>>` markers on tasks no longer actively in progress
- Add `>>` markers to tasks that are now in progress
- Route deferred items from plan file to appropriate phase or Backlog

**Phase sign-off gate:**
If ALL tasks in the `[IN-PROGRESS]` phase are now `[x]`, ask the user:

> "All Phase N tasks complete. Mark Phase N as [COMPLETE] and promote
> Phase N+1 to [IN-PROGRESS]?"

Wait for explicit approval before changing phase status. The user may want to
add more tasks to the current phase, or may not be ready to advance.

- Update the `<!-- Last updated: YYYY-MM-DD -->` comment at the top

### 2. `.scaffold/state.md` (always update)

- Status → "idle" (or "blocked" with reason)
- Current Position → reflect what was accomplished this session
- Next Action → clear the execute pointer. Set to either:
  - "Run /scaffold:plan to determine next steps" (default)
  - A note about remaining work if partially complete
- Update Blockers — add new blockers, remove resolved ones
- **Resolved blocker routing:** For each blocker removed, add an entry to
  `.scaffold/decisions.md` (at the top, newest first) with:
  - Category: `Resolved Blocker`
  - Context: what was blocked and why
  - Decision: the resolution
  - Why: how/why this resolved it
  - Status: `Active`
- Update Open Questions — add new ones, remove answered ones
- Update the `<!-- Last updated: YYYY-MM-DD -->` comment at the top

### 3. `.scaffold/decisions.md` (update only if decisions were made)

- Add new entries at the TOP of the file (below the header, above existing entries)
  with today's date, category, context, decision, reasoning, and status
- Include decisions from the plan file's "Decisions for decisions.md" section
- Skip trivial decisions (variable names, minor styling, etc.)
- **Updating existing decisions:** If a decision's status changed (Active → Revisiting
  or Reversed), update the Status field in place. If Reversed, move the entry to
  the `## Archived` section at the bottom.
- If 20+ active entries: suggest archiving older stable ones
- If updated, update the `<!-- Last updated -->` date

### 4. `.scaffold/project.md` (update only if vision/scope evolved)

- Update "What is this?" if our understanding of the project sharpened
- Update "Scope boundaries" if we decided to include or exclude something
- Update "What does success look like?" if the goal shifted
- Skip if nothing changed about the vision
- If updated, update the `<!-- Last updated -->` date

### 5. CLAUDE.md (update only if structural things changed)

- Update "Tech stack" if we added or changed technologies
- Update "Hard constraints" if new constraints emerged
- Skip if nothing structural changed

---

## Review Before Committing

- Re-read all updated files. Flag any contradictions between them.
- Run `git diff .scaffold/` to see mechanical ground truth of what changed
- For each file updated, show the specific changes:
  - What was added
  - What was removed
  - What was reworded
- Present the changes and ask: "These are the checkpoint changes. Anything to adjust before I commit?"
- Wait for confirmation before proceeding to git commit
- If the user requests changes, make them and show the updated diff
- Only commit after explicit approval

---

## After Approval

- If git is initialized: `git add CLAUDE.md .scaffold/ && git commit -m "checkpoint: [brief summary of session]"`
  If the commit fails, show the error and stop. Don't retry automatically.
- List any open questions or loose threads heading into next session.

---

## Enhanced Mode (`/scaffold:checkpoint --audit`)

If "--audit" appears in the arguments, after the standard checkpoint completes
(including user approval and git commit), launch an Explore subagent
(thoroughness: "very thorough") to verify scaffold claims against the codebase:

1. **Done items** — Do completed roadmap items actually exist in the code?
   Look for the features, routes, components, or functions they describe.
2. **In progress items** — Do they have recent changes or uncommitted work?
3. **Blockers** — Can you find evidence of these issues in the code?
4. **Tech stack** — Does CLAUDE.md's tech stack match actual dependencies
   in manifest files?
5. **Decisions** — Do active decisions in .scaffold/decisions.md match what
   the code actually does?

Report discrepancies: "Audit found N issues:" followed by specifics.
Do NOT modify scaffold files — report only, let the user decide what to fix.

If the subagent fails or times out, the checkpoint already committed. Note
the audit failure and move on.
