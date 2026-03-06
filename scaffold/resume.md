---
description: Resume work from a paused session with full context restoration
---

**Precondition:** Check if `.scaffold/continue-here.md` exists. If it does NOT
exist, say:

> "No paused session found. Run `/scaffold:status` to orient instead."

Stop here.

---

## Restore Context

1. Read these files in order:
   - `.scaffold/continue-here.md`
   - `.scaffold/state.md`
   - `.scaffold/roadmap.md`
   - `CLAUDE.md`
   - The plan doc referenced in continue-here.md (if any)

2. Present a structured briefing:

   > **Resuming from pause** ([date from continue-here.md])
   >
   > **State:** [Current State field]
   > **Completed:** [brief summary from Completed Work]
   > **Remaining:** [brief summary from Remaining Work]
   > **Blockers:** [if any]
   > **Context:** [Context & Approach field — the key insight]
   > **Next action:** [Next Specific Action field]

---

## Clean Up Pause State

- Delete `.scaffold/continue-here.md`
- Update `.scaffold/state.md`:
  - Remove "paused" status — restore to appropriate status based on context
    (e.g., "executing" if mid-execute, "idle" if between commands)
  - Remove pause annotation from Current Position
- Update the `<!-- Last updated -->` date

If git is initialized:
`git add .scaffold/ && git commit -m "resume: restore from pause"`

---

## Route to Next Action

Based on the Current State field from continue-here.md:

- **mid-execute:** Proceed directly to executing remaining tasks from the
  referenced plan doc. Continue where the pause left off.
- **mid-plan:** Resume the planning flow. Re-read the roadmap and pick up
  from where planning stopped.
- **idle / between commands:** Suggest the next command based on the
  Next Specific Action field.
- **blocked:** Surface the blocker and ask the user how to proceed.
