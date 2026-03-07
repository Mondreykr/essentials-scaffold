# The Handoff Gap: Mixed-Ownership Task Chains in Scaffold

> **RESOLVED** (2026-03-06) — All gaps described below are addressed in the
> current codebase. `plan.md` classifies 4 session types with distinct state
> routing. `checkpoint.md` preserves the plan pointer when incomplete `[USER]`
> tasks remain. `verify.md` reads the preserved pointer, walks each task
> against acceptance criteria, and routes deferred items only when all pass.
> Relevant commits: `7515121` ([USER] task support), `411a2be` (plan mode
> integration). The analysis below is retained for historical context.

## What Happened

A planning session produced a work sequence where AI tasks came first, followed
by user tasks (vault deployment, manual testing). The AI tasks were executed and
checkpointed successfully. At that point:

- **Roadmap** knew what needed doing (user tasks listed as `[ ]`)
- **State** knew the user was up next (Next Action said so)
- **No plan doc existed for the user tasks** -- the plan doc was scoped to AI
  execution and was effectively "consumed" by checkpoint

When the user later wanted to close the loop with `/scaffold:verify`, verify
had no plan doc to verify against. The "done when" criteria for the user tasks
lived only in the roadmap (as task descriptions) and informally in state.md.
Verify needs a plan doc with explicit acceptance criteria per task. Without one,
the scaffold loop can't close deterministically.

## The Core Issue

The scaffold workflow assumes a single-owner cycle:

```
plan -> execute -> checkpoint -> (loop)
```

This works when all tasks in a cycle belong to the same actor (AI). It breaks
when a cycle contains tasks for **two different actors** with a handoff between
them. The handoff creates a gap where:

1. The first actor's work is done and committed
2. The second actor's work hasn't started
3. The system artifact that defines "done" (the plan doc) has already been
   consumed or orphaned

## Factors That Make This Non-Trivial

### 1. Plan Doc Lifetime

A plan doc currently serves as an execution contract for a single run of
`/scaffold:execute`. Its lifecycle is: created by plan, consumed by execute,
cleaned up by checkpoint. But if a plan contains both AI and user tasks, the
plan doc needs to survive past checkpoint -- it still has unfulfilled tasks.
The question is how long a plan doc should remain "active" and what determines
when it's fully resolved.

### 2. Checkpoint's Completion Model

Checkpoint treats plan completion as binary: either the work is done (clear the
plan pointer, route deferred items) or it's not. It has no concept of "partially
done by design" -- where AI tasks are genuinely complete but user tasks are
intentionally deferred. If checkpoint clears the plan pointer, verify loses its
reference. If checkpoint preserves it, the pointer becomes stale for execute
(which has nothing left to do).

### 3. Task Ownership Ambiguity

Roadmap tasks and plan doc tasks have no ownership marker. There's no way to
distinguish "this task is for the AI to execute" from "this task is for the
human to do manually." Without this distinction, every command in the chain
(plan, execute, checkpoint, verify) has to guess or infer who owns what.

### 4. Verify's Contract Requirements

Verify is designed to check user-completed work against acceptance criteria. It
needs:
- A plan doc to read from (the contract)
- Tasks with clear "done when" conditions
- A way to identify which tasks are its responsibility (vs already handled by execute)

If the plan doc was consumed by checkpoint, or if tasks aren't marked by owner,
verify can't function. It either has nothing to verify against, or it tries to
re-verify work that execute already completed.

### 5. State.md as the Routing Mechanism

State.md's Next Action field is the only persistent pointer between commands
across `/clear` boundaries. It must correctly route to the right command:
- After plan: route to execute (or prep)
- After execute + checkpoint: route to... what?
  - If all tasks done: route to plan (next cycle)
  - If user tasks remain: route to verify, which needs the plan doc

The routing logic needs to account for the mixed-ownership case without
creating ambiguous or conflicting pointers.

### 6. The Temporal Gap

User tasks may take hours, days, or weeks to complete (e.g., deploying a DLL,
running manual tests, waiting for external approvals). During this gap:
- Multiple `/clear` cycles may happen
- The user may work on unrelated things
- Context about what "done" means drifts

The plan doc is the only artifact that can bridge this gap with deterministic
acceptance criteria. If it's been consumed or cleared, the gap has no bridge.

### 7. Roadmap as Implicit vs Explicit Contract

The roadmap contains task descriptions but not acceptance criteria. It's a
progress tracker, not a verification contract. Using roadmap alone as the
"what to verify" source means verify has to infer done-when criteria from
task descriptions -- which is fuzzy and defeats the purpose of a deterministic
verification step.

## The Invariant That Broke

The scaffold system has an implicit invariant: **every task that enters the
system must exit through a verification gate.** AI tasks exit through execute's
per-task verification + checkpoint. User tasks are supposed to exit through
verify. The gap occurs when there's no mechanism to ensure that user tasks get
a plan doc with acceptance criteria that persists until verify runs.

## What This Means for the Command Chain

The issue isn't isolated to one command. It touches the interaction between
four commands:

| Command    | Role in the gap                                              |
|------------|--------------------------------------------------------------|
| Plan       | Must recognize mixed-ownership work and produce artifacts    |
|            | that survive past the AI execution cycle                     |
| Execute    | Must know where to stop (AI boundary) without consuming      |
|            | the entire plan doc                                          |
| Checkpoint | Must know that "AI done" != "plan done" when user tasks      |
|            | remain, and preserve the plan pointer accordingly            |
| Verify     | Must find and use the surviving plan doc to check user tasks  |

The fix isn't in any single command -- it's in the contract between them about
plan doc lifecycle and task ownership.
