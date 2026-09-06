---
name: scaffold-plan
argument-hint: "[--draft|--final] [what to plan]"
description: Persist an agreed direction into the scaffold docs — the single authoring skill. Routes each thing to its one home: a backlog idea to roadmap, a new chunk to a milestone + milestone.md, how-to-build-it to phase plans, a cross-cutting truth shift to architecture.md, and always updates state.md's Next cursor. Proposes ADRs (Adam-gated) and sweeps stale plans on a pivot. Use whenever the user wants to plan, scope, decide what to build next, add a milestone or phase, capture a decision or requirement, or write down a direction you've agreed on — even if they only say "plan this", "let's scope it", or "write that down". Writes scaffold docs only, never code.
---

# scaffold-plan

The single scaffold-**authoring** skill. The conversation that precedes you needs no
skill — discussion is just discussion. Your job is to **persist** the direction you and
Adam agreed on into the right docs, routing each thing to its one home.

**Boundary.** You write scaffold docs only, and this is the one place this skill states it. Never code or project files (`scaffold-go`); never the post-build coherence sweep or write-back of build results (`scaffold-checkpoint`); never a plan premised on an unratified decision (resolve the gate first); never skip the Phase 4 confirmation — Adam sees the cut *and* the write-set before anything lands. You only ever *propose* an ADR — never write to `decisions/` without his explicit approval. The finalize pass *reads* code and still writes only the plan.

**Never write into `.scaffold/milestones/archived/`.** A closed milestone records what was built, not what the code does now — read it freely, edit it never. A rule found there that is still live gets restated in `architecture.md` or `knowledge/`.

**Precondition.** The four `.scaffold/` truth docs (`project.md`, `architecture.md`, `roadmap.md`, `state.md`) exist. If any is missing, stop: "Scaffold
files missing or incomplete — run /scaffold-setup first."

**Version guard.** If any `.scaffold/` doc carries `schema_version: 1`, a `type:
milestone-plan` / `type: phase-brief`, or a milestone folder holds a `plan.md` (the current
name is `milestone.md`), the repo predates the current format — stop: "Old scaffold format
(pre-rename) — run /scaffold-cleanup to migrate first; the current skills will misread it."

**Frontmatter.** Every `.scaffold/` doc you create or touch carries `type` /
`schema_version: 2` / `updated:`; set `updated:` to today on every file you write.

---

## Precondition guards

Read `state.md` and `roadmap.md` first.

- **Blockers present** (`## Blockers` ≠ "None."): "State shows blockers: [reason].
  Resolved? If yes, we plan forward; if not, let's address the blocker first." Wait.
- **Executed-but-unrecorded work** — `go` ran in *this* conversation but no `checkpoint`
  followed (the plan's `milestone.md` box is still unchecked). This is a *conversation-context*
  signal, not a disk fact (on a cold resume the unchecked box can't distinguish "done but
  unrecorded" from "not started"). When this session knows work was done: "There's
  executed-but-unrecorded work on [plan]. Run /scaffold-checkpoint first to record it,
  then re-plan." Stop — don't proceed.

## Inline description

If the user invoked with a description (e.g. "plan add an export endpoint"), treat it as
the agreed direction: run Phase 1 (triage) silently, then assess weight. A one-line backlog idea → do the minimum: run the admission bar, **propose the line and wait** (`## Backlog` additions are Adam-gated exactly as `## Deferred` ones are), then write it. Propose-then-write, never write-then-confirm — no full flow otherwise.
Anything that creates a milestone, authors plans, shifts architecture truth, or touches a
decision → proceed to Phase 2.

## Draft or finalize (the `--draft` / `--final` argument)

Authoring a phase plan has two modes, and a plan has two states derived from its content
(never a stored enum):

- **draft** — high-level, code-blind, may be written ahead of the code. Has **no**
  `## Targets` section.
- **final** — validated against the code *as it is now* and execution-ready. Carries a
  `## Targets` section stamped `as of <sha>` and a `## Governed by` read-set (the finalize
  pass below writes both; a plan governed by nothing says so in `## Approach` instead).

**Which mode:** the default is to **ask** — "Draft this, or finalize it against the current
code?". The argument **`--draft`** / **`--final`** is a shortcut that skips the ask; if it's
absent, you ask. The ask may *name* the likely option ("a draft exists for phase 7 —
finalize it?") but never decides for the user. The argument is a per-invocation intent
shortcut, **never stored** — the plan's state stays derived from `## Targets` + sha.

On **`--final`** (or the user choosing finalize), run the **Finalize pass** below instead of
the ordinary author flow. Everything else (new milestone, backlog idea, truth shift, a
fresh draft plan) runs the normal Phases 1–7.

## Phase 1: Triage (silent)

Read, absorbing context (don't present yet):

1. `state.md` — Active focus, Next, Blockers, Open Questions. `## Next` may already carry a concrete instruction `checkpoint` wrote there (e.g. "re-finalize `…/phases/04-y.md` — its `## Targets` predate [[0007-…]]"). That is a disposed finding handed to you on disk, not a stale note: treat it as the agreed direction, confirm it in Phase 2, and act on it rather than re-deriving it
2. `roadmap.md` — `## Milestones` index + `## Backlog`
3. `project.md` — identity, scope boundaries
4. `architecture.md` — current technical truth + referenced ADRs
5. `glossary.md` if present — write plans in the project's own words. Read-only here; entries are `checkpoint`'s to propose and Adam's to approve.

Then the **active milestone** (per `state.md` Next — *not* folder order; highest `NN` is
only a fallback when Next is silent): its `milestone.md` (checklist, objectives,
done-contract, `## Deferred` list); the phase plan Next points at, if any; its `spec/` if present (follow a
pointer to an external/shared spec; don't crack open its internals); and any
`knowledge/` doc relevant to the direction. Scan `decisions/` and `investigations/` by
filename; read any directly relevant.

Assess internally: where does the direction land (backlog idea / new milestone /
new-or-changed plans / a requirement / an architecture-truth shift / a decision)? **Is it a pivot** (reverses a prior decision, or reorders/replaces/**inserts** phases in the active milestone — insertion counts, and an interstitial like `09.1` is the canonical case that stales everything downstream)? — if so, downstream unexecuted plans may now be stale. **Does any intended
plan depend on a not-yet-approved decision?** — if so, the ADR gate resolves first.

## Phase 2: Confirm direction (interactive — WAIT)

Skip only if the inline description was an unambiguous one-liner. Restate in one sentence
and confirm: "So the direction is [restatement]. Right?" Wait. The user's direction
overrides the docs. If it's still fuzzy, surface what the docs suggest and ask — don't
author against a guess. If the direction changes mid-discussion, drop the stale proposal
and re-confirm before authoring.

## Phase 3: Resolve the decision gate FIRST

**Ordering rule (hard):** never author a plan premised on an unratified decision. If the
direction rests on a significant, durable, cross-cutting choice (tenancy, auth, a
foundational pivot) not yet in `decisions/`, resolve it before authoring anything that
depends on it.

A choice clears the **ADR bar** only if a reader would want the *why* of it in a year —
not a routine guardrail or build-record. If it clears the bar:

1. **Propose** the full draft, ADR-shaped:
   > **NNNN — [title]** · **Status:** Proposed
   > **Context** [what forces a choice] · **Decision** [the ruling] · **Why** [rationale]
   > · **Alternatives considered** [options + why rejected] · **Consequences** [what this
   > commits us to]
2. **STOP. Wait for Adam's explicit approval.** No ADR is written without it.
3. On approval: write `.scaffold/decisions/NNNN-slug.md` — frontmatter `type: decision`,
   then `# NNNN — <title>`, a `**Status:** Accepted` line, and `## Context` / `## Decision`
   / `## Why` / `## Alternatives considered` / `## Consequences`. `NNNN` is the next
   sequential decision number, zero-padded to **4 digits** (distinct from the 2-digit
   milestone/phase `NN`). If architectural, **in the same turn** add/update its
   referencing statement in `architecture.md` (`[[NNNN-…]]` — the references are the
   index; omitting it silently breaks the index).
4. **Superseding:** flip the prior file's `Status:` to `Superseded by [[NNNN-…]]`, write a
   NEW file, update the referencing architecture statement — same turn. Never edit the
   original ruling.

If the choice doesn't clear the bar, write no ADR — it's a guardrail, not a recorded
decision.

## Phase 4: Confirm the slicing, then announce the write-set

**4a — the slicing.** *Only when you're authoring new phase plans.* How the work is cut into phases decides how the milestone goes, and it is a different question from which files you'll write — so it gets confirmed first, on its own. Present the proposed cut, the phases in order, one line each:

> "Here's how I'd cut this:
> - **07-slug** — [what it delivers, and what you'd see working when it lands]
> - **08-slug** — [ditto]
>
> Right number of phases, cut in the right places?"

Wait. Three rules govern the cut:

- **Vertical slice.** Each phase cuts through every layer *the change itself touches* — no further — and ends in something observable. It need not reach the UI: a backend-only phase is a complete slice when its change can be run and checked in its own scope. The horizontal cut (all the schema, then all the queries, then the wiring) is what this rules out.
- **One agent session per phase.** A phase needing a mid-phase `/clear` is two phases.
- **Wide refactor — expand–contract.** Add the new form, migrate the call sites, remove the old: three phases, build green at every boundary.

**4b — the write-set.** Then state exactly what you'll touch and how:

> "Here's what I'll write:
> - `roadmap.md` — [add backlog line / update milestone index entry]
> - `milestones/02-slug/` — **new milestone**, `milestone.md` seeded
> - `milestones/NN-slug/phases/07-slug.md` — **new phase plan**
> - `milestones/NN-slug/milestone.md` — add Phase 07 to the checklist
> - `architecture.md` — [truth shift, if any]
> - `project.md` — [scope/identity change, if any]
> - `state.md` — Active focus + set Next
>
> Approve?"

Wait for approval. Adjust if Adam changes anything.

## Phase 5: Author (route by the model — one home each)

Write only what the direction calls for. **Every datum has exactly one home below — never
invent a catch-all / "misc" / "notes" section to park something that doesn't obviously
fit.** Route it to its real home; if it genuinely seems to need a new kind of section,
that's a system-design question to raise with Adam, not a bucket to add mid-session.

- The admission bar — run it BEFORE the routing test below. Routing decides *which
  list*; admission decides *whether it gets a line at all*. An item earns one only if it
  **needs a decision**, is **materially out of scope**, or is **real work that can't ride
  along safely.** Clears none → it is **fixed in place or dropped**, never parked (if the
  fix is smaller than the line describing it, the line is the more expensive artifact).
  **Additions to `## Deferred` / `## Backlog` are Adam-gated**: propose each with the gate
  it clears and write only what he approves. Removal stays ungated.
- **The Backlog↔Deferred test (one computable rule):** *is this tied to the active
  milestone — its scope, its code, or its goal?* Not tied (or no milestone is active) →
  `roadmap.md` `## Backlog` (it outlives any current milestone — typically a future
  feature/capability). Tied → the active milestone's `milestone.md` `## Deferred` (it's moot
  or owned elsewhere once the milestone closes — typically a bug, cleanup, debt, residual,
  or doc/spec-reconciliation surfaced inside the work). "Altitude" is not the rule; tied-ness
  is. Either way: one terse `- [ ]` line, never ticked — an item leaves by removal when
  promoted or shipped.
- Grooming Deferred + Backlog (when the direction touches them). You own *promotion*:
  pull a `## Deferred` or `## Backlog` item into a phase plan (authoring it per below) and
  **remove the promoted line in the same write**, or leave the item if Adam decides not to
  schedule it yet. Don't delete an item as "done" on your own judgment — shipped-removal is
  `checkpoint`'s (it has the diff) and stale-detection is `audit`'s (it checks the code).
  **A dismissal is Adam's to make and yours to offer**: when grooming surfaces an item that
  no longer clears the admission bar, say so and remove it on his nod — a list only stays
  short if things leave it.
- **A new milestone** → create `.scaffold/milestones/NN-slug/` (`NN` = one above the highest `NN` across BOTH `milestones/*/` and `milestones/archived/*/` — the archive holds the closed ones, and numbering off the live folders alone re-issues `01` the moment every earlier milestone has been archived, colliding in the roadmap index and breaking every "highest `NN`" fallback;
  slug is a sticky namespace — choose deliberately). Seed `milestone.md` (frontmatter
  `type: milestone`; `# Milestone NN — <slug>`; `## Objectives`; `## Phases`
  checklist with checkbox + completion-date slot; `## Done-contract`). Add the milestone
  to `roadmap.md`'s `## Milestones` (`[planned]`/`[active]` token + one-liner + folder
  pointer). If it warrants heavy scoping, create `spec/` — the spec itself or a pointer
  file to one living elsewhere; never crack open a pointer'd spec's internals.
- **One or more phase plans** → `.scaffold/milestones/NN-slug/phases/NN-slug.md`, and add
  each phase to that milestone's `milestone.md` checklist. Phase numbers reset per milestone;
  the slug namespaces them. **Interstitials allowed** (`09.1` for a surgical phase
  inserted after a frozen plan) — preserve them, never renumber siblings. Each plan is a vertical slice sized to one agent session — the cut was confirmed in Phase 4a; apply the three rules there if you reached here without it. Plan shape:

  ```markdown
  ---
  type: phase-plan
  schema_version: 2
  updated: [today]
  ---

  # Phase NN — <slug>

  ## Objective
  [What this phase delivers, in a sentence or two.]

  ## Scope
  [The deliverables `scaffold-go` executes — crisp and self-contained. Number them, and
  mark human-owned items `[USER]` (e.g. `2. [USER] Create the OAuth app — client ID in
  .env`). Out-of-scope discoveries route to checkpoint, never silent expansion.]

  ## Approach
  [Key decisions, strategy, what to watch out for. Reference the live spec/references or
  the controlling ADR by pointer — never copy their content here.]

  ## Acceptance
  [Verifiable criteria — an OBSERVABLE outcome the user can confirm without reading code
  (a behavior, an output, a visible state), never "tests pass". How `checkpoint` confirms
  the phase is done.]
  ```

  A fresh plan authored this way is a **draft** — no `## Targets`, no `## Governed by`. Both sections are added only by the **Finalize pass**, which validates the plan against the current code. Don't write either in a draft.

  For an investigation deliverable, note `Output: .scaffold/investigations/YYYYMMDD-slug.md`
  in its scope line.
- **A requirement / product constraint** → `project.md`, as **plain truth** (in `## Scope`
  or `## Not building`) — **never a checkbox** (checkboxes are a `project.md` anti-pattern).
  A *verifiable invariant* routes instead to where it's tested: a phase plan's
  `## Acceptance`, a milestone done-contract, the `spec/`, or a `knowledge/` invariants
  doc — not a truth doc.
- **A cross-cutting technical-truth shift** → `architecture.md`, in place, **only** when
  the direction changes *how the system is built* at a cross-cutting level (not a routine
  detail). Tiebreak: changes on *re-platform* (business rule stays) → `architecture.md`;
  changes only when the *business rule* changes → `knowledge/`. `checkpoint` is the
  primary owner (it sees the diff); `plan` touches it only on a discussed truth shift, and
  applies the ADR coupling rule when relevant.
- **A durable cross-cutting invariant settled in discussion** → `knowledge/*.md`, in place,
  in the contract's form (invariant + why + a pointer to where code enforces it). Only when
  it is load-bearing AND has no single code home (a localized value belongs in code; a
  re-platform fact in `architecture.md`). `checkpoint` is the band's primary owner and most
  rules graduate at close; `plan` writes one here only when the discussion itself settled a
  durable invariant with no code to wait on.
- **Where we are now** → always update `state.md`:
  - **Active focus** — one paragraph reflecting the new plan. ELI5: plain words, short
    sentences, no jargon, no officialese.
  - **Next** — set the active cursor: the milestone + the phase plan to execute next
    (by path), e.g. "Execute `milestones/01-rebuild/phases/07-slug.md` — say 'go ahead'
    or run /scaffold-go." **This is the authority for what's active.**
  - **Blockers / Open Questions** — update only if the discussion resolved or surfaced
    one; remove resolved lines (history is git).
  - **No `## Notes` section** — `state.md` has no transient-state bucket. A precondition on
    resuming (reseed the DB first) rides in `## Next`; a durable run/env condition goes to
    `architecture.md`; a blocker to `## Blockers`.

**Auto-finalize when next up.** If one of the plans you just authored is the one `state.md`'s `## Next` will point at, offer to finalize it in the same act — "I'll finalize 07-slug now so it's ready to run?" — and on his yes run the Finalize pass below without a re-invocation. **On a pivot, Phase 6's sweep runs first** — inserting a phase *is* a pivot, so this is the common path: the sweep rewrites the very siblings the neighbour check reads, and its step 2 demotes a plan finalized before it. Offer the auto-finalize only once the sweep is complete, and run the Finalize pass against the swept siblings. **Only that one plan.** Every sibling stays a draft: finalizing stamps a plan against code that will have moved by the time the plan runs, so a batch-finalized set arrives at `go` stale and the freshness gate fires on plans it was never meant to judge.

## Finalize pass (`--final`)

Turn a draft plan into an execution-ready **final** plan by validating it against the
code as it is now. This is where the code-aware, reasoning-heavy work lives — the work
`scaffold-go` no longer does. Run it on the plan `state.md`'s `## Next` points at (or the
one the user names).

**Where the writes land.** Steps 2–6 edit the plan file **in place** — which is why a hard
stop has to *delete* what this pass already wrote. Step 8's write is `state.md` plus
whatever step 7's dialogue changed, not a deferred first write of the plan. The corollary
of editing in place: **if the pass is abandoned before step 7's confirmation, delete
`## Targets`** — same treatment as a hard stop, and for the same reason (an un-confirmed
plan carrying a stamp reads as *final & fresh* to `go`).

1. **Research the current code.** Read the files and patterns the plan's `## Scope`
   implies; identify the concrete files/interfaces the phase will touch and any
   dependencies. (Reading code to author a better plan does **not** cross the "never write
   code" boundary — you still write only the plan.)
2. **Neighbour check — before you commit to a scope.** **First, list the milestone's plan set:** list `.scaffold/milestones/NN-slug/phases/` and read that milestone's `milestone.md` `## Phases` checklist — this pass runs *instead of* Phase 1's triage, so nothing else has put either in front of you, and the unlisted sibling is only visible by diffing the folder against the checklist. Then read `## Objective` + `## Scope` + `## Approach` (those three sections only) of every **unexecuted** sibling plan in this milestone — unexecuted = its `milestone.md` `## Phases` entry is unticked, **or the plan has no entry there yet** (a just-authored sibling is exactly the overlap risk this check exists for, so it is in reach; note the missing entry for `/scaffold-checkpoint` to add). Reach stops there: other milestones and ticked phases are out, and no code is read for this step. `## Approach` is in the set because that is where a written seam and an owned forward pointer live: without it you cannot see that an overlap was already resolved, and you re-report it on every re-finalize.

   Per scope item, one test: **if that sibling executed first, exactly as written, would this item still need doing in full?**
   - **Yes, in full** → not a finding. Stop. Two phases editing one file for different reasons answer yes.
   - **No, or only partly** → hit: the work gets built twice, or built twice differently.

   Admit a hit only when you can **name the one artifact** — a file, table, column, test, document, procedure, dataset — that both items would leave in the same end state. If the two items are plainly about different artifacts, there is no finding.

   **A sibling too thin to answer the test is not a pass.** A draft sibling is code-blind by definition, and one whose `## Objective`/`## Scope` names no artifact at all ("stand up the export pipeline") leaves you unable to *either* clear or admit the item on the text — and no code is read here to settle it. Say so: name the sibling and the item, and ask the user whether the sibling covers it. An unanswerable comparison surfaces at step 7 exactly like a hit; it is never silently dropped as "can't name it".

   Second admission route: **an unresolved forward pointer.** Either plan's prose names an unexecuted sibling without saying who owns the work ("…so it may be cheaper there", "a decision for the audit"). A pointer that already names an owner ("08-splits item 6 owns adding it") is a written seam — silent, and never re-reported on a re-finalize.

   **Never a finding:** both plans pointing at the same `knowledge/` or `decisions/` doc (that's `## Governed by`, not overlap); two phases touching one file for different reasons; this plan building on what a named sibling produces; a sequencing preference.

   **Every hit resolves before finalize, and which resolutions are legal depends on which answer produced it:**
   - **No, not at all** (the sibling leaves the item wholly done) → one plan owns it whole: keep it here and drop it from the sibling, or drop it here. **Ownership goes to whichever phase must have it first — by default the lower-numbered plan.** The subtraction test is order-blind, so nothing else cues you: handing a deliverable to the phase that runs *second* leaves the first executing against a scope the item was deleted from. After any drop, state that the losing plan's remaining scope still stands on its own at the point it executes; if it doesn't, the drop is the wrong resolution and the seam (or a re-cut) is the answer.
   - **Only partly** (the sibling leaves the named artifact half-way there) → exactly two legal moves: **narrow this item to the remainder** and name in `## Approach` what the sibling leaves behind, or **take the whole item here** and drop it from the sibling. **A bare drop here is forbidden** — it deletes the remainder from the only plan that named it, and the work gets built zero times: more expensive than twice, and far harder to notice.
   - Where both plans genuinely touch the work, that split is a seam — `## Approach` states it: who builds what, and what the other assumes.
   - **An unresolved forward pointer** (the second admission route — the subtraction test produced no answer, so none of the three above is keyed to it) → write the owner into **this** plan's `## Approach`: "`08-splits` item 6 owns adding it; this phase assumes it exists". That converts the pointer into a written seam and silences it on every re-finalize. **Never by deleting the pointer** — deleting it loses the dependency and leaves nothing to re-find it.

   Resolution is an edit, not a note; reporting an overlap without resolving it is not a pass. Surface the resolutions at step 7's confirmation seam.

   **Whose file the edit lands in.** The seam sentence always goes in **this** plan — the one being finalized — so the check has a single writer and the sibling reads the same on its own finalize. Beyond that: this plan is always editable; a **draft** sibling may be edited too (that is where "the sibling owns it" adds the item); a **finalized** sibling is **never** edited in place — it was stamped against code and nothing re-checks it, so changing it silently changes what `go` builds. If the only correct resolution requires editing a **finalized** sibling, do not finalize this plan on a promise. Prefer a this-plan-only move where one is legal — narrow this item to the remainder, or (on a *whole* hit) drop it here — and write the seam into `## Approach`. If no this-plan-only move is correct, that is a **hard stop** of the same kind as the >3 case: finalize does not complete, this plan stays a draft, you name the sibling and the item and say it must be re-finalized first, and once it has been you run this finalize again from step 1 against the sibling as written. Never re-finalize a sibling from inside this pass — one plan is mid-finalize at a time, or the sibling's own check reads this plan's pre-edit scope off disk.

   **One hit = one scope item of this plan**, however many siblings it collides with — the count is items in trouble, not comparisons made. **A forward-pointer hit counts as one** whether or not it maps to a scope item of this plan, and an unanswerable comparison counts as one too: both are things that must be resolved before finalize, which is what the count measures. **Zero hits is the normal result.** More than three means the milestone's phase cut is wrong, and that is a **hard stop**: finalize does not complete, the plan stays a draft, and you say so and propose a re-cut rather than filing a list of items. If the user takes the re-cut, finalize again against the new phases. If the user declines it, the check reverts to normal — every hit resolves individually, here and now, and then finalize completes.

   **Re-run the subtraction test on any scope item step 5's tightening adds or materially re-cuts** — same test, same admission bar, same resolutions. An item derived from the code is the likeliest one a sibling's author derived from the same code, and it enters after this step has already run.

   **A hard stop leaves a draft on disk, not just in the summary.** Either stop above can fire while the file already carries `## Targets` — written by step 4 of this pass when the step 5 re-run hits, or left by a previous finalize when this is a *re*-finalize. **Delete `## Targets` before you stop, and leave `state.md`'s `## Next` where it was.** `go`'s state test is content-derived and exempts `.scaffold/` edits, so a plan abandoned mid-finalize with its stamp intact still reads as *final & fresh* and executes the overlap you just refused to resolve — the duplicate build this check exists to stop. A plan that stays a draft must read as one on disk (*a rewritten plan is not a fresh plan*). A `## Governed by` section written this pass may stay: a draft is allowed to carry one.
3. **Write `## Governed by`.** **First, list the candidate set:** every file in `.scaffold/knowledge/` and `.scaffold/decisions/` — filenames plus each doc's opening rule/ruling line, reading any that could plausibly bind. **No `decisions/` file whose `Status:` is not `Accepted` is ever listed** — but the two non-Accepted cases part company. `Superseded by [[NNNN-…]]`: the ruling is kept on disk and is not live — if its successor binds, list the successor. `Proposed`: **if it would bind this phase, stop and resolve the ADR gate (Phase 3) before finalize completes** — a plan is never authored on a not-yet-approved decision, and skipping it silently ships a plan whose governing rule is listed nowhere, invisible to `go` (which reads only what the list names) and to audit (which grades only the entries present). Only a `Proposed` ADR that would *not* bind is simply left out. `decisions/` is append-only, so a dead ruling still reads assertively and will pass the binding test on its face. This pass runs *instead of* Phase 1's triage, so nothing else has put those two folders in front of you; the section is chosen from that listing, never from memory.

   **Then one test per candidate: if you built this phase in violation of this document's rule, would the phase be wrong?** Yes → it binds, list it. If the rule is merely about the same area, or the phase could violate it and still be correct, it does not bind — leave it out. Name the *rule*, not the doc's topic, in the trailing few words; if you can't name the rule, it doesn't belong. Erring wide is not free here: `go` reads every listed document in full before the first deliverable, so a padded read-set burns the execution session's context — the resource the one-session-per-phase rule exists to protect.

   Entries are repo-relative paths under `.scaffold/knowledge/` or `.scaffold/decisions/`, one bullet per line: a backticked path token, then an em dash and a few words naming *which* rule binds. The note is required and is never itself a defect — it is the path token that has to be a path. Literally:

   ```markdown
   ## Governed by
   - `.scaffold/knowledge/tenancy.md` — every query filters by `org_id`
   - `.scaffold/decisions/0007-single-writer.md` — one writer per aggregate
   ```

   Place the section after `## Acceptance`, before `## Targets`; on a *re*-finalize, **replace** the existing section — never append a second one. **The two forms are exclusive and a re-finalize ends in exactly one.** If nothing binds any more, **delete the `## Governed by` heading itself** — a bare heading names nothing to read, `go` stops on it and audit grades it malformed — and write the fixed sentence below into `## Approach`. If something binds now and the plan carried the sentence, write the section and **delete the `Governed by: none` line** from `## Approach`.

   It is the twin of `## Targets`: targets are what the phase **writes**, this is what it must have **read**. `go` resolves and reads these paths before executing, so a `[[wikilink]]`, a doc title or a prose mention is inert — the same lesson `## Targets` already taught. A path that doesn't resolve is malformed.

   **Mandatory here.** Nothing else belongs in the list: not the milestone spec (that's scope), not a sibling plan (a plan is not a rule — a real dependency is a seam in `## Approach`), not source files (those are targets). If the phase is genuinely governed by no `knowledge/` or `decisions/` doc, write this line into `## Approach` instead — **fixed wording, not a paraphrase**, so the check is a grep and not a judgement about prose — optional-and-nobody-writes-it is how the section dies quietly:

   > Governed by: none — no `knowledge/` or `decisions/` document constrains this phase.

   **Point, don't copy.** Now that the pointer is honoured, a pasted copy of a rule is a second home for it and the one that goes stale. `## Approach` says how the rule applies *to this phase*; the pointer supplies the rule.
4. **Write `## Targets`.** Add the section to the plan, one entry per file/interface the
   phase touches, and stamp it with the current commit — get it with `git rev-parse --short
   HEAD` and write `_as of <sha>_` under the heading. This is the grounding evidence that
   makes the plan auditable and gives `go` its staleness backstop. **Place it last, after `## Governed by`** — the order Acceptance, Governed by, Targets is the contract's Required-structure template, and you are the only thing enforcing it: no grader checks section order, and every reader downstream greps by heading, so a misplacement is silent. On a *re*-finalize, **replace** the existing `## Targets` — never append a second one.

   Every entry that names a file must be a repo-relative path (a trailing `/` covers
   everything beneath it) — `go`'s freshness check matches changed paths against this
   list, so a file named only in prose is invisible to it and the phase's own edits will
   read as undeclared drift. An entry naming an *interface or surface* rather than a file
   is fine and is ignored by that comparison; if that surface lives in a file the phase
   will touch, give the file its own path entry too.

   **Be complete, not minimal.** This list is the phase's declaration of what it may move.
   A file the phase will genuinely touch but that you leave out will stop `go` on resume.
   Erring wide costs nothing here; erring narrow costs a false refusal later.

   The stamp does **not** have to stay uncommitted to stay valid — freshness is "nothing
   moved that the plan didn't declare", so committing the plan (or checkpointing mid-phase)
   keeps it fresh.
5. **Tighten Scope/Approach** against what the code actually is, and **ensure `##
   Acceptance` is user-verifiable** — an observable outcome, not "tests pass". Any scope item this tightening adds or materially re-cuts goes back through step 2's subtraction test before you go on.
6. **Apply the stranger test.** Ask: could a competent builder who has never seen this
   project execute this plan from the plan alone? Not *should* they — *could* they. Every
   place the answer is no marks a rule the plan is leaning on without stating: a
   convention, an invariant, a constraint that lives in someone's head or three documents
   away. Name each one in `## Approach`, or point to where it is written. This is a test
   of the plan, not a hiring decision — a plan that only works for a builder who already
   knows the unwritten rules is underspecified, and you cannot see where until you ask.
   It is also cheap: the answer is usually one or two additions, and the gaps it finds are
   a different class from what step 1's code research finds. Where the answer names a rule that already lives in `knowledge/` or `decisions/`, the fix is a `## Governed by` path plus a line in `## Approach` on how it applies — never a pasted copy of the rule.
7. Present the approach in plain terms and confirm in dialogue. The user is an
   architect who doesn't read the plan or the code — so surface the approach as a
   plain-language conversation ("here's how I'll do it: …"), not "read this doc". **Wait for
   his confirmation.** This is the approval seam; `go` executes afterward without
   re-approving.
8. On confirmation, apply whatever step 7's dialogue changed and set `state.md`'s Active
   focus + `## Next` so a resuming session knows the plan is final & fresh. (The plan
   itself was written in place across steps 2–6.)

If finalize surfaces that the plan rests on an unratified decision, resolve the ADR gate (Phase 3) first.

## Phase 6: Pivot — stale-plan sweep

**Run whenever the direction is a pivot** (a decision reversed, or phases
reordered/replaced/inserted in the active milestone). Because plans *persist*, a
pre-written downstream plan can silently go stale when a later change lands.

For **every unexecuted plan** in the active milestone — **drafts included** (a draft
premised on a since-superseded ADR still breaks the ADR gate); executed ones are history,
leave them:
1. Re-read it against the change just made.
2. If its scope/approach/acceptance now conflicts, **flag and rewrite it in place** to match — or, if it no longer belongs, propose removing it and updating the `milestone.md` checklist.
   Rewriting a FINALIZED plan demotes it to draft: delete its `## Targets` in the same edit. The freshness test exempts everything under `.scaffold/`, so a rewritten plan that keeps its stamp still reads as *final & fresh* to `go` — which would then execute a scope nobody validated, against a target list that no longer describes the files it touches, skipping the approval seam entirely. Report it as `rewritten → draft` and say it needs `--final` before `go`.
3. Report each plan as `OK / rewritten / removed` in the summary.

A plan authored earlier in *this* invocation is swept like any other — which is why Phase 5's auto-finalize offer waits for this sweep on a pivot. If the sweep rewrites a plan that was somehow already finalized, step 2 applies unchanged: demote it and re-finalize (its neighbour check re-runs against the siblings as the sweep left them).

This is `plan`'s half of the staleness obligation; `checkpoint`'s coherence sweep is the
backstop that also catches plan-vs-decision drift.

**Not the same defect as the neighbour check.** This sweep hunts **conflict** — a plan a
later change made wrong — and fires only when something moved. The finalize neighbour check
hunts **duplication** — two plans that were both right the day they were written and simply
build the same thing twice, which no pivot ever surfaces. Run both; neither substitutes for
the other.

## Phase 7: Summary + route

Report per file: roadmap / milestone-index changes; milestone created (if any); plans
authored or rewritten (+ checklist updates); architecture / project / knowledge changes;
decision proposed and its status (proposed / approved+written / declined); state updates
(Active focus + the new Next cursor); stale-plan sweep results (if a pivot); on a finalize,
the `## Governed by` paths written (or the governed-by-nothing sentence) and how each
neighbour-check hit was resolved. Then:

> "[Summary]. Ready to build — say 'go ahead' or run /scaffold-go. Or keep planning."

---

## Edge cases

- **User wants something not on the roadmap:** their direction wins — route it to its home
  in Phase 5.
- **User doesn't know what to work on:** stay in Phase 2. Surface the milestone index +
  open questions and help them choose; don't author against a guess.
- **Direction depends on an unratified decision:** resolve the ADR gate (Phase 3) first.
- **Mid-discussion pivot:** drop stale proposals, re-confirm (Phase 2), author, then run
  the Phase 6 sweep.
- **Files look stale** (an `updated:` well behind the work — `checkpoint`'s sweep owns the actual threshold): flag it; offer to refresh now or note it for the next
  `/scaffold-checkpoint` (which sweeps).
