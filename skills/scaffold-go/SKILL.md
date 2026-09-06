---
name: scaffold-go
description: Execute the active phase plan in a scaffold project — a thin executor. Requires a FINALIZED plan (validated against current code); refuses a draft or a stale plan and routes you to finalize. Loads the scope that state.md's Next points at and builds it under tight scope control. Writes project files (and optionally an investigation record) only; never scaffold truth or execution docs. Use whenever the user wants to execute a phase, implement the current plan, build the next thing, or resume in-progress work — even if they only say "go", "build it", "run the phase", or "let's implement this".
---

# scaffold-go

Execute exactly the phase plan that `state.md`'s `## Next` points at. `go` is a **thin
executor**: it does not research or propose an approach — that was done and approved at
**finalize** (`/scaffold-plan --final`). `go` computes the plan's state, and only a
**final & fresh** plan runs. Scope-controlled — the plan's `## Scope` is the boundary,
and out-of-scope discoveries route to checkpoint rather than expanding the work.

**Precondition.** Read `.scaffold/state.md`. `## Next` must reference a phase plan at
`.scaffold/milestones/NN-slug/phases/NN-slug.md`. If not, stop: "No active phase plan.
Run /scaffold-plan to author one and set state.md Next, or just work without formal scope."

**Version guard.** If any `.scaffold/` doc carries `schema_version: 1`, a `type:
milestone-plan` / `type: phase-brief`, or a milestone folder holds a `plan.md` (the current
name is `milestone.md`), the repo predates the current format — stop: "Old scaffold format
(pre-rename) — run /scaffold-cleanup to migrate first; the current skills will misread it."

**Boundary — the one place this skill states it.** Go MAY: write project files (code, config, assets); drop an opportunistic `investigations/YYYYMMDD-slug.md`; dispatch a fresh read-only subagent for the Step 5 scope check.

Go does NOT: touch scaffold truth or execution docs — `state.md`, `roadmap.md`, `architecture.md`, `project.md`, `knowledge/`, `glossary.md`, `decisions/`, the milestone's `milestone.md` — or tick its phase checklist; all scaffold write-back, including marking the phase complete, is `/scaffold-checkpoint`'s. Nor does it: execute a draft or stale plan (refuse, route to finalize); research or propose an approach (that is `plan`'s finalize pass — you execute the approved one); propose or write ADRs (Adam-gated, via plan/checkpoint); expand scope past the plan's items; answer the Step 5 scope check itself (dispatch a fresh agent — self-review is worth nothing); build a *different* finding a second way without the user's ruling; or run `/code-review` automatically (offer it).

**Never write into `.scaffold/milestones/archived/`.** A closed milestone records what was built, not what the code does now — read it freely, edit it never. A rule found there that is still live gets restated in `architecture.md` or `knowledge/`.

---

## Step 1: Load scope

`state.md`'s `## Next` is the single authority for what's active — the milestone and the
current phase plan. Read these in order:

1. The phase plan referenced in `## Next` — its `## Scope` is what you execute.
2. `.scaffold/state.md` — Active focus context and `## Next` (which carries any
   precondition on resuming, e.g. "reseed the dev DB first"). There is no `## Notes`
   section.
3. The active milestone's `milestone.md` — objectives and the phase's place in the checklist.
4. `.scaffold/architecture.md` — technical truth (stack, tenancy, data-access,
   conventions, how to run).
5. The active milestone's `spec/` if present (the contract, or a pointer to one elsewhere)
   — for a predetermined milestone its `references/` are the live rulebook.
6. `.scaffold/knowledge/` — durable domain/behavioral rules relevant to the plan
   (orientation only; the plan's `## Governed by` is the binding list, read in full at Step 3).
7. `.scaffold/glossary.md` if present — name things in code the way the glossary names them.

## Step 2: Check the plan is executable (deterministic)

**First, check the phase isn't already done.** Read the `milestone.md` checklist: if the phase this plan covers is already ticked, say so and stop — nothing to execute. Do this *before* the freshness test below, or a ticked phase whose code has since moved computes as **stale** and you send the user to re-finalize a plan that was already built.

`go` runs only a **final & fresh** plan. Compute the state from the plan's `## Targets`
section — this is ancestry plus a path-list comparison, it judges nothing:

1. **No `## Targets`** → **draft**. Stop:
   > "This plan isn't finalized. Run `/scaffold-plan --final` to validate it against the
   > current code — or just work freeform (status → work → checkpoint)."

   Do **not** try to research or propose an approach yourself — a draft is `plan`'s to
   finalize, and freeform is scaffold's existing wing-it path, not a `go` override.
2. **`## Targets` present** → read its `_as of <sha>_` stamp and ask **whether the stamp still holds**. The question is *not* "has the repo moved?" — a phase that spans a `/clear` moves the repo by construction, and so does `checkpoint` committing `.scaffold/`. The question is **"has anything moved that this plan did not declare?"** Two commands answer it:

   ```
   git merge-base --is-ancestor <sha> HEAD    # (1) still on this history?
   git diff --name-only <sha> --              # (2) what has moved since — committed AND uncommitted
   ```

   - **(1) fails** (the sha doesn't resolve, or isn't an ancestor of HEAD) → **stale**, no exemptions. The plan was validated against a history that no longer exists — a rebase, a force-push, a different branch. Stop:
     > "Validated `as of <sha>`, which is not in this branch's history (rebase, force-push, or wrong branch). Re-finalize with `/scaffold-plan --final`."
   - (2) lists a path that is neither matched by a `## Targets` path entry, nor under `.scaffold/`, nor touched by a `checkpoint:`/`reconcile:` commit since the stamp (`git log --format=%H%x09%s <sha>..HEAD` names them — `checkpoint` commits its repair-licence tidy-ups under those subjects, and refusing a resume because the last save removed a dead import is the same false refusal the other two exemptions exist to prevent) → **stale**. Stop, and **name the files** — a refusal the user can't check is a refusal they'll learn to dismiss:
     > "Validated `as of <sha>`; these moved outside the plan's declared targets: `<file>`, `<file>`. Re-finalize with `/scaffold-plan --final`."
   - **Otherwise** → **final & fresh**. Proceed.

   **Matching a path against `## Targets`:** an entry is a repo-relative path; a trailing `/` covers everything beneath it. `## Targets` entries that name an *interface or surface* in prose rather than a path are ignored by this comparison. Untracked files never trip the gate (`git diff` doesn't list them, and that is correct — they aren't part of the validated code state).

   Why these three are exempt, so you don't "helpfully" tighten this back: you already move target files item-by-item within a single session with no re-check — the code moving *is* executing — so moving them across a session boundary is exactly as safe. And `.scaffold/` drift belongs to a different defense entirely (`plan`'s pivot sweep, `checkpoint`'s coherence sweep), never to this check. A `checkpoint:`/`reconcile:` commit is the third case for the same reason: it is scaffold's own bookkeeping and its bounded repair of *this* work, not a stranger's change to code the plan didn't declare.

(If the repo has no git, there is no sha to check — treat a plan with `## Targets` as
fresh and note that staleness can't be verified without git.)

## Step 3: Determine starting point

**Check for already-completed work.** Read the `milestone.md` checklist. If the phase this
plan covers is already ticked (checkbox + date), say so and stop — nothing to execute.

**The checkbox is not the only done-signal.** Only `checkpoint` ticks it, so a phase can
be *done but not yet ticked* — e.g. a context crash between `go` and `checkpoint`. Before
executing, check whether the plan's scope deliverables **already exist in the code**
(the `## Targets` files are where to look). If they exist, do NOT rebuild: say so and
route to `/scaffold-checkpoint` to record the completion. Only within a genuinely
in-progress phase do you use Active focus to find where to pick up.

**`[USER]` scope items are not yours to build.** A scope line marked `[USER]` is a human-owned deliverable — creating an OAuth app, provisioning a key. Skip it, say you skipped it, and hand it to `/scaffold-checkpoint`'s USER task check. Exclude `[USER]` items from the `## Scope` you hand the Step 5 agent, or it reports them as *not built* and Step 5's disposition rule tells you to build them — which is exactly the thing this rule forbids.

**Use Active focus for resume context** — it describes where the work currently sits; use
it to understand where to resume, especially after a pause. If the user says part of the
scope is already done, skip it.

**Then read the plan's read-set before you present the scope.** `## Governed by` lists the `.scaffold/knowledge/` and `.scaffold/decisions/` documents whose rules bind this phase. Resolve every path and read the whole document — a rule the plan points at is a rule you are executing under, and where the plan restates one, the document is current. Every check below runs at load, before anything is announced; a refusal issued after "Starting now" teaches the user to dismiss this skill's gates.

Stop, build nothing, and route to `/scaffold-plan --final` if any of these holds:

- A listed path does not resolve, or the section is present but empty.
- The plan has no `## Governed by` and `## Approach` does not carry this line, matched literally (the wording is fixed so this is a grep, not a judgement):
  > Governed by: none — no `knowledge/` or `decisions/` document constrains this phase.
- A listed document and a named plan element — an `## Approach` step, a `## Scope` item, a `## Targets` entry — cannot both hold, and you can state which would have to be violated to satisfy the other. A rule the plan does not reach, or that constrains *how* rather than whether, is not a contradiction: proceed and execute under it. Executing under these documents is the normal result.

> "`<path>` [doesn't exist / is empty / rules out `## Approach` step N: the rule, the element]. Nothing built this session[; items 1–N were built under the previous approach — the re-finalize decides what happens to them]. Re-finalize with `/scaffold-plan --final`."

On a contradiction `go` never picks between the rule and the approved approach — that choice is `plan`'s. This is **not** the "not satisfiable as written" exit below: the scope still holds and the phase is still wanted, so it is never abandoned and the cursor stays on this plan.

**Only then present scope and confirm the start** (the approach was approved at finalize —
you do **not** re-propose it). **Print what has moved since the stamp** — not as a question,
as visibility. A gate that passes silently teaches nothing; a gate that shows its work is
what makes the refusing case worth reading:
> "Phase: [plan filename], final & fresh. Since `<sha>`: [N] files moved, all declared
> targets or `.scaffold/` — [list them]. [N] scope items to execute [out of M — N
> already done]. Starting now."

If nothing has moved since the stamp, say "nothing has moved since `<sha>`" rather than
printing an empty list.

## Step 4: Execute

Execute scope items one at a time. For each:

1. Implement the changes (project files only).
2. Confirm: "Item [N] done: [what was done]. Moving to [N+1]."
3. Move to the next.

For single-item plans, combine the item confirmations: "Done: [what was done]." Then go to
Step 5 — the scope check runs on every phase, single-item included.

If the work produces a research/analysis output worth keeping (a spike, a gap map, a
security investigation), write it to `.scaffold/investigations/YYYYMMDD-slug.md` (date as
`YYYYMMDD`, no hyphens). Stamp it with `type: investigation` / `schema_version: 2` /
`updated: <today>` frontmatter — it is the one scaffold doc `go` writes, and it must be
born conformant. Opportunistic — nothing obligates you to create one. If that
research yields a candidate ruling, leave the analysis here and let `/scaffold-checkpoint`
*propose* the ADR (decisions are Adam-gated; `go` never writes one).

## Step 5: Scope check (always — a fresh agent, not you)

When the scope items are done, **dispatch one fresh read-only subagent** (Explore, or general-purpose with no write tools) and give it two things: the plan's `## Scope` verbatim, and the phase's full diff. Ask it exactly three questions:

1. **Missing** — which scope items are not built?
2. **Different** — which were built differently from what the plan named?
3. **Unasked** — what is in this diff that **no scope item called for**?

Get the diff right — the check is worthless against the wrong one. Diff against the sha the plan was validated at, from `## Targets`' `_as of <sha>_`: `git diff <sha> -- . ':(exclude).scaffold'` plus any untracked files the phase added. **Exclude `.scaffold/`**: on a phase resumed across a checkpoint the span from the stamp legitimately contains that checkpoint's own doc commits, and the agent would report them as *unasked* work — a false finding that trains the same dismissal habit the freshness gate was fixed to avoid. The scope check judges code against scope, not scaffold's bookkeeping. **Not bare `git diff`** — it shows only unstaged work, so a phase that staged or committed mid-run would hand the agent nothing. Tell the agent to refuse rather than report clean if the diff it receives is empty; a check that passes on empty input is worse than no check. No git: pass the working tree's current state of the `## Targets` files plus anything new the phase created, and say in the report that the basis was files, not a diff.

**Dispatch it; never answer these yourself.** The value is entirely in the reader being cold — a model reviewing its own work finds nothing. So the agent gets the scope and the diff and nothing else: not this conversation, not the reasoning behind any choice. One agent, not several: two reads of the same diff converge on a compromise and cost double.

Question 3 is the one no other check in scaffold performs — every other pass hunts for work that is *missing*. Brief the agent explicitly that a plausible, well-built, unrequested change is a finding, not a bonus, and that a rationale in the code or a comment does not excuse it.

Report what came back:
> "Scope check (fresh agent): [N] missing, [N] different, [N] unasked. [Each, one line.]"

Then act on it — these are code findings, and this is the skill that writes code. A *missing* scope item: build it, it was always in scope (a `[USER]` item is never "missing" — it was excluded above). An *unasked* change: **name it and revert on the user's nod — never silently.** The agent is cold by construction, so it cannot tell surplus work from something the user authorized out of scope during this session, or from a repair a mid-phase `checkpoint` committed; reverting on the agent's word alone deletes approved work and the user never sees it go. A *different* finding: report it and let the user rule — building it a second way is a decision, not a fix. If you changed anything, re-run the check. Then report what's left, and hand the remainder to `/scaffold-checkpoint` to dispose of.

Then offer, don't run:
> "Run a deeper review on this diff (`/code-review` if you have it), or go straight to `/scaffold-checkpoint`?"

A deeper review is a separate decision with its own cost. **Never run one automatically**, and don't block on one existing — `/code-review` is a Claude Code native command, not part of scaffold, so it may not be available.

## Step 6: Complete

When all scope items are done and the scope check has been reported:
> "Phase scope complete. Run /scaffold-checkpoint."

Do NOT tick the `milestone.md` checklist yourself — checkpoint marks the phase complete after
verifying. If you resolved a resume precondition that `## Next` warned about (e.g.
re-seeded the dirty dev DB), surface it so `checkpoint` can update `## Next` — you don't
write `state.md` yourself. Likewise surface any ground-level issue you hit but left alone —
`checkpoint` decides its disposition, and most such issues are **fixed in place there, not
parked**: `## Deferred` admits an item only if it needs a decision, is materially out of
scope, or is real work that can't ride along safely. Surfacing it is not the same as filing
it, and it is not a way to bank scope you skipped.

---

## Scope control

The plan's `## Scope` is your scope. Do not expand beyond it.

- Out-of-scope discoveries: note for checkpoint, don't act.
  > "Found: [issue]. Out of scope — will note for checkpoint."
- If the user asks for work outside scope:
  > "That's outside this phase's scope. Add it to the plan via /scaffold-plan, or do it
  > now and note for checkpoint?"
- Do NOT add features, refactor surrounding code, or make "while I'm here" improvements
  unless the user explicitly asks.

## Escape hatch — two exits

If a scope item is significantly bigger than expected, needs an architectural decision,
touches unexpected systems, or the approach won't work — STOP. Which exit depends on
whether the plan can still be satisfied at all:

**Still buildable, just not as scoped** → offer the choice:
> "This is more complex than the plan anticipated: [explain]. Re-scope with /scaffold-plan,
> or continue?"

**Not satisfiable as written** — the scope contradicts what the code is, two scope items
can't both hold, or the plan needs a fact that doesn't exist → **don't offer to continue:**
> "This plan is not satisfiable as written. The contradiction: [what the plan requires, what
> is actually true, why both cannot hold]. Nothing further built."

That second one is a **legitimate finished outcome, not a failed phase.** State it once and stop — then send the user to `/scaffold-checkpoint` before anything else, and say why: you write no scaffold docs, so nothing on disk records the contradiction and `## Next` still points at this plan. Until checkpoint abandons the phase, the next session reads the cursor, runs `go`, and walks into the identical wall. Do not offer `/clear` as a peer option here. Do not propose a fix, and do not pick a reading of the scope that happens to work and
build that — choosing a reading *is* deciding the contradiction, which is not `go`'s to
decide. Reporting it is the deliverable; `/scaffold-checkpoint` records it (it abandons the
phase, which clears the cursor so a resuming session doesn't re-derive the same wall).

A scope item that hinges on an unmade architectural decision always stops here: ADRs are
Adam-gated and routed through `/scaffold-plan`, never invented mid-execution.

## Context window awareness

If the session has grown long mid-execution and several large scope items are behind you,
complete the current item, then suggest:
> "Context is getting long. Suggest /scaffold-checkpoint to save progress, then /clear and
> /scaffold-status to continue fresh."

Don't start a fresh scope item late in a long session — checkpoint first.

---
