---
description: Session planning — triage, consult, scope, write plan
---

**Precondition:** Verify that all five scaffold files exist: CLAUDE.md,
`.scaffold/project.md`, `.scaffold/state.md`, `.scaffold/roadmap.md`,
`.scaffold/decisions.md`. If any are missing, stop and say:
"Scaffold files missing — run /scaffold:setup first."

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
- **Type:** build | validate | investigate | design | debug
- **Execute:** agent | direct
- **Why:** how it connects to the user's stated goal
- **Key files:** files to read or modify (helps agent tasks start with the right context)
- **Done when:** specific, verifiable condition
- **Verify by:** concrete action (command to run, behavior to check, output to see)

Execution mode routing:
- build / validate → `agent` (dispatch to general-purpose Agent subagent with fresh context)
- investigate / design / debug → `direct` (execute directly, user in loop)

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
- **Investigate:** tasks are questions to answer. Cap at 2-3 focused questions
  per session — investigation burns context fast. Each task includes:
  - **What:** the question to answer
  - **Done when:** question answered or enough known to decide next step
  - **Scratch file:** `.scaffold/scratch/YYYYMMDD-#-topic.md` — write findings
    here as you work so they persist outside context
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

Write the plan to the plan file. Also write a copy to
`.scaffold/plans/session-YYYY-MM-DD-[brief-slug].md` (create the directory if
needed). The `.scaffold/plans/` copy is what checkpoint reads — it's
project-local and reliable.

The plan file MUST be self-contained — after context clear, it will be the
ONLY thing guiding execution. Include:

1. **Project** — identifier for checkpoint matching:
   ```
   **Root:** [absolute path to project root]
   **Name:** [from .scaffold/project.md]
   ```
2. **Session goal** — what we're doing and why (from the discussion, not just docs)
3. **Context pointers** — which .scaffold/ files to read for project context
4. **Key decisions from discussion** — anything the user said that affects execution.
   Especially: concerns raised, constraints stated, direction chosen over alternatives.
5. **Tasks** — full task list with what/type/execute/why/key-files/done-when/verify-by
   For investigation tasks: include "Output to" and "Scratch file" fields.
6. **Deferred items (for awareness)** — work identified but not scoped to this
   session, with where it should go in the roadmap (Up next / Later). Listed
   visibly so the user and Claude see them during execution. If any turn out
   to be blocking, stop and discuss before pulling them in. Omit if nothing deferred.
7. **Decisions for decisions.md** — decisions made during the planning discussion
   that should be recorded at checkpoint. Omit if no decisions made.
8. **Execution notes:**
   - Use TodoWrite to track progress
   - Verify each task before marking complete
   - If verification fails: present findings, ask user, don't auto-fix
   - If task is bigger than expected: stop, re-scope, ask user
   - If uncertain about approach or encountering unexpected complexity: stop,
     present what you found, ask the user. Don't guess.
   - Prefer completing and verifying each task before starting the next
   - For agent tasks: launch a general-purpose Agent with the task description,
     key files, project context pointers, and verification criteria. Wait for
     completion. Review result. If verification passed, mark complete and
     present result. If failed, present to user and ask how to proceed.
   - For direct tasks: execute directly. Verify each step. If uncertain, stop
     and ask.
   - Between tasks: if the conversation is getting long (many tool calls,
     large code blocks), suggest checkpointing completed tasks and clearing
     context before continuing.
   - For investigation tasks: write findings to the designated scratch file as
     you work. This persists findings outside context.
   - If the user changes direction: suggest checkpoint completed work →
     /clear → /scaffold:plan for the new direction.
9. **Checkpoint reminder** — "When complete, suggest /scaffold:checkpoint.
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
- For agent tasks: launch a general-purpose Agent with the task description,
  key files, and verification criteria. Review result before proceeding.
- For direct tasks: execute directly, verify each step
- If verification fails: present findings, ask user
- If task is bigger than expected: stop, re-scope, ask user
- If uncertain about approach or encountering unexpected complexity: stop,
  present what you found, ask the user. Don't guess.
- Between tasks: if the conversation is getting long, suggest checkpointing
  completed work and clearing context before continuing
- If the user changes direction: suggest checkpoint → /clear → /scaffold:plan
- When all tasks done: suggest /scaffold:checkpoint (don't auto-invoke)

## Edge Cases

- **User wants something not on the roadmap:** User's direction wins. Roadmap is
  context, not mandate.
- **User doesn't know what to work on:** Present options from roadmap and state,
  help them choose.
- **Files are stale:** Flag in Phase 2, suggest /scaffold:checkpoint --audit first.
- **Mid-session pivot:** Stop current task. Suggest: checkpoint completed work →
  /clear → /scaffold:plan for the new direction.
- **Task bigger than expected:** Stop. Present what you found. Propose re-scoping.
- **Verification fails:** Present what failed. Ask user. Don't auto-fix.
- **Uncertainty:** If confused, finding multiple valid approaches, or hitting
  unexpected complexity — stop, present what you found, ask the user. Don't guess.
