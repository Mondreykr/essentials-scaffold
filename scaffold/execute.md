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
Confirm with the user:

> "Plan: [filename]. Goal: [session goal]. [N] tasks in scope.
> Ready to execute?"

If the user says no or wants changes, let them modify scope verbally
or suggest they edit the plan file directly.

---

## Step 2: Load Context

Read CLAUDE.md and context files listed in the plan's "Context pointers" section.
Read key files listed for the first task.

---

## Step 3: Execute Tasks

Work through scoped tasks in order. For each task:
- Read key files listed for the task
- Follow the tactical detail in the plan doc
- Verify using the plan's "Verify by" criteria
- If verification fails: present findings, ask user how to proceed
- If task is bigger than expected: stop, explain, ask user to re-scope

For investigation tasks:
- Write findings to the designated scratch file as you work
- This persists findings outside context

---

## Step 4: Between Tasks

- If the conversation is getting long (many tool calls, large code blocks),
  suggest `/scaffold:checkpoint` for completed work before continuing
- Read key files for the next task before starting
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
- **Update scaffold files** — that's checkpoint's job
- **Make strategic decisions** — that's plan's job
- **Re-research the approach** — the plan doc has tactical detail

If execution reveals that the plan is wrong, scope needs to change, or
unexpected complexity arises — STOP and tell the user. They decide:
adjust and continue, or re-plan.

If the user changes direction mid-execute: suggest checkpoint completed work →
`/clear` → `/scaffold:plan` for the new direction.
