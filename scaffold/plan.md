---
description: Session planning -- triage, consult, scope, write plan
---

**Precondition:** Verify that all five scaffold files exist: CLAUDE.md,
`.scaffold/project.md`, `.scaffold/state.md`, `.scaffold/roadmap.md`,
`.scaffold/decisions.md`. If any are missing, stop and say:
"Scaffold files missing -- run /scaffold:setup first."

---

## Behavioral Principle: User Comprehension

User comprehension is a prerequisite for forward progress. When the user
expresses uncertainty -- "I don't understand", "help me understand", "I'm
not sure", "what does that mean", or any language signaling confusion --
that becomes the top priority before the planning flow continues.

**How to respond to expressed uncertainty:**

Use AskUserQuestion to offer 2-4 concrete aspects the user might be
uncertain about. Let them point to what needs clarification rather than
having to articulate it from scratch. Then address only what they selected.

Example -- user says "I'm not sure about this task":
  > "What's unclear about [task]?"
  > - What it actually does
  > - Why it comes before the other work
  > - What happens if it doesn't go as expected
  > - All of the above

This reduces the cognitive load of expressing confusion. The user clicks
instead of having to formulate the right question.

**When presenting options and decisions throughout planning:**

Explain choices in terms of outcomes the user cares about, not
implementation details. If a concept is technical, lead with what it
means for the project in plain terms.

**What this does NOT mean:**

- Don't probe for hidden uncertainty -- respond to expressed uncertainty
- If the user says "yes", "proceed", or gives a clear affirmative, move
  forward. Don't second-guess clear signals.
- Don't quiz after every statement -- read the room
- Don't be patronizing -- if they clearly understand, keep moving
- Don't hold progress hostage to perfect understanding of every detail

---

## Phase 1: Triage (silent)

Read in this order. Do not present findings yet -- just absorb context:
1. .scaffold/state.md -- Status, Current Position, Next Action, Blockers, Open Questions
2. .scaffold/roadmap.md -- phase structure, `[IN-PROGRESS]` phase, task states
3. .scaffold/project.md -- scope boundaries and success criteria
4. .scaffold/decisions.md -- recent active decisions only
5. CLAUDE.md -- constraints and tech stack

Scan `.scaffold/investigations/` -- if the directory exists and contains files,
note them. They may contain prior research relevant to the current planning
session. Read any that look relevant based on filename.

Assess (internally, for Phase 2):
- Which phase is `[IN-PROGRESS]`? What tasks are `[x]`, `>> `, or `[ ]`?
- Are there blockers or open questions that need resolving first?
- Are there blockers that are stale or already resolved? (If clearly resolved,
  flag for removal and routing to decisions.md during Phase 3.)
- Are any scaffold files stale (>7 days since last update)?
- Is there a pending execute (state.md Next Action has a plan pointer)?
- What kind of work is likely needed? (investigate / design / build / validate / debug)
- Are there investigation files that inform the current phase?

---

## Phase 2: Consult (interactive -- WAIT for user)

Present a brief structured assessment:

- **Where we are:** 1-2 sentences on current state (phase, recent completions)
- **What the docs suggest:** what roadmap/state point to as next work
- **Flags:** blockers (including stale/resolved ones), stale files, contradictions, open questions, pending execute
- **Prior research:** if investigation files exist, note them briefly

Then ask:

> "That's what I see in the scaffold files. What are you thinking?
> Do you have a direction in mind, concerns, or ideas?"

**CRITICAL -- Do NOT skip this step. Do NOT propose tasks yet.**

Even if the scaffold files make the next step obvious, the user may have:
- Context that isn't captured in the files
- Concerns about the current approach
- A completely different direction in mind
- Questions they need answered before deciding

Rationalizations that are NOT valid reasons to skip consultation:
- "The roadmap clearly says X is next" -- the user may have changed their mind
- "This is a continuation of previous work" -- the user may want to pivot
- "The task is simple enough to just start" -- the user wants to understand first
- "I already know what to do from the files" -- the files may be stale or incomplete

STOP. Wait for the user to respond before proceeding.

---

## Phase 3: Propose Roadmap Changes (interactive -- user approves)

After the user shares their direction, determine what roadmap changes are needed.
The user's stated direction overrides whatever the scaffold files suggest. If
they conflict, follow the user.

**Determine the plan path:**

1. **State-only session** -- brainstorming, roadmap restructuring, research that
   doesn't produce codebase changes. No execute step needed.
2. **Execution session** -- codebase changes needed. Will produce a plan doc
   for `/scaffold:execute`.

**Propose roadmap changes:**

Show proposed changes to roadmap.md:
- New tasks to add (and which phase)
- Tasks to reorder or move between phases
- Items to move to Backlog
- New phases to create
- Phase status changes (if applicable)

Format proposals clearly so the user can review:
```
Proposed roadmap changes:
- Phase 2 -- [Title]: add "Task X", add "Task Y"
- Backlog: move "Item Z" from Phase 3
- [etc.]
```

**Wait for explicit approval before writing changes to roadmap.md.**

If the user modifies the proposal, incorporate their changes. Write the
approved changes to `.scaffold/roadmap.md`. Update the `<!-- Last updated -->`
date.

**If state-only session:** Skip to Phase 5 (produce plan document, update state).

---

## Phase 4: Scope Execute (interactive -- user approves, execution sessions only)

From the roadmap tasks in the `[IN-PROGRESS]` phase, propose which tasks are
in scope for the next execute. This is the "what's the contract for execute?" step.

Present the candidate tasks and ask:
> "Which of these should be in scope for the next execute?
> [list tasks with brief descriptions]
> All of them, or a subset?"

The user controls ambition level -- they decide how many tasks to include.
Default to fewer tasks. 3 well-scoped tasks > 7 ambitious ones.

**Task sizing:**
- If a task can't be stated in 1-2 sentences, it's too big -- break it down
- If you're uncertain whether a task fits this execute, defer it
- Investigation tasks: cap at 2-3 focused questions per execute

Wait for the user to confirm scope before proceeding.

**First-time phase activation check:**

If this is the first execute targeting this phase (just promoted from `[PLANNED]`),
review task sequence:

> "This is the first execute for Phase N. Here are the tasks in order:
> 1. [Task A]
> 2. [Task B]
> ...
> Does this sequence make sense, or should any tasks be reordered?"

Wait for confirmation. If reordered, update roadmap.md. Runs once per phase.

---

## Phase 5: Produce Plan Document + Update State

**Write the plan doc** to `.scaffold/plans/YYYYMMDD-NN-phase-N-slug.md`
(create the directory if needed).

**Naming convention:**
- `YYYYMMDD` -- date without dashes
- `NN` -- zero-padded sequence counter. Scan `.scaffold/plans/` for existing
  files starting with today's date to determine NN. First file of the day is 01.
- `phase-N` -- primary phase number (use the primary phase when a plan spans phases)
- `slug` -- brief descriptor

The plan doc MUST be self-contained -- after `/clear`, it will be the ONLY thing
guiding execution. Include:

```markdown
**Root:** [absolute path to project root]
**Name:** [from .scaffold/project.md]

## Session Goal
[what and why]

## Context Pointers
[which .scaffold/ files to read]

## Key Decisions
[from the planning discussion]

## Tasks

### Task: [title]
- **What:** one sentence
- **Type:** build | validate | investigate | design | debug
- **Why:** connection to goal
- **Done when:** specific condition

### Task: [title]
...

## Deferred Items
[if any -- route targets specified. Omit section if nothing deferred.]

## Decisions for decisions.md
[if any -- omit if no decisions made]

## Execution Notes
- Verify each task before marking complete
- If verification fails: present findings, ask user, don't auto-fix
- If task is bigger than expected: stop, re-scope, ask user
- If uncertain about approach or encountering unexpected complexity: stop,
  present what you found, ask the user. Don't guess.
- Prefer completing and verifying each task before starting the next
- Between tasks: if the conversation is getting long, suggest checkpointing
- If the user changes direction: suggest checkpoint completed work ->
  /clear -> /scaffold:plan for the new direction

## Checkpoint Reminder
When complete, run /scaffold:checkpoint.
Checkpoint reads this plan file for deferred items and decisions.
```

**For investigation tasks**, additionally include in the task:
```
- **Output to:** `.scaffold/investigations/YYYYMMDD-NN-slug.md`
```
This tells execute where to write findings.

**Tasks do NOT include key-files or verify-by fields.** Those come from
`/scaffold:prep` if it runs. Tasks contain: what, type, why, done-when
(and output-to for investigation tasks).

**For state-only sessions:** The plan doc records what was discussed/changed
instead of tactical execution detail. It serves as a session record.

**Update state.md:**
- Status -> "planning complete" (execution session) or "idle" (state-only)
- Current Position -> reflect any roadmap changes made
- Next Action ->
  - Execution session (complex tasks): "Run `/scaffold:prep` then `/scaffold:execute`.
    Plan: `.scaffold/plans/YYYYMMDD-NN-phase-N-slug.md`"
  - Execution session (simple tasks): "Run `/scaffold:execute`.
    Plan: `.scaffold/plans/YYYYMMDD-NN-phase-N-slug.md`"
  - State-only session: "No execute needed -- state documents updated.
    Run /scaffold:plan to determine next steps."
- Update Blockers and Open Questions if they changed during planning
- Update the `<!-- Last updated -->` date

**Prep recommendation rule of thumb:** If tasks are `type: build` or
`type: investigate` and touch unfamiliar code, recommend prep. If tasks are
simple fixes, config changes, or the user knows the codebase well, skip prep.

**If in plan mode:** Call ExitPlanMode after writing files. The user will review
and can edit the plan doc directly before approving.

---

## Phase 6: Summary

Present what was updated and where:
- Roadmap changes written
- Plan doc location
- State.md updates

**If execution session (prep recommended):**
> "Run `/scaffold:prep` then `/clear` then `/scaffold:execute`,
> or `/clear` then `/scaffold:execute` to skip prep."

**If execution session (prep not needed):**
> "Run `/scaffold:execute` to begin, or `/clear` then `/scaffold:execute`
> for a fresh context window."

**If state-only session:**
> "State documents updated. No execution needed."

---

## Edge Cases

- **User wants something not on the roadmap:** User's direction wins. Roadmap is
  context, not mandate. Add to roadmap during Phase 3.
- **User doesn't know what to work on:** Present options from roadmap and state,
  help them choose. Stay in Phase 2 until they have direction.
- **Files are stale:** Flag in Phase 2, suggest running checkpoint --audit first
  or updating files during this plan session.
- **Pending execute exists:** Flag in Phase 2. User decides: run the pending
  execute, or re-plan (which replaces the old plan pointer).
- **Mid-planning pivot:** If the user changes direction during planning, restart
  from Phase 3 with the new direction. Don't carry stale proposals forward.
- **No codebase changes needed:** State-only path. Update roadmap/state, produce
  record document, done.
