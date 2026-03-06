---
description: Plan a quick fix — lightweight task that skips the full plan/execute ceremony
argument-hint: [--discuss] [description]
---

**Precondition:** Verify that `.scaffold/state.md` and `.scaffold/roadmap.md`
exist. If any are missing, stop and say:
"Scaffold files missing — run /scaffold:setup first."

---

## Step 1: Get Description

If a description was provided as an argument, use it.
Otherwise, ask: "What needs fixing? One sentence."

---

## Step 2: Create Directory

Create `.scaffold/quick/NNN-slug/` where:
- `NNN` is a zero-padded 3-digit number
- Scan `.scaffold/quick/` for existing directories to determine the next number
  (if directory doesn't exist yet, start at 001)
- `slug` is a short kebab-case descriptor derived from the description

---

## Step 3: Orient

Read `.scaffold/state.md` and `.scaffold/roadmap.md` silently. Know what's
active so the quick task doesn't conflict with in-progress work.

---

## Step 4: Discuss (only if --discuss flag is present)

If `--discuss` appears in the arguments:

1. Read the quick task context — state, roadmap, and any relevant code
2. Identify 2-4 concrete uncertainties about the issue or approach
3. Ask the user via AskUserQuestion with concrete options for each uncertainty
4. Capture the decisions for inclusion in the plan

If `--discuss` is NOT present, skip this step entirely.

---

## Step 5: Escape Hatch Check

Before writing the plan, assess complexity. If the approach looks like it needs:
- More than 3 implementation steps
- Architectural decisions or design choices
- Changes across multiple subsystems
- Significant investigation before acting

Then STOP and say:

> "This looks bigger than a quick fix. It needs [reason].
> Suggest running `/scaffold:plan` instead to scope it properly."

Do not proceed. Let the user decide whether to continue as quick or switch to
full plan/execute.

---

## Step 6: Write Plan

Write `.scaffold/quick/NNN-slug/plan.md`:

```markdown
# Quick Task NNN: [description]
**Date:** YYYY-MM-DD

## Goal
[1-2 sentences: what needs to happen and why]

## Approach
[Files to look at, likely fix, strategy — keep to ~3 steps]

## Done When
[Concrete condition: test passes, error gone, behavior correct]

## Decisions
[Only present if --discuss was used. Captures clarification outcomes.]
```

Omit the Decisions section if `--discuss` was not used.

---

## Step 7: Tell User

> "Quick task NNN planned: [description]
> Plan: `.scaffold/quick/NNN-slug/plan.md`
> Run `/scaffold:quick-execute` when ready."

**Do NOT update state.md.** Quick tasks run independently of the main workflow.
No disruption to the current plan/execute cycle.
