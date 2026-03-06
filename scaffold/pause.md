---
description: Pause work and capture context for seamless resumption
---

**Precondition:** Verify that `.scaffold/state.md` and `.scaffold/roadmap.md`
exist. If any are missing, stop and say:
"Scaffold files missing — run /scaffold:setup first."

---

## Capture Context

1. Read `.scaffold/state.md`, `.scaffold/roadmap.md`, and the most recent plan
   file in `.scaffold/plans/` (if one exists).

2. Assess what was accomplished vs what remains:
   - Which tasks moved to `[x]` or `>>` this session?
   - What's left in the current phase?
   - Were any decisions made but not yet checkpointed?

3. Ask the user:
   > "Anything else I should note for whoever picks this up?
   > (Context, gotchas, where you left off mentally — or just 'no'.)"

   Wait for response.

---

## Write Handoff File

Write `.scaffold/continue-here.md` with this structure:

```markdown
# Continue Here
<!-- Written: [today's date and time] -->

## Current State
[idle | mid-plan | mid-execute | blocked] — [which command was running, if any]

## Completed Work
- [Specific files changed, tasks completed, features built]
- [Reference roadmap task names where applicable]

## Remaining Work
- [Tasks still open in the current phase — reference roadmap.md]
- [If mid-execute: which tasks in the plan doc are not yet done]

## Decisions Made
- [Any decisions from this session not yet captured in decisions.md]
- [Omit section if none]

## Blockers
- [Current blockers, if any]
- [Omit section if none]

## Context & Approach
[What I wish someone had told me before starting this session.
Key insight, tricky bit, approach that's working, thing to watch out for.]

## Next Specific Action
[Concrete next step — e.g., "Run /scaffold:execute to continue plan
`.scaffold/plans/20260305-01-phase-2-api.md`, starting from Task 3."
Or: "Run /scaffold:checkpoint to commit completed work, then /scaffold:plan
for the next batch."]
```

---

## Update State

- Update `.scaffold/state.md`:
  - Status → "paused"
  - Annotate Current Position with pause context (e.g., "Paused mid-execute —
    see `.scaffold/continue-here.md`")
- Update the `<!-- Last updated -->` date

---

## Commit and Confirm

If git is initialized:
`git add .scaffold/ && git commit -m "pause: [brief description of where we stopped]"`

Then confirm:

> "Context captured in `.scaffold/continue-here.md`.
> When you're ready to pick up, run `/scaffold:resume`."
