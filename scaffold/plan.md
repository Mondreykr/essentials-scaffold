---
description: Session planning — triage, consult, scope, write plan
---

**Precondition:** Verify that `.scaffold/state.md` and `.scaffold/roadmap.md`
exist. If missing: "Scaffold files missing — run /scaffold:setup first."

## Phase 1: Triage

Read in this order. Do not present findings yet — just absorb context:
1. .scaffold/state.md — especially "Next session", "What's not working", "Open questions"
2. .scaffold/roadmap.md — especially "In progress", "Up next", "Current phase"
3. .scaffold/project.md — scope boundaries and success criteria
4. .scaffold/decisions.md — recent active decisions only
5. CLAUDE.md — constraints and tech stack

Assess (internally, for Phase 2):
- What's in progress? What was queued for "next session"?
- Are there blockers or open questions that need resolving first?
- Are any scaffold files stale (>7 days since last update)?
- What kind of work is likely needed? (investigate / design / build / validate / debug)

## Phase 2: Present and Consult

Present a brief structured assessment:

- **Where we are:** 1-2 sentences on current state
- **What the docs suggest:** what roadmap/state point to as next work
- **Flags:** blockers, stale files, contradictions, open questions

Then ask:

> "That's what I see in the scaffold files. What are you thinking?
> Do you have a direction in mind, concerns, or ideas?"

**CRITICAL — Do NOT skip this step. Do NOT propose tasks yet.**

Even if the scaffold files make the next step obvious, the user may have:
- Context that isn't captured in the files
- Concerns about the current approach
- A completely different direction in mind
- Questions they need answered before deciding

Rationalizations that are NOT valid reasons to skip consultation:
- "The roadmap clearly says X is next" — the user may have changed their mind
- "This is a continuation of previous work" — the user may want to pivot
- "The task is simple enough to just start" — the user wants to understand first
- "I already know what to do from the files" — the files may be stale or incomplete

STOP. Wait for the user to respond before proceeding.

## Phase 3: Propose Plan

After the user shares their direction, incorporate it and propose 2-5 concrete
tasks scoped to this session. The user's stated direction overrides whatever
the scaffold files suggest. If they conflict, follow the user.

For each task:
- **What:** one sentence describing the work
- **Why:** how it connects to the user's stated goal
- **Done when:** specific, verifiable condition
- **Verify by:** concrete action (command to run, behavior to check, output to see)

**Task sizing and scoping — what's "this session" vs. "later":**

Default to fewer tasks. 3 well-scoped tasks > 7 ambitious ones.

Scope to this session:
- Tasks that directly address the user's stated direction (from Gate 1)
- Tasks that unblock other work
- Tasks completable in a focused stretch (one clear unit of work)
- 2-5 tasks total

Defer to roadmap (capture in plan file "Deferred Items" section):
- Tasks identified during triage/discussion that aren't this session's focus
- Tasks that depend on this session's work completing first
- Tasks that would push beyond ~5 focused tasks
- Tasks the user flagged as "eventually" or "later"

The scoping heuristic: **if you're uncertain whether a task fits this session,
it doesn't fit.** Put it in Deferred Items. It'll route to roadmap at checkpoint.

If a task can't be stated in 1-2 sentences, it's too big — break it down
or defer parts.

**Route based on work type:**
- **Investigate:** tasks are questions to answer. Each task includes:
  - **What:** the question to answer
  - **Done when:** question answered or enough known to decide next step
  - **Output to:** which scaffold file(s) findings route to at checkpoint:
    - Findings that inform a decision → decisions.md
    - Findings that change scope → project.md
    - Findings that reveal bugs/issues → state.md "What's not working"
    - Findings that affect priorities → roadmap.md
    - General reference knowledge → state.md as session note
  The last investigation task should be: "Summarize findings and identify
  next steps" — this ensures investigation sessions produce actionable output,
  not just raw notes.
- **Design:** tasks are decisions to make; each produces a decisions.md entry
  with context, decision, rationale, and status
- **Build:** tasks are implementation steps with verification commands
- **Validate:** tasks are things to test/check; report results to state.md
- **Debug:** first task is ALWAYS "diagnose the root cause" before any fix attempt

**If in plan mode (recommended for substantial work):**

Write the plan to the plan file. The plan file MUST be self-contained — after
context clear, it will be the ONLY thing guiding execution. Include:

1. **Session goal** — what we're doing and why (from the discussion, not just docs)
2. **Context pointers** — which .scaffold/ files to read for project context
3. **Key decisions from discussion** — anything the user said that affects execution.
   Especially: concerns raised, constraints stated, direction chosen over alternatives.
4. **Tasks** — full task list with what/why/done-when/verify-by
   For investigation tasks: include "Output to" field specifying which scaffold
   file(s) findings should route to at checkpoint.
5. **Deferred items** — work identified but not scoped to this session, with
   where it should go in the roadmap (Up next / Later). Omit if nothing deferred.
6. **Decisions for decisions.md** — decisions made during the planning discussion
   that should be recorded at checkpoint. Omit if no decisions made.
7. **Execution notes:**
   - Use TodoWrite to track progress
   - Verify each task before marking complete
   - If verification fails: present findings, ask user, don't auto-fix
   - If task is bigger than expected: stop, re-scope, ask user
8. **Checkpoint reminder** — "When complete, suggest /scaffold:checkpoint.
   Checkpoint should read this plan file for deferred items and decisions."

Then call ExitPlanMode. The user will review and can edit the plan file
directly with Ctrl+G before approving.

**If NOT in plan mode:**

Present the plan and STOP. Wait for explicit approval.
"The plan seems reasonable so I'll start" is NOT user approval.
Wait for the user to say "go", "approved", "looks good", etc.

After approval, proceed to execute:
- Use TodoWrite to track tasks
- For each task: implement → verify → mark complete
- If verification fails: present findings, ask user
- If task is bigger than expected: stop, re-scope, ask user
- When all tasks done: suggest /scaffold:checkpoint (don't auto-invoke)

## Edge Cases

- **User wants something not on the roadmap:** User's direction wins. Roadmap is
  context, not mandate.
- **User doesn't know what to work on:** Present options from roadmap and state,
  help them choose.
- **Files are stale:** Flag in Phase 2, suggest /scaffold:checkpoint --audit first.
- **Mid-session pivot:** Stop current task. Ask if user wants to checkpoint progress
  before changing course.
- **Task bigger than expected:** Stop. Present what you found. Propose re-scoping.
- **Verification fails:** Present what failed. Ask user. Don't auto-fix.
