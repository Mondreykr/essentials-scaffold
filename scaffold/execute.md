---
description: Execute scoped tasks from the current plan
---

**Precondition:** Read `.scaffold/state.md`. Check the "Next Action" section for
a plan file pointer. If Next Action says "No execute needed", "Run /scaffold:plan",
or has no plan file pointer, stop and say:
"No execution planned. Run /scaffold:plan first."

---

## Step 1: Load the Plan

Read the plan file referenced in state.md's Next Action section.
Check whether a `## Prep Detail` section exists in the plan doc.

Confirm with the user:

> "Plan: [filename]. Goal: [session goal]. [N] tasks in scope.
> Prep detail: [yes/no]. Ready to execute?"

If prep detail is missing and state.md had recommended running prep first:
> "This plan hasn't been prepped. Proceed with basic task descriptions,
> or run `/scaffold:prep` first?"

If the user says no or wants changes, let them modify scope verbally
or suggest they edit the plan file directly.

---

## Step 2: Load Context

Read CLAUDE.md and context files listed in the plan's "Context pointers" section.
Read key files for the first task (from Prep Detail if available, otherwise
read as needed).

---

## Step 3: Execute Tasks

Work through scoped tasks in order. For each task:

1. Check if a matching entry exists in the plan doc's `## Prep Detail` section
   (match by task title)
2. **If Prep Detail exists for this task:**
   - Read key files listed in the prep detail
   - Follow the approach described
   - Verify using the prep detail's "Verify by" criteria
3. **If no Prep Detail:**
   - Read key files as needed (execute figures it out from the task description)
   - Use the task's "Done when" field as the acceptance criterion
4. If verification fails: present findings, ask user how to proceed
5. If task is bigger than expected: stop, explain, ask user to re-scope

For investigation tasks:
- Write findings to the path specified in the task's `**Output to:**` field
- This creates a file in `.scaffold/investigations/` (create directory if needed)
- The filename is already specified by plan -- execute just writes to it

---

## Step 4: Between Tasks

- If the conversation is getting long (many tool calls, large code blocks),
  suggest `/scaffold:checkpoint` for completed work before continuing
- Read key files for the next task before starting (from Prep Detail if available)
- Brief the user: "Task N complete. Moving to Task N+1: [description]"

---

## Step 5: Wrap Up

When all scoped tasks complete (or user decides to stop):
- Summarize which tasks completed and which didn't
- Note any issues discovered during execution
- Suggest `/scaffold:checkpoint` to close the loop

---

## Boundaries

Execute does NOT:
- **Update scaffold files** -- that's checkpoint's job
- **Make strategic decisions** -- that's plan's job
- **Write scaffold documents outside `.scaffold/`** -- all scaffold-produced
  documents go under `.scaffold/`. Plans -> `.scaffold/plans/`.
  Investigation output -> `.scaffold/investigations/`.
  Never write scaffold documents to project directories (e.g., `docs/`, `notes/`).

If execution reveals that the plan is wrong, scope needs to change, or
unexpected complexity arises -- STOP and tell the user. They decide:
adjust and continue, or re-plan.

If the user changes direction mid-execute: suggest checkpoint completed work ->
`/clear` -> `/scaffold:plan` for the new direction.
