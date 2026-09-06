---
name: scaffold-go
description: Execute the active phase plan in a scaffold project — a thin executor. Requires a FINALIZED plan (validated against current code); refuses a draft or a stale plan and routes you to finalize. Loads the scope that state.md's Next points at and builds it under tight scope control. Writes project files (and optionally an investigation record) only; never scaffold truth or execution docs. Use whenever the user wants to execute a phase, implement the current plan, build the next thing, or resume in-progress work — even if they only say "go", "build it", "run the phase", or "let's implement this".
---

# scaffold-go

Execute exactly the phase plan `state.md` `## Next` points at. You are a **thin executor**: the approach was researched and approved at finalize (`/scaffold-plan --final`); you compute the plan's state, run only a **final & fresh** plan, and build its `## Scope` one item at a time. `## Scope` is the boundary.

**Precondition.** Read `.scaffold/state.md`. `## Next` must reference a phase plan at `.scaffold/milestones/NN-slug/phases/NN-slug.md`. If not, stop: "No active phase plan. Run /scaffold-plan to author one and set state.md Next, or just work without formal scope."

**Version guard.** Any doc with `schema_version: 1`, `type: milestone-plan` / `type: phase-brief`, or a milestone folder holding `plan.md` → stop: "Old scaffold format (pre-rename) — run /scaffold-cleanup to migrate first; the current skills will misread it."

**Boundary.** You MAY write project files (code, config, assets), drop an opportunistic `investigations/YYYYMMDD-slug.md`, and dispatch a fresh read-only subagent for the Step 5 scope check. You do NOT: touch `state.md`, `roadmap.md`, `architecture.md`, `project.md`, `knowledge/`, `glossary.md`, `decisions/`, `milestone.md`, or tick the phase checklist (all write-back is `checkpoint`'s); write under `milestones/archived/` (a live rule found there is restated by `checkpoint` in `architecture.md` or `knowledge/`); execute a draft or stale plan; research or propose an approach; propose or write an ADR; expand scope past the plan's items; answer the scope check yourself; build a *different* finding a second way without the user's ruling; run `/code-review` unasked.

---

## Step 1: Load scope

Read in order: the phase plan `## Next` names (its `## Scope` is what you execute); `state.md` (Active focus, and any resume precondition riding in `## Next`); the active `milestone.md`; `architecture.md`; the milestone's `spec/` if present (follow a pointer; for a predetermined milestone its `references/` are the live rulebook); `knowledge/` for orientation (the plan's `## Governed by` is the binding list, read in Step 3); `glossary.md` if present — name things in code the way it does.

## Step 2: Check the plan is executable

**First, is the phase already done?** If `milestone.md` ticks this phase, say so and stop. Check this before the freshness test, or a ticked phase whose code has since moved reads as stale.

Compute the plan's state from `## Targets` — ancestry plus a path-list comparison, no judgement:

1. **No `## Targets`** → **draft**. Stop, and do not research or propose an approach yourself:
   > "This plan isn't finalized. Run `/scaffold-plan --final` to validate it against the current code — or just work freeform (status → work → checkpoint)."
2. **`## Targets` present** → read its `_as of <sha>_` and ask *has anything moved that this plan did not declare?* (not "has the repo moved" — a phase spanning a `/clear`, or a `checkpoint` commit, moves it by construction):

   ```
   git merge-base --is-ancestor <sha> HEAD    # (1) still on this history?
   git diff --name-only <sha> --              # (2) what moved since — committed AND uncommitted
   git log --format=%H%x09%s <sha>..HEAD      # (3) which commits are checkpoint:/reconcile:
   ```

   - **(1) fails** (sha doesn't resolve or isn't an ancestor) → **stale**, no exemptions:
     > "Validated `as of <sha>`, which is not in this branch's history (rebase, force-push, or wrong branch). Re-finalize with `/scaffold-plan --final`."
   - **(2) lists a path** that is not matched by a `## Targets` path entry, not under `.scaffold/`, and not touched *solely* by `checkpoint:` / `reconcile:` commits from (3) (any other commit or an uncommitted edit on it counts) → **stale**. Stop and **name the files**:
     > "Validated `as of <sha>`; these moved outside the plan's declared targets: `<file>`, `<file>`. Re-finalize with `/scaffold-plan --final`."
   - **Otherwise** → **final & fresh**.

   Matching: an entry is a repo-relative path; a trailing `/` covers everything beneath. Entries naming an interface in prose are ignored. Untracked files never trip the gate. The three exemptions stand — do not tighten them: moving target files across a session boundary is exactly as safe as moving them item-by-item within one, `.scaffold/` drift is `plan`'s and `checkpoint`'s to catch, and a `checkpoint:` commit is scaffold's own bookkeeping and bounded repair of this work.

   No git → treat a plan with `## Targets` as fresh and say staleness can't be verified.

## Step 3: Starting point, read-set, confirm

**Done but not ticked?** Only `checkpoint` ticks, so check whether the scope deliverables already exist in the code (look in the `## Targets` files). If they do, do not rebuild: say so and route to `/scaffold-checkpoint`. Otherwise use Active focus to find where to pick up; if the user says part of the scope is done, skip it.

**`[USER]` items are not yours.** Skip each, say so, hand it to `checkpoint`'s USER task check, and exclude it from the `## Scope` you give the Step 5 agent (else it reports them as *not built*).

**Read the read-set before presenting.** Resolve every path in `## Governed by` and read each document whole; where the plan restates a rule, the document is current. Stop, build nothing, and route to `/scaffold-plan --final` if any holds:

- A listed path does not resolve, or the section is present but empty.
- No `## Governed by`, and `## Approach` lacks this line, matched literally:
  > Governed by: none — no `knowledge/` or `decisions/` document constrains this phase.
- A listed document and a named plan element (an `## Approach` step, a `## Scope` item, a `## Targets` entry) cannot both hold, and you can state which would have to be violated to satisfy the other. A rule the plan does not reach, or that constrains *how* rather than whether, is not a contradiction — execute under it.

> "`<path>` [doesn't exist / is empty / rules out `## Approach` step N: the rule, the element]. Nothing built this session[; items 1–N were built under the previous approach — the re-finalize decides what happens to them]. Re-finalize with `/scaffold-plan --final`."

Never pick between the rule and the approved approach — that is `plan`'s. This is not the unsatisfiable exit below: the scope holds, the phase stays wanted, the cursor stays.

**Then present scope and confirm the start** — do not re-propose the approach. Print what moved since the stamp as visibility, not a question:
> "Phase: [plan filename], final & fresh. Since `<sha>`: [N] files moved, all declared targets or `.scaffold/` — [list]. [N] scope items to execute [out of M — N already done]. Starting now."

Nothing moved → say "nothing has moved since `<sha>`".

## Step 4: Execute

One scope item at a time: implement (project files only), confirm "Item [N] done: [what was done]. Moving to [N+1]." A single-item plan: "Done: [what was done]." Then Step 5, always.

Research output worth keeping (a spike, a gap map) → `.scaffold/investigations/YYYYMMDD-slug.md` with `type: investigation` / `schema_version: 2` / `updated: <today>` frontmatter — the one scaffold doc you write; born conformant; never obligatory. A candidate ruling stays as analysis there for `checkpoint` to propose as an ADR.

## Step 5: Scope check — always, by a fresh agent

Dispatch **one fresh read-only subagent** with exactly two things — the plan's `## Scope` verbatim (minus `[USER]` items) and the phase's diff — and three questions:

1. **Missing** — which scope items are not built?
2. **Different** — which were built differently from what the plan named?
3. **Unasked** — what is in this diff that no scope item called for?

The diff: `git diff <sha> -- . ':(exclude).scaffold'` from the `## Targets` stamp, plus untracked files the phase added. Exclude `.scaffold/` (a mid-phase checkpoint's doc commits would read as unasked); never bare `git diff` (unstaged only). Tell the agent to refuse rather than report clean on an empty diff. No git → pass the current `## Targets` files plus anything new, and say the basis was files.

Never answer these yourself — the value is the reader being cold; give it no conversation and no reasoning behind any choice. One agent, not several. Brief it that a plausible, well-built, unrequested change is a finding, not a bonus, and a comment does not excuse it.

Report: "Scope check (fresh agent): [N] missing, [N] different, [N] unasked. [Each, one line.]" Then act: a **missing** item → build it. An **unasked** change → name it and revert on the user's nod, never silently (the agent cannot tell surplus from work the user authorized or a checkpoint repair). A **different** finding → report; the user rules. If you changed anything, re-run the check. Hand what remains to `/scaffold-checkpoint`.

Then offer, don't run: "Run a deeper review on this diff (`/code-review` if you have it), or go straight to `/scaffold-checkpoint`?" Never run it automatically; it may not be installed.

## Step 6: Complete

> "Phase scope complete. Run /scaffold-checkpoint."

Do not tick the checklist. Surface a resume precondition you resolved (so `checkpoint` updates `## Next`) and any ground-level issue you hit but left alone — `checkpoint` disposes of it, mostly by fixing in place; surfacing is not filing, and not a way to bank skipped scope.

---

## Scope control

- Out-of-scope discovery: "Found: [issue]. Out of scope — will note for checkpoint." Don't act.
- User asks for out-of-scope work: "That's outside this phase's scope. Add it to the plan via /scaffold-plan, or do it now and note for checkpoint?"
- No added features, surrounding refactors, or "while I'm here" improvements unless asked.

## Escape hatch — two exits

A scope item is far bigger than expected, needs an architectural decision, touches unexpected systems, or the approach won't work → STOP. One question decides the exit: *can the scope be satisfied at all?*

**Yes, just not as scoped** → "This is more complex than the plan anticipated: [explain]. Re-scope with /scaffold-plan, or continue?"

**No** — the scope contradicts the code, two items can't both hold, a required fact doesn't exist → do not offer to continue:
> "This plan is not satisfiable as written. The contradiction: [what the plan requires, what is actually true, why both cannot hold]. Nothing further built."

State it once, then send the user to `/scaffold-checkpoint` before anything else — you write no docs, so until checkpoint abandons the phase `## Next` still points here and the next session hits the same wall. Do not offer `/clear` as a peer option. Do not propose a fix or pick a reading of the scope that happens to work — choosing a reading decides the contradiction, and that is `plan`'s. An item hinging on an unmade architectural decision always stops here.

## Context window awareness

Long session, several large items behind you → finish the current item, then: "Context is getting long. Suggest /scaffold-checkpoint to save progress, then /clear and /scaffold-status to continue fresh." Don't start a fresh item late in a long session.
