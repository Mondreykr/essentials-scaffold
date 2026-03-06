---
description: Execute a pending quick task — fix, verify, record, commit
---

**Precondition:** Verify that `.scaffold/state.md` exists. If missing, stop
and say: "Scaffold files missing — run /scaffold:setup first."

---

## Step 1: Find Pending Quick Task

Scan `.scaffold/quick/` for directories that have `plan.md` but no `summary.md`.
These are pending quick tasks.

- If none found: "No pending quick tasks. Run `/scaffold:quick` to plan one."
- If multiple found: list them and ask which one to execute.
- If exactly one: use it.

Read the `plan.md` from the selected task directory.

---

## Step 2: Orient

Re-read `.scaffold/state.md` briefly in case anything changed since the plan
was written. Note any new blockers or state changes.

---

## Step 3: Do the Work

Execute the approach from the plan:

1. Investigate the issue — read relevant files, understand the problem
2. Implement the fix
3. If investigation produces durable findings, write them to
   `.scaffold/investigations/YYYYMMDD-NN-slug.md` (create directory if needed)

**Escape hatch:** If during execution the task turns out to be bigger than
expected — needs more than 3 steps, requires architectural decisions, or
touches multiple subsystems — STOP and say:

> "This is bigger than the quick plan anticipated. [explain what changed]
> Suggest converting to full `/scaffold:plan` + `/scaffold:execute`."

Let the user decide how to proceed.

---

## Step 4: Verify

Check for test/lint/build commands in the project (package.json scripts,
Makefile, pytest, cargo test, go test, CLAUDE.md references, etc.):

- **If found:** Run them. If they fail, stop and report before committing.
  Do NOT record as resolved if verification fails.
- **If not found:** Ask the user to confirm the fix works.

This preserves scaffold's "evidence, not trust" principle.

---

## Step 5: Write Summary

Write `.scaffold/quick/NNN-slug/summary.md`:

```markdown
# Quick Task NNN: [description]

**Date:** YYYY-MM-DD
**Status:** resolved | partial | deferred-to-plan

## Issue
[What was wrong — 1-3 sentences]

## Fix
[What was changed — files modified, approach taken]

## Verification
[How verified — test output, manual check, etc.]

## Notes
[Anything worth remembering. Omit section if nothing to note.]
```

---

## Step 6: Update State

Update `.scaffold/state.md` — append to the Quick Fixes table. If the table
doesn't exist yet, create it as a new section before the existing sections
(after the `# State` header):

```markdown
## Quick Fixes

| # | Description | Date | Status |
|---|-------------|------|--------|
| NNN | [description] | YYYY-MM-DD | resolved |
```

If the table already exists, append a new row.

Update the `<!-- Last updated -->` date.

---

## Step 7: Handle Blockers

If this quick fix resolved a blocker listed in `.scaffold/state.md`:

1. Remove the blocker from the Blockers section in state.md
2. Add an entry to `.scaffold/decisions.md` (at the top, newest first):
   - **Category:** Resolved Blocker
   - **Context:** what was blocked and why
   - **Decision:** the resolution
   - **Why:** how/why this resolved it
   - **Status:** Active

---

## Step 8: Commit

If git is initialized:

```
git add [changed project files] .scaffold/quick/NNN-slug/ .scaffold/state.md
git commit -m "quick(NNN): [description]"
```

If `.scaffold/decisions.md` was updated (blocker resolution), include it in
the commit.

Then confirm:

> "Quick task NNN complete: [description]
> Summary: `.scaffold/quick/NNN-slug/summary.md`"
