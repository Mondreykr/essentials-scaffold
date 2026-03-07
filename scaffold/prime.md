---
description: Prime Claude's plan mode with scoped tasks from the current plan
---

**Precondition 1:** Verify plan mode is active. Check for plan mode indicators
in the system context. If plan mode is NOT active, stop and say:

> "Enter plan mode first (shift-tab), then run `/scaffold:prime`."

**Precondition 2:** Read `.scaffold/state.md`. Check the "Next Action" section
for a plan file pointer. If Next Action has no plan file pointer, or says
"Run /scaffold:plan", stop and say:

> "No plan to prime. Run `/scaffold:plan` first."

---

## Step 1: Load Context

Read these files in order:

1. The plan doc referenced in state.md's Next Action
2. `CLAUDE.md`
3. Context files listed in the plan doc's `## Context Pointers` section

---

## Step 2: Validate Scope

Check for `## AI Tasks` section in the plan doc. If absent, stop and say:

> "No AI tasks in this plan — nothing to prime."

Count AI tasks. Note whether `## User Tasks` section exists.

---

## Step 3: Present Scope

> "Plan: [filename]. [N] AI tasks. [User tasks: yes/no — handled by
> `/scaffold:verify` after.]"
>
> "Context loaded. Proceeding with plan mode research."

---

## Step 4: Hand Off

Claude continues in plan mode naturally — the AI Tasks section with its fixed
preamble is now in context. Research the codebase to understand how to implement
the tasks, write an execution plan, and present it to the user for approval.

---

## Boundaries

Prime does NOT:
- **Update scaffold files** — state.md was already set by `/scaffold:plan`
- **Call EnterPlanMode** — the user already entered plan mode
- **Execute tasks** — Claude's plan mode handles that after user approval
- **Write anything** — prime is read-only (reads files, presents information)
