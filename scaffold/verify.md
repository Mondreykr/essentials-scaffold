---
description: Verify completed user tasks from the current plan
---

**Precondition:** Read `.scaffold/state.md`. Check the "Next Action" section for
a plan file pointer. If Next Action has no plan file pointer, or says
"Run /scaffold:plan", stop and say:
"No plan to verify. Run /scaffold:plan first."

Read the plan doc referenced in state.md's Next Action section. Scan for tasks
marked `[USER]` in the Tasks section. If no `[USER]` tasks exist, stop and say:
"No user tasks in this plan. Run /scaffold:execute or /scaffold:checkpoint instead."

---

## Step 1: Present Overview

Show the user what USER tasks are in the plan:

> "Plan: [filename]. [N] user task(s) to verify:
> 1. [Task title]
> 2. [Task title]
> ...
> Ready to walk through them?"

Wait for the user to confirm before proceeding.

---

## Step 2: Gated Walkthrough

Process each `[USER]` task one at a time, in plan order. For each task:

**Present the task:**
- What was expected (from the task's **What:** field)
- What "done" looks like (from the task's **Done when:** field)
- Any specified artifacts (from the task's **Artifacts:** field)

**If artifacts are specified** (file paths): check whether each file exists.
Report findings:
- Found: "[path] exists ([size], [modified date])"
- Missing: "[path] not found"

**Ask the user** (using AskUserQuestion):
> "Task: [title]
> Expected: [done-when condition]
> Artifacts: [found/missing status, or 'none specified']
>
> Did you complete this? Describe what happened."

**Process the response:**

- **Pass** -- user confirms completion, description is consistent with done-when
  criteria. Will mark `[x]` in roadmap during wrap-up.
- **Issue** -- user completed it but something went wrong or is partially done.
  Record the issue. Ask:
  > "Should this be a blocker (blocks further work) or a follow-up task
  > (add to roadmap for later)?"
  Create the appropriate entry during wrap-up.
- **Not done** -- user hasn't done this yet. Leave `[ ]` in roadmap. Note in
  state.md during wrap-up.

**GATE: Do not proceed to the next task until the current one is fully resolved.**
Each task must have a clear outcome (pass, issue, or not-done) before moving on.

---

## Step 3: Wrap Up

Tally results and route accordingly:

### All passed

1. Mark each verified `[USER]` task `[x]` in `.scaffold/roadmap.md` with today's
   date: `- [x] [USER] Task name (YYYY-MM-DD)`
2. Route deferred items from the plan doc:
   - **Deferred Items section** -> route each item to the appropriate roadmap
     phase or Backlog as specified in the plan file
   - **Decisions for decisions.md section** -> route each decision to
     `.scaffold/decisions.md` with the context captured during planning
   - **Investigation tasks with `Output to` fields** -> verify that the output
     files exist in `.scaffold/investigations/`. Note them in the summary.
3. Clear the plan pointer in `.scaffold/state.md`:
   - Status -> "idle"
   - Next Action -> "Run /scaffold:plan to determine next steps."
4. Update the `<!-- Last updated -->` dates on all modified scaffold files.
5. If git is initialized:
   `git add .scaffold/ && git commit -m "verify: [brief summary of verified tasks]"`

### Some issues

1. Mark passed tasks `[x]` in `.scaffold/roadmap.md` with today's date.
2. For tasks with issues:
   - If blocker: add to Blockers section in `.scaffold/state.md`
   - If follow-up: add as new task in the appropriate roadmap phase
3. Do NOT route deferred items or decisions from the plan doc.
4. Do NOT clear the plan pointer. Update `.scaffold/state.md`:
   - Status -> "blocked" (if blockers) or "idle" (if only follow-ups)
   - Next Action -> "User tasks pending: [list incomplete/issue tasks].
     Run `/scaffold:verify` when resolved.
     Plan: [plan file path]"
5. Update the `<!-- Last updated -->` dates on all modified scaffold files.
6. If git is initialized:
   `git add .scaffold/ && git commit -m "verify: partial -- [summary of what passed and what didn't]"`

### None done

1. Do not modify roadmap.
2. Update `.scaffold/state.md`:
   - Next Action -> "User tasks pending: [list all USER tasks].
     Run `/scaffold:verify` when complete.
     Plan: [plan file path]"
3. Update the `<!-- Last updated -->` date on state.md.
4. No commit needed -- nothing substantive changed.

---

## Step 4: Summary

Present results:

> "Verified [N] user task(s):
> - [Task title]: [pass/issue/not done]
> ...
> [Next action recommendation based on outcome]"

**If all passed:**
> "All user tasks verified. Plan complete. Run `/scaffold:plan` for next steps."

**If some issues:**
> "Partial verification. [N] passed, [N] issues. Resolve issues then
> run `/scaffold:verify` again."

**If none done:**
> "No tasks complete yet. Run `/scaffold:verify` when ready."

---

## Boundaries

Verify does NOT:
- **Execute AI tasks** -- that's execute's job
- **Make strategic decisions** -- that's plan's job
- **Guess at user task outcomes** -- the user confirms each task explicitly
- **Route deferred items when tasks remain incomplete** -- only routes when all
  USER tasks pass
