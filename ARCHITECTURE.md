# Scaffold — Architecture

This is the controlling document for the **scaffold system** (the product): how it
works and where everything goes when scaffold is applied to a user's repo. All skills
and file behaviors derive from what's defined here. It is the timeless human+AI
reference, not a changelog.

It defines *concepts*. The exact **format** of each document type lives in its
canonical contract under `contracts/` (see [Document Types](#document-types)); those
contracts are the single master of each format and the oracle the audit grades
against. (This doc lives in the dev repo — the factory — and does not ship; the
shipped artifacts are the self-contained `/scaffold-[skill]` skills.)

Scaffold is a solo-developer context-persistence system: a set of living and
historical markdown documents in a repo's `.scaffold/` directory, plus Claude Code
skills that maintain them so a session can resume after a week-long gap with full
context intact.

## Design Principles

**Scaffold runs like code.** It is a deterministic state machine whose *data is the
document structure itself*: skills compute what's active, what's done, and what to do
next by reading sections off disk (`## Next`, the `milestone.md` checkbox, a plan's
`## Scope`). That is the load-bearing invariant behind every principle below, and it has
one sharp consequence — **every piece of information must have exactly one *computable*
home, so a catch-all or open-ended section is forbidden.** A soft bucket is a
non-deterministic home: the place ambiguous data silently piles up, which is how the
machine starts misreading its own state (and how the docs bloat). When you change
Scaffold, preserve determinism — a new kind of datum gets a section with a membership
rule a skill can apply, never a dumping ground.

1. **State machine.** Every skill leaves all state documents accurate and
   self-consistent. Any skill could be the last thing that runs before a long gap.
2. **Skills are optional tools, not mandatory gates.** The minimum ceremony is
   status → work → checkpoint. Everything else is available when you need it.
3. **No plan mode dependency.** All skills run in normal mode. Shift+Tab plan mode is
   a complementary tool, not a requirement.
4. **Ceremony scales with the user.** You decide how much structure you want per
   session. The system supports freeform collaboration and formal scoped execution
   equally.
5. **A place for everything — and it's computable.** Every piece of information has
   exactly one canonical home, decidable by a rule a skill can apply. Documents don't
   duplicate each other, and no section is a catch-all.
6. **Don't tell Claude what it already knows.** Skills and rules only instruct
   behaviors Claude wouldn't do by default.
7. **Content-derived state, no enums.** What's active, what's done, and what mode a
   milestone is in are all read off disk, never stored as a status flag that can drift
   from reality.

## The Two Governing Laws

Everything below derives from two laws. They are the test for where any artifact
lives.

**Law 1 — Truth and history never share a document.** A document is *either* **living
truth** (one of it; always current; updated in place; never reconstructed by replaying
a log) *or* **frozen history** (dated; written once; never the source of current
truth). The failure mode to design out is a single append-only document that tries to
be both — it smears current truth across N entries and bloats by construction. A
living-truth document is overwritten in place; a history document is written once and
never edited as the source of present truth.

**Law 2 — A document lives at the layer that owns its lifecycle and audience.**
Work-tracking belongs to Scaffold's execution layer. System truth (architecture,
durable rules) belongs to Scaffold's truth layer. Strategy and cross-project thinking
belong to an external knowledge base (e.g. cortex). Scaffold *points outward*; it does
not absorb what another layer owns. Within the repo, `.scaffold/` is the single
governed home for project documentation; repo-level `docs/` holds only
**code-adjacent reference assets** (e.g. a design-system upload bundle), never project
documentation.

These two laws are the tie-breaker for every routing question. If a placement would
violate one, the placement is wrong — not the law.

## Information Model

Each layer has exactly one home and a defined mutability. Living layers are
overwritten in place; history layers are written once; execution layers are temporal
and retire with their milestone.

| Layer | What it is | Home | Mutability |
|-------|-----------|------|------------|
| Product identity | What this is, who for, why, scope boundaries | `.scaffold/project.md` | living |
| **Architecture truth** | How it's built — tenancy, auth, stack, data-access, deployment, conventions | `.scaffold/architecture.md` | living |
| Domain/behavioral truth | Durable cross-cutting invariants (each: the rule + why + a pointer to where code enforces it) | `.scaffold/knowledge/*.md` | living |
| Anchor terms | The words that must mean one thing here — canonical form named, rivals retired | `.scaffold/glossary.md` | living |
| Program | Milestones (done/active/planned) + the backlog index | `.scaffold/roadmap.md` | living |
| Backlog item | One future item: what, trigger, shape, not-doing | `.scaffold/backlog/<slug>.md` | living; leaves by deletion |
| Active state | Where we are now / next / blockers / open questions | `.scaffold/state.md` | living (churns) |
| Decisions | Load-bearing *why* + rejected alternatives (ADRs) | `.scaffold/decisions/NNNN-slug.md` | frozen; **Adam-gated** |
| Research | Investigations / analyses produced while working | `.scaffold/investigations/YYYYMMDD-slug.md` | frozen |
| Milestone plan | The phases + objectives + acceptance + deferred work for one chunk | `.scaffold/milestones/NN-slug/milestone.md` | temporal |
| Milestone contract | The spec, if the chunk needed heavy scoping | `.scaffold/milestones/NN-slug/spec/` | temporal |
| Phase plan | Atomic execution unit: one phase's scope/approach/acceptance | `.scaffold/milestones/NN-slug/phases/NN-slug.md` | temporal |

Each of the three execution rows above moves to `.scaffold/milestones/archived/NN-slug/…` when its milestone closes.

The model has three bands: **living truth** (overwritten in place, always current),
**history** (frozen, written once), and **execution** (temporal, retires with its
milestone).

## Files & Folders

```
.scaffold/
  # ── LIVING TRUTH (overwritten in place; never reconstructed from a log) ──
  project.md                      what this product is & why (identity/scope)
  architecture.md                 how it's built (tech truth)
  roadmap.md                      the program: milestone index + backlog index
  backlog/
    <slug>.md                     one future item — what / trigger / shape / not doing
  state.md                        where we are now / next / blockers / open questions
  glossary.md                     anchor terms — what things are called (may be empty)
  knowledge/
    *.md                          durable domain/behavioral truth (living)

  # ── HISTORY (frozen; written once; never the source of truth) ──
  decisions/
    NNNN-slug.md                  ADRs — load-bearing why + alternatives + status line
  investigations/
    YYYYMMDD-slug.md              research & analysis records

  # ── EXECUTION (temporal; retires with its milestone) ──
  milestones/
    NN-slug/                      an ACTIVE or PLANNED milestone
      milestone.md                     this milestone's phases + objectives + acceptance + deferred work
      spec/                       OPTIONAL — the contract, if heavy scoping was needed
      phases/
        NN-slug.md                phase plans
    archived/
      NN-slug/                    a CLOSED milestone, moved here whole at close — read-only history

docs/                             code-adjacent reference assets ONLY (e.g. design-system bundle)
```

**A closed milestone moves to `milestones/archived/NN-slug/`, whole and unrenamed.**
The move is the marker: every path inside it then reads
`…/milestones/archived/NN-slug/…`, so the word travels with the file into every grep
hit, listing and read — which is how a file is actually encountered, and the only place
a marker survives all three. A banner inside a file does not, because a search hit shows
a line in the middle of a file and never its first line.

**Everything under `archived/` is a closed record: read freely, never edit, never cite
as current.** It states what was built and why, at the time it was built. It does not
state what the code does now — `architecture.md` and `knowledge/` do, and a rule still
live at close belongs in one of them. A closed spec left standing in present tense will
otherwise read as a live contract; three sessions in one corpus repo did exactly that,
editing a spec ten days after its milestone closed.

**This does not make folder location the active-cursor authority. What's active is
whatever `state.md`'s `## Next` points at — not folder order.** "Highest `NN`" is
only a fallback hint when `state.md` is silent: a later-numbered milestone can be
pre-created while an earlier one is still active, so folder order cannot be the
authority. `archived/` answers a different question — *is this closed?* — and it is
derived from the `roadmap.md` `[done]` flip in the same act, never independently.

(`setup` may also write a `.scaffold/archive/` — singular, a flexible bucket
for pre-scaffold snapshots and superseded originals with no other home. It is read by no
skill and is not part of the live model. Distinct from `milestones/archived/`, which is
structured and holds closed milestones only.)

**What happened (history)** lives in git. There is no `log.md`.

## Document Types

Every document type has one canonical **format contract** in `contracts/`. This doc
defines the *concepts*; the contract defines the *exact form* (required sections,
skeleton, rules, anti-patterns) and is the oracle `/scaffold-audit` grades against. The
format detail lives in the contract, not here — so there is one master per format, not
two. **Contracts are factory-authored masters.** We write each skill's format guidance
*from* them, at the altitude that skill needs — for most skills that guidance is an inline
paraphrase, never the contract itself. **One exception:** `/scaffold-audit` grades docs
against the *exact* contract, so it ships a verbatim copy of every contract in its own
`references/` — the single place a contract is bundled into a skill. Those copies are
**derived**: `scripts/sync-contracts.sh` regenerates them from `contracts/` and its
`--check` mode guards the drift, so the direction stays one-way (master → copy). No other
skill bundles a contract.

**Frontmatter convention.** Every `.scaffold/` document carries minimal YAML
frontmatter: **`type` · `schema_version` · `updated`**. `type` is authoritative for
what a doc is — the auditor reads it, never infers. **Band is *derived* from `type`,
never stored** (a stored band would be a driftable enum — Principle 7).

**Identifier convention.** An ordered, zero-padded number marks things referenced as a
sequence — milestones and phases at 2 digits (`NN`), decisions at 4 (`NNNN`,
deliberately distinct so the two namespaces never read alike). A `YYYYMMDD` date marks
a point-in-time capture (investigations). A new doc type picks its scheme by this rule.

| Type | Band | Home | Contract |
|------|------|------|----------|
| `project` | living | `.scaffold/project.md` | `contracts/project.md` |
| `architecture` | living | `.scaffold/architecture.md` | `contracts/architecture.md` |
| `roadmap` | living | `.scaffold/roadmap.md` | `contracts/roadmap.md` |
| `state` | living | `.scaffold/state.md` | `contracts/state.md` |
| `knowledge` | living | `.scaffold/knowledge/*.md` | `contracts/knowledge.md` |
| `glossary` | living | `.scaffold/glossary.md` | `contracts/glossary.md` |
| `backlog` | living | `.scaffold/backlog/<slug>.md` | `contracts/backlog.md` |
| `decision` | history | `.scaffold/decisions/NNNN-slug.md` | `contracts/decision.md` |
| `investigation` | history | `.scaffold/investigations/YYYYMMDD-slug.md` | `contracts/investigation.md` |
| `milestone` | execution | `.scaffold/milestones/NN-slug/milestone.md` | `contracts/milestone.md` |
| `spec-pointer` | execution | `.scaffold/milestones/NN-slug/spec/` | `contracts/spec-pointer.md` |
| `phase-plan` | execution | `.scaffold/milestones/NN-slug/phases/NN-slug.md` | `contracts/phase-plan.md` |

### Execution model (cross-cutting)

A few concepts span the execution docs and don't belong to any single contract:

- **The mode question — dissolved (no flag).** Emergent vs predetermined is not a
  setting; it's an emergent property of how much was pre-written, derivable from disk:
  a **predetermined** milestone has a `spec/` (or pointer) and pre-written phase
  plans; an **emergent** milestone has no spec and plans written just-in-time. Same
  structure either way.
- **One artifact type — the phase plan.** A plan lives at
  `milestones/NN-slug/phases/NN-slug.md`, written up front (predetermined) or
  just-in-time by `plan` (emergent), executed by `go`, and persisting as the record.
  There is no standalone `plans/` folder.
- **The read-set — `## Governed by`.** A finalized plan names the `knowledge/` and `decisions/` documents whose rules bind it, as repo-relative paths, and `go` reads them in full before executing. It is the twin of `## Targets` — what the phase *writes* versus what it must have *read* — and exists for the same reason: **a plan is paper; it cannot read, only point**, and a pointer in prose is inert. Honouring the pointer is also what lets a plan stop pasting the rules it leans on: a rule keeps one home and the plan points at it. Mandatory at finalize; a phase governed by nothing says so with one fixed sentence in `## Approach`, so the check is a grep, not a judgement. The read-set is stamped once and nothing re-checks it, so a rule doc placed *after* a plan finalized would never reach it — `integrate` closes that gap by flagging a finalized plan the doc it just placed would bind. Full statement: `contracts/phase-plan.md`.
- **Phase granularity — vertical slices, one session each.** A phase cuts through every layer *the change itself touches* — no further — ends in something observable, and fits one agent session; a wide refactor is the one exception and sequences expand–contract. This is the `## Acceptance` rule stated from the other end, so a horizontal cut cannot satisfy it. Full statement: `contracts/phase-plan.md`. **When authoring new phase plans**, `plan` confirms the cut with Adam before writing them (its Phase 4a) — a separate question from the write-set, and the more consequential one.
- **Draft vs. final — a plan has two states, derived from content + evidence (no
  enum).** A **draft** is code-blind: high-level, may be pre-written, not executable. A
  **final** plan has been validated against the code *as it is now* and carries a
  `## Targets` section — the files/interfaces the phase touches — stamped `as of <sha>`.
  The state is read off disk: no `## Targets` → draft; `## Targets` whose stamp still
  **holds** → final & fresh; `## Targets` whose stamp no longer holds → stale. The stamp
  holds when nothing has moved that this plan did not declare — the exact test is the
  *Freshness* bullet below.
  This is scaffold's own idiom — a signal is *content + evidence*, like the phase checkbox
  is *checkbox + date* — so it is auditable by construction (the sha must resolve to a real
  commit and the named files must exist). **Finalizing is where the code-aware,
  reasoning-heavy work lives** (`plan`'s finalize pass); `go` is then a thin executor
  behind a deterministic freshness gate. This split is what lets the reasoning step
  and the execution step run on different models / clean contexts, with a reviewable seam
  between them.
- **Freshness — the stamp holds until something moves that the plan did not declare.** The question is *not* "has the repo moved?" A phase that spans a `/clear` moves the repo by construction, and so does `checkpoint` committing `.scaffold/`. Asking the broad question makes a harmless save and a stranger's commit **indistinguishable** — both merely differ from HEAD — so the gate fires on every resume, and a gate you pass without reading is not a gate. The test is deterministic and judges nothing:
  1. The stamped sha resolves **and is an ancestor of HEAD**. If not — a rebase, a force-push, a different branch — the plan was validated against a history that no longer exists: **stale**, no exemptions.
  2. Every changed tracked path between the stamp and the working tree is either **named in `## Targets`** or lives **under `.scaffold/`**. Anything else → **stale**, and `go` names the offending files. One command covers the committed span *and* uncommitted edits: `git diff --name-only <sha> --`.

  Both exemptions are principled, not conveniences. **Target files** already move under `go` item-by-item within one session with no re-check — the code moving is what executing *is* — so letting them move across a session boundary is exactly as safe, and erasing that boundary is what scaffold exists to do. **`.scaffold/` files** belong to the **plan-set drift** obligation: doc drift is defended by `plan`'s pivot sweep and `checkpoint`'s coherence sweep, never by this check. A third exemption follows from the repair licence: **a project file touched by a `checkpoint`/`reconcile` commit since the stamp** — refusing a resume because the last save tidied a dead import is the same false refusal the first two exemptions exist to prevent. Untracked files never trip the gate.

  **A rewritten plan is not a fresh plan.** Because `.scaffold/` is exempt, editing a finalized plan's scope leaves it reading as *final & fresh* — so whoever rewrites one (the pivot sweep, a migration) **deletes its `## Targets` in the same edit** and sends it back through finalize. Otherwise `go` executes a scope no one validated, against a target list that no longer matches it.

  This is also what makes **fresh** a state a *committed* plan can be in: a commit cannot contain its own hash, so any `sha == HEAD?` test would invalidate a plan the moment it was saved.

  **`go` prints the changed-file list before proceeding** — not as a question, as visibility. A passing gate that shows its work is what keeps the refusing gate worth reading; a confirmation prompt here would only relocate the rubber stamp.

  One residual gap, accepted explicitly: an outside commit touching *only* this plan's declared targets passes. Narrow for a solo developer on one branch, and strictly better than a check that is dismissed every time.
- **`--draft` / `--final` is a user-intent shortcut, not a mode enum.** `plan` asks
  "draft or finalize?" when the argument is absent; the flag only skips the ask. It is
  **never stored** anywhere on disk — the plan's state is still derived from `## Targets`
  + sha — so it does not reintroduce a driftable status flag. This is the one place
  scaffold takes an argument, and it is justified precisely because it selects an intent
  for *this* invocation rather than recording state.
- **Staleness obligations — three, of which the two here face outward from a change.**
  Because plans *persist* instead of being thrown away, they can go stale, and each way
  has a defense. These two ask *what did this change invalidate?*; the third — **plan-set
  coherence**, in the bullet below — does not:
  - **Finalize→execute drift** — a plan finalized `as of X`, then code moves before `go`
    runs (a `/clear`, a pause, a week-long gap — scaffold's whole reason to exist).
    Defended by `go`'s **deterministic** freshness check (it judges nothing — ancestry
    plus a path-list comparison, per *Freshness* above); undeclared movement → `go`
    refuses, names the files, and routes to re-finalize.
  - **Plan-set drift** — phases reordered/cut, or a plan premised on a since-superseded
    decision. Defended by `plan`'s pivot sweep over all *unexecuted* plans (**drafts
    included** — a draft on a superseded ADR still breaks the ADR gate) and
    `checkpoint`'s coherence sweep flagging a *finalized* plan vs a later decision.
  Persistence buys durability at this cost, accepted explicitly.
- **Plan-set coherence — the invariant over the *relationships between* plans.** *Within a milestone, no two unexecuted phase plans claim the same deliverable; where two genuinely touch the same work, each names the seam.* This is the third staleness obligation, and it differs from the two above in its trigger: those face outward from a change and ask *what did this just invalidate?*, so an overlap baked in on the day two plans were written triggers neither. **Conflict is loud; duplication is silent** — two conflicting plans cannot both be right, but two duplicating plans are both right and the work is simply built twice. **The admission bar is narrow, and the bar is the design.** *Claims the same deliverable* is decided by subtraction, not word-matching: *if that sibling executed first, exactly as written, would this scope item still need doing in full?* Yes → no finding (two phases editing one file for different reasons answer yes). No, or only partly → a hit, admitted only if the one artifact both would leave in the same end state can be named. The only other route is an unresolved forward pointer — prose naming an unexecuted sibling without saying who owns the work. Word-matching cannot do this job: deliverable identity is semantic, and the overlap that provoked the invariant shared no noun between the two scopes. Without a bar this narrow the check reports five soft overlaps every run and gets rubber-stamped — *a gate you pass without reading is not a gate.* Reach is siblings in the same milestone, no wider; zero hits is the normal result. **Two enforcers, and they are not a second home:** `plan`'s neighbour check at finalize *writes* the resolution, one plan at a time; `/scaffold-audit`'s reality pass *grades* the set read-only after the fact — the only enforcer that can see an overlap when no plan is being finalized — and routes to `plan`. `checkpoint` is deliberately not a third. Procedure: `skills/scaffold-plan/references/finalize.md`.
- **Milestone lifecycle.** Active = wherever `state.md` Next points (not folder
  order). On close, the folder moves whole to `milestones/archived/NN-slug/` and its
  `milestone.md` is stamped `archived: YYYY-MM-DD`; durable rules graduate
  to `knowledge/` (reconciled, surfaced for Adam); `roadmap.md`'s milestone line flips
  to `[done]`. Any remaining `## Deferred` items are resolved, promoted, or dropped at
  close — they retire with the milestone, never silently graveyarded.
- **Deferred work (`milestone.md` `## Deferred`).** Work *tied to* a milestone — surfaced
  inside it, in its scope or code, but not scheduled into a phase: a bug, a cleanup,
  deferred debt, a review residual. **The Backlog↔Deferred discriminator is one computable
  test — "is it tied to the active milestone?"** Tied → here (it's moot or owned elsewhere
  once the milestone closes); not tied, or no milestone is active → `backlog/<slug>.md`, indexed by one
  `roadmap.md` `## Backlog` line (it outlives any current milestone).

  **A backlog item is a file, every one of them.** A one-line item loses the thing that makes it real — its *trigger* ("demand, not a date") — or grows into a paragraph and bloats the index. So each item is a file with four fixed sections (`## What`, `## Trigger`, `## Shape`, `## Not doing`) and `roadmap.md` `## Backlog` is a pure index, one pointer line per file, its size fixed by construction. *Every* item gets a file, not only the detailed ones: partial coverage would make each skill judge which items have files, and that judgement is what a disk-driven system cannot make. The file holds *shape* and *points*; a rule still routes to `knowledge/` and a choice to `decisions/` — otherwise the dumping ground has moved, not gone. Full statement: `contracts/backlog.md`.

  **Admission is a bar, and it runs before routing.** Tied-ness answers *which list*; it
  never answered *whether the thing deserves a line*, and without that gate a deferred list
  is the one section in the system with an open membership rule — every soft observation an
  agent doesn't want to lose lands there, and it bloats faster than any other doc. So an
  item is admitted only if it **needs a decision**, is **materially out of scope**, or is
  **real work that can't ride along safely**; anything else is **fixed in place or dropped**
  (if the fix is smaller than the line describing it, the line is the more expensive
  artifact). **Additions are Adam-gated** — a skill proposes with the gate it clears and
  Adam approves, the same hard gate `decisions/` carries; removal stays ungated, because the
  friction belongs on the way in. Full statement: `contracts/milestone.md`.

  Grooming still runs **continuously, not only at close** (close is too rare to be the
  drain — milestones can run a long time): `plan` promotes an item into a phase plan (and
  removes the line) or leaves it; `checkpoint` removes items shipped that session **and, on
  its always-on sweep, flags a list that has grown past what the bar should permit**;
  `audit`'s reality pass does the expensive "already built / no longer applies"
  determination and flags items for removal. The bar and the grooming are complements, not
  substitutes: the bar keeps the list short, grooming keeps it *true*. A long list is read
  as an admission failure first and a grooming backlog second.

## Routing — "Where Does This Go?"

Deterministic. Resolve by the two laws when in doubt.

| The thing | Home |
|-----------|------|
| Future work NOT tied to the active milestone (a feature/capability that outlives it; or anything surfaced while no milestone is active) — **and clearing the admission bar** | `backlog/<slug>.md` + its index line in `roadmap.md` `## Backlog` |
| Deferred work tied to the active milestone (a bug, cleanup, debt, residual in its scope/code) — **and clearing the admission bar** (needs a decision / materially out of scope / can't ride along safely), Adam-approved | that milestone's `milestone.md` → `## Deferred` |
| Something noticed in passing that clears no admission gate (a rename, a stale comment, a one-line guard, a duplicate) | fix it in place now (`checkpoint`'s closing repair licence), or drop it — **not** a parked line |
| A significant, durable choice + its why | `decisions/NNNN-slug.md` (+ reference it from `architecture.md` if architectural) |
| Research / analysis output | `investigations/YYYYMMDD-slug.md` |
| Current technical truth (how it's built, incl. durable run/env) | `architecture.md` |
| A durable business/behavioral rule | `knowledge/*.md` |
| A word that must mean exactly one thing here (esp. several words circling one concept) | `glossary.md` — **Adam-gated**, and only if it clears the admission bar |
| How to build phase X of the active milestone | `milestones/NN-active/phases/X-slug.md` |
| The contract that scoped a milestone | `milestones/NN-slug/spec/` (the spec, or a pointer to a shared/external one). Once closed: `milestones/archived/NN-slug/spec/` — a record of what was built, never a statement of current behaviour |
| Where we are right now | `state.md` (`## Next` is the active-cursor authority) |
| Transient operational state (dirty DB, temp env) | resolve it; else route — a resume precondition → `state.md` `## Next`; a durable run/env condition → `architecture.md`; a blocker → `## Blockers`. **No catch-all section.** |
| What the product is / scope boundaries | `project.md` |
| A project-specific working constraint ("must work offline", "no paid APIs without approval") | **Not scaffold's** — it belongs in the project's own always-loaded instructions (Law 2: scaffold points outward). No `.scaffold/` doc owns it. |
| A code-adjacent reference asset (design bundle) | repo `docs/` |
| What happened (history) | git (no `log.md`) |

## Skills

The skill set is **9**: `setup`, `status`, `plan`, `go`, `checkpoint`, `audit`,
`integrate`, `cleanup`, and the `update` utility — each named `/scaffold-[skill]` and
each a self-contained artifact that carries the format guidance it needs, written in. Skills are
tools you reach for when you need them; the minimum session is status → work →
checkpoint.

Three structural boundaries hold across the set:

- **`go` writes code (and optional investigations); never scaffold truth or execution docs.** All *runtime* scaffold write-back is owned by `plan` and `checkpoint`; `setup` creates the initial set and `cleanup` migrates it. The reverse holds with exactly one bounded exception: `plan` never touches project code, and `checkpoint` touches it only under the **closing repair licence** — the residue of a session whose diff it is already holding, never new work.
- **`decisions/` is propose-only.** Skills may draft an ADR and stop; **Adam approves**
  before anything is written.
- **A finding that would be lost gets a disposition before the session ends.** Three things produce findings — `checkpoint`'s sweep, `audit`, and `go`'s scope check. `go` acts on its own scope-check findings in code (that is the skill that writes code); everything left, and everything the other two produce, is **`checkpoint`'s to dispose of**: **fixed**, **routed to a home on disk**, **ruled on by Adam and then acted on in the same session**, or **dropped**. Naming it in the transcript and committing anyway is not a disposition — the transcript is the one thing this system exists to stop depending on. *The test is losability:* a finding a later run can re-derive from disk (a per-contract format detail — `audit` re-grades the whole tree on demand) is not lost by going unmentioned, so reporting it is exit enough. A finding that existed only because **this** session saw the diff, the run, or the conversation dies with the session, and gets one of the four.

### The two-tier audit model (no flags)

*Scope: grading the **docs**. Code is checked separately, by `go`'s scope check.*

A safety check you must remember to invoke isn't a safety net, so there are no audit
flags. Instead, two tiers:

- **`checkpoint` always runs a light, inline structural + coherence sweep** over the
  living docs — automatically, every time, no flag. It checks the *stable* structural
  invariants (frontmatter present, required sections present, no catch-all / no
  append-log) and cross-doc coherence, then **defers the deep per-rule grading to audit**.
  Fast enough to run at every session end.
- **`audit` is the deep, independent review** — on demand, spins up fresh agents. It is
  the **sole grader of per-contract format rules** (it owns the bundled contract copies in
  its `references/` — the one drift-guarded place those rules live) and checks docs against
  actual code. It always does both (see below), and it never reads
  `milestones/archived/`.

  *Why the split:* the detailed per-contract format rules change as contracts evolve, so
  keeping them in exactly one drift-guarded place (audit's bundled copies) is what stops
  the rules from being hand-copied into multiple skills and silently rotting. Checkpoint's
  always-on net stays cheap by checking only the Law-level structural invariants, which
  don't drift.

---

### `/scaffold-setup`

**Role:** Initialize. Scaffold the structure for a new project.

Creates the living-truth docs (`project`, `architecture`, `roadmap`, `state`), empty
`knowledge/`, `decisions/`, `investigations/`, and `milestones/` with an initial
`01-<slug>/` (emergent default: `milestone.md` seeded with a single Phase 1, no spec, no
pre-written plans). The seed slug is rename-cheap (`01-main`); because the slug is a
sticky namespace, setup documents the rename procedure. Creates `glossary.md` **empty** — a project with no anchor terms yet is the correct starting state; setup never proposes terms. **Stamps frontmatter** on every doc it creates. On an **existing codebase**, setup
automatically gives it careful treatment — a thorough Explore pass seeds
`architecture.md`/`project.md` from the real code (no flag). It does **not** curate
decisions into ADRs — a legacy monolith is `cleanup`'s migration job; a stray decisions
doc is surfaced and proposed via `plan`/`checkpoint` (Adam-gated). `integrate` is
pure-ingest and never writes decisions.

---

### `/scaffold-status`

**Role:** Orient. Read state, present options. Read-only — writes nothing.

Reads the truth docs + the active milestone's `milestone.md` + the phase plan that
`state.md` Next points at. **Reads `glossary.md` in full, silently** — its audience at session start is Claude, not the user, so the terms are loaded into context and nothing about them is reported. Derives all signals from disk; **active is per `state.md`
Next, not folder order.** Surfaces investigation filenames (cheap, no read) so a
resuming session sees them. Ends with options, not directives.

**Names what is coming, not just what is active.** Up to three unticked `## Phases` entries from the already-open `milestone.md`, by title: an unticked entry sitting *before* the active one is named first and marked stranded (it is unexecuted, and the likelier duplicate); the rest follow in list order. With no active phase, the first three unticked entries and a note that the cursor is unanchored. Names only — it does not open the plans or adjudicate overlap (that is `plan`'s neighbour check). It exists so the user can see an overlap or a mis-ordered cut without holding the plan set in memory; nothing else shows the shape of the queue.

---

### `/scaffold-plan`

**Role:** Consult and author. The **single scaffold-authoring skill** (it absorbs the
old `scope`). The preceding conversation needs no skill; `plan` *persists* the agreed
plan into the right docs, routing by the model above.

It may: update `roadmap.md`, `state.md`, `architecture.md` (on a cross-cutting truth
shift), `project.md`; **create a new milestone**; **author one or more phase plans** +
update the milestone's `milestone.md`; **finalize** a plan; and set `state.md` Next. On a
**pivot**, it sweeps unexecuted plans (drafts included) for staleness.

- **Finalize pass.** `plan` turns a draft plan into a final one: it researches the current code, tightens Scope/Approach and makes `## Acceptance` user-verifiable, **runs the neighbour check** (below), applies the **stranger test** (could a builder with no knowledge of this project execute the plan from the plan alone? — each no names an unwritten rule the plan leans on, which then gets stated or pointed at), **writes `## Governed by`** (the `knowledge/`/`decisions/` paths whose rules bind the phase, or the fixed `Governed by: none` line in `## Approach`), and **presents the approach in plain terms for the user to confirm in dialogue** (not "read the doc"). Only on confirmation does it write `## Targets` (stamped `as of HEAD`) and move the cursor — so a pass that stops or is abandoned leaves a draft on disk, never a stamp nobody confirmed. This is where the code-aware, reasoning-heavy work lives — the step `go` no longer does. It reads code but still writes only the plan (the "never code" boundary holds). Invocation is ask-if-absent, `--draft`/`--final` as a shortcut.
- **The neighbour check (at finalize).** `plan` applies the plan-set coherence bar per scope item against every unexecuted sibling in the milestone (reading `## Objective`, `## Scope` and `## Approach` — a written seam lives in `## Approach`, so without it a resolved overlap re-reports on every re-finalize). Every hit is resolved by an edit to this plan, never merely reported, and surfaces at the existing confirmation seam. **A finalized sibling is never edited in place** — its stamp would then lie about what `go` builds — so a hit that can only be resolved by changing one hard-stops this finalize until that sibling is re-finalized. Invariant, bar and reach: *Execution model → Plan-set coherence*.
- **Auto-finalize when next up.** If the plan just authored is the one `state.md` Next will point at, `plan` offers to finalize it in the same act — after the pivot sweep, which may rewrite the very siblings the neighbour check reads. **Only that one.** Siblings stay drafts by design: finalizing stamps a plan against code that will move before it runs, so a batch-finalized set arrives at `go` stale and the freshness gate fires on plans it was never meant to judge.
- **Ordering rule:** if a plan depends on a not-yet-approved ADR, `plan` resolves the
  ADR gate *first* — it never authors plans premised on an unratified decision.
- May **propose** an ADR — present the draft, **stop for Adam's approval.**
- **Confirms the slicing, then announces its intended write-set — both before writing.** When the write-set includes new phase plans, `plan` first presents the proposed cut (the phases in order, one line each) and confirms the granularity and the boundaries. Which files get written is the cheaper question.
- **Boundary:** scaffold docs only, never code.

---

### `/scaffold-go`

**Role:** Execute. A thin executor of the phase plan referenced by `state.md` Next.

Writes project files and may write an `investigations/` record; **does NOT write
scaffold truth or execution docs** — that is `checkpoint`'s job. Reads its plan from
`milestones/NN/phases/` and **computes its state** (draft / final&fresh / stale) from
`## Targets` + the freshness check:

- **draft** (no `## Targets`) → stop: finalize it with `/scaffold-plan --final`, or work
  freeform (status → work → checkpoint). `go` has no research/propose step of its own — a
  draft is not for `go` to figure out.
- **stale** (the stamp is not an ancestor of HEAD, or something moved that `## Targets`
  and `.scaffold/` do not cover) → stop, **name the offending files**, and re-finalize
  with `/scaffold-plan --final`.
- **final & fresh** → **read every document `## Governed by` names, in full, before presenting the scope** — resolving those paths is what makes the plan's pointers real. The read-set stops `go` at load, graded as a malformed plan, on a path that does not resolve, an empty section, or neither the section nor the verbatim `Governed by: none` line. A named document that **forbids what the plan directs** also stops `go`: it names the rule and the plan element, builds nothing further, and routes to `/scaffold-plan --final` — the phase is not abandoned and the cursor stays, because only the approach is re-decided. `go` never picks between the governing rule and the approved approach; choosing one *is* deciding the contradiction, and that is `plan`'s. Otherwise print what has moved since the stamp and execute exactly what `## Scope` names, one deliverable at a time.
  The approach was already approved in plain terms at finalize, so `go` confirms the
  start and works item-by-item — it does not re-propose. Out-of-scope discoveries route
  to checkpoint rather than expanding silently.

**The scope check — always, at the end, by a fresh agent.** When the scope items are done, `go` dispatches **one fresh subagent** and hands it the plan's `## Scope` and the diff. It answers three questions: what scope items are **not built**, what was built **differently** from what the plan named, and what was built that **no scope item asked for**. The third is the one nothing else in the system looks for — every other check hunts for missing work, and surplus code on a path nobody asked to review is the same risk from the other side. *Fresh* is the mechanism, not a preference: a model reviewing its own work finds nothing, so `go` cannot run this check itself. The agent reports; it does not fix. A deeper review (`/code-review`) is **offered, never automatic**.

**The unsatisfiable exit.** `go`'s escape hatch has two exits, chosen by one question: *can the scope be satisfied at all?* **Yes, just not as scoped** → offer to re-scope or continue. **No** — the scope contradicts the code, two items can't both hold, a required fact doesn't exist → `go` states the contradiction and stops, and **continuing is not offered.** That is a legitimate terminal result, not a failed phase; the exit has to exist because a plan with no door marked *this cannot be done* is a plan the executor forces a pass on instead. `go` writes nothing; `checkpoint` records it through **abandon** — phase unticked, cursor cleared off the plan, the contradiction as the reason. A read-set document that contradicts `## Approach` is **neither of these exits** — the scope still holds and the phase is still wanted, so it re-finalizes (above) and is never abandoned.

---

### `/scaffold-checkpoint`

**Role:** Close the session cleanly. Verify work, update files, sweep, **repair**, commit.

**Why it exists (the first-principles statement).** Checkpoint is the only moment in the system where the diff, the docs and the human are present at the same time. After the commit all three disperse: the diff goes to git, the human leaves, and the next session starts cold and has to re-derive from scratch what is sitting in front of this one for free. So checkpoint's job is **not recording** — recording is the means. Its job is to **leave no known-wrong state in the tree.** The operative rule follows directly: *a finding checkpoint can dispose of, it must dispose of*, because it will never be cheaper to close than right now. Deferring is paying a multiplier to redo the same work later with less information.

Updates the truth docs + the active milestone's `milestone.md` (tick the phase checklist +
date) + `state.md` + `knowledge/` (when behavior changed).

- **Evidence must be FRESH** — produced *in this exchange*, not a green run remembered from earlier in the session (the run was real; the code has moved since). And tests passing is evidence the tests pass, **not** evidence the scope was built: that needs the scope read against the diff (`go`'s scope check, or a pass here).
- **A phase `go` reported unsatisfiable is recorded through abandon** — phase unticked, the plan reference cleared from `## Next`, the contradiction as the reason.
- **Always runs a light, inline structural + coherence sweep** over *all* living docs
  (not just the touched ones), no flag:
  - *Structural* — each living doc well-formed at the stable, Law-level shape: required
    sections present and in order, frontmatter correct, no catch-all / no append-log, no
    `project.md` checkbox (Law 2). The deep per-contract rule grading is deferred to audit
    (the sole grader).
  - *Coherence* — cross-reference integrity (architecture ↔ decisions), Law-1/Law-2
    violations, duplication, plan-vs-decision staleness, `## Next` resolves, stale
    dates.
- **Auto-detects "no work to save → just sweep"** — run it after hand-edits or to
  tidy. There is no flag — detect the no-work case.
- May **propose** an ADR (gated).
- **Milestone-close motion:** graduate durable rules to `knowledge/` (reconciling +
  retiring contradicted docs, **surfaced for Adam's confirmation**), flip the
  `roadmap.md` line to done, move the folder to `milestones/archived/NN-slug/` and stamp
  its `milestone.md`.
- **Primary owner of `architecture.md`** — it sees the diff and updates the technical
  truth when the build changed how it's built.
- **Proposes a glossary term on a collision only** — when the session showed the same concept called more than one thing, or one word used for two. A high bar, deliberately: a "any terms today?" prompt every checkpoint trains the answer *no*. Additions **and definition changes** are Adam-gated; removal is not.
- **The closing repair licence — checkpoint fixes what it finds, in both bands.**
  - *Scaffold docs, including the ones it primarily owns.* Collapsing a duplicate and re-homing a fact between `architecture.md` and `knowledge/` are decided by the routing tiebreak above; a published rule is not a judgment call, so checkpoint **applies** it rather than reporting it. (It remains barred from rewriting a *plan* — that is authoring, and it routes.)
  - *Project code — the session's residue only.* The one exception to "truth-writing skills never touch project code," and it is bounded by what checkpoint is: it holds this session's diff and the human. The test is **"does this need a plan?"** — if yes, it is `plan`/`go` work and gets routed, never fixed here. There is no line-count limit; the judgment is the skill's and the **brake is the pre-commit review**, where every repair lands in a diff Adam approves before anything is committed. A repair is never new capability, and never touches a surface the session did not already touch.
- **Every finding gets a disposition before the commit — one of four, and "mentioned" is not one of them.** Fixed; routed to a home *on disk* (an undecided call → `## Open Questions`; a real obstacle → `## Blockers`; work clearing the admission bar → `## Deferred` / `## Backlog`; work needing authoring → the concrete instruction written into `## Next`, phrased so a cold session can act on it); ruled on by Adam and then acted on in this same session; or dropped. Saying "run `/scaffold-plan`" into the transcript is not a route — the transcript does not survive the gap, which is the whole reason scaffold exists.
- The inline sweep *flags*; the **deep** grading (hard conformance + docs-vs-code) is `/scaffold-audit`. Git is the history; no log file. Commits `.scaffold/` — **plus any repaired project files**, in the same commit, named in the message.

---

### `/scaffold-audit`

**Role:** Deep, independent review. On demand. Read-only — reports drift, changes
nothing.

Spins up fresh read-only agents to do thoroughly what `checkpoint`'s inline sweep only
samples. **It always does both, no asking** — depth is already chosen by invoking
`audit` at all. **`milestones/archived/` is out of scope in both passes:** a closed
milestone is a frozen record, so grading it can only produce findings nobody may act on.

- **Conformance (runs first, gates the rest):** grade every `.scaffold/` doc against its
  contract — the audit skill bundles a verbatim copy of each in `references/` — and grade
  **one rule at a time**: every Required-structure item, Rule, and Anti-pattern gets an
  explicit pass/fail/n-a verdict with evidence, so a present-but-ignored rule can't be
  waved through by a holistic glance. The per-doc grade is derived (conforms only if every rule passed or was n-a). Frontmatter `type` selects the contract.
- **Reality:** verify scaffold claims against actual code — ticked phases really built,
  `architecture.md` matches the real stack, ADRs match reality.

  *Stranded rules are not audit's to catch.* Because nothing may act on a finding inside the archive, the obligation sits at the close: `checkpoint` accounts for **every** rule in the retiring spec (graduated / code-homed / dead), that being the last moment the question can be asked. A rule missed there stays missed.

**Conformance gates reality:** if a doc is malformed enough that its state can't be
read reliably (e.g. `## Next` doesn't resolve), the reality pass for that area is
reported as *unreliable* rather than guessed. Findings are returned prioritized; fixes
go through the owning skill (audit never edits).

**Audit's findings are disposed of by `checkpoint`, not by the transcript.** Audit stays read-only — that independence is the point of the tier — but read-only must not mean *lost*. Audit ends by naming the disposing skill for each finding and, when the run is not immediately followed by one, states plainly that the findings live only in this transcript until a `checkpoint` disposes of them.

---

### `/scaffold-integrate`

**Role:** Absorb. Pure ingest of an external artifact.

Absorbs a spec or doc: if it scopes a milestone → that milestone's `spec/` (the
artifact itself or a pointer); if it is cross-cutting durable knowledge → `knowledge/`.
Extracts operational info into the truth docs. Does not execute work, author phase
plans, or modify project files.

**A placed `knowledge/` doc can bind an already-finalized plan.** The read-set is stamped once and nothing re-checks it, so after placing a `knowledge/` doc integrate reads every finalized (has `## Targets`), unexecuted plan in every live milestone and applies `plan`'s binding test: *if that phase were built in violation of this document's rule, would the phase be wrong?* Yes, and the read-set does not name the path → route to `/scaffold-plan --final`. Absence of the path alone is never the trigger, or every finalized plan gets rubber-stamped after any placement. Integrate never edits a plan.

---

### `/scaffold-cleanup`

**Role:** Migrate. The cautious, interactive **migrator to this structure.**

**Cleanup is the one skill whose input is unknown by design.** Every other skill assumes a
conformant repo and computes from it; cleanup faces an old format, a half-finished
migration, a hand-edited mess, or something unfamiliar — and you cannot write fixed steps
for unknown input. So cleanup is **objective-driven, not shape-driven**: it fixes the
*target end-state* (what `setup` produces + the contracts), reads whatever is on disk
**without assuming a shape**, and works with Adam to map what it finds onto that target.
The flexibility is bounded by two *fixed* ends — the known objective, and a structural
self-check at the end that proves the result reached it. It **migrates the gap, not a
presumed whole**, so it is safe to re-run and safe on a partially-migrated repo.

Its flow: **inventory** (read everything, assume nothing; hard-stop if there's no
`.scaffold/` → `setup`, or if it's already fully conformant → nothing to do) → **triage**
every gap into *mechanical* (just do), *judgment* (gate with Adam — the milestone slug,
which decisions become ADRs, which doc is the plan), or **ambiguous / partial /
contradictory → STOP and surface, never guess** (this is the safety valve for the unknown
repo) → **propose the full plan** → **reference sweep before any move** → **map** what the
inventory found → **execute in one pass** → **verify against the target**.

The mapping playbook (applied only to patterns the inventory actually turns up): splits an
old per-phase `roadmap.md` by altitude (build plan → `milestones/NN-*/milestone.md` with the
checkbox+date checklist preserved; `## Backlog` + a fresh `## Milestones` index stay at
program altitude; a `phase-00` "plan authored" entry folds into `milestone.md`, not a plan);
moves `plans/phase-*` into `phases/` **preserving interstitials (`09.1`) — never renumber**;
stands up `architecture.md` from decisions + run/env + the real code (architecture-vs-knowledge
tiebreak); **curates decisions — does not split them** (a monolithic `decisions.md` → an
Adam-gated promote-the-few session; the rest retire to git; a grandfathered spec's internal
decisions file is never cracked open); normalizes nonconformant names
(`2026-06-11-*` → `20260611-*`); drains a legacy `state.md` `## Notes` to each item's real home; **gives every bare `## Backlog` line its `backlog/<slug>.md`** (sections Adam does not supply read `Unknown.`); **archives closed milestones retroactively** (a `[done]` milestone still sitting outside `archived/` is moved there, stamped, and its roadmap path repointed — and because that close never ran, the knowledge-graduation pass runs with it, Adam-gated, since `contracts/knowledge.md` makes a rule missed at close unrecoverable); and **stamps frontmatter** (`schema_version`) so future format migrations are detectable.

**Verify + hand-off (the fixed back end):** before committing, cleanup runs the *same
light structural + coherence self-check `checkpoint` runs* — proving the mechanical result
is well-formed and no pointer dangles. It does **not** grade docs rule-by-rule against the
contracts; that is `audit`'s sole job, and duplicating those rules here would re-create the
drift the system prevents. After committing, it **recommends `/scaffold-audit`** for the
independent deep conformance + reality pass.

---

### `/scaffold-update` (utility)

**Role:** Pull the latest skills. Touches no `.scaffold/` content.

---

### Skill × Artifact Coverage

Every artifact has a skill that **creates** it and a skill that **maintains** it
(updates, or retires/freezes). No orphan files, no orphan operations. `R` = reads,
`C` = creates, `U` = updates, `×` = retires/freezes/closes.

**"Single owner per band" means single owner of *maintenance*, not single writer.** A band
may be *written* at several distinct lifecycle moments (e.g. `knowledge/` is written at
ingest by `integrate`, at discussion-settle by `plan`, and at milestone-close by
`checkpoint`) — that is correct, not a smell, because each write is owned by the skill
that owns *that moment*. What must be single is the skill accountable for the band staying
coherent over time; that owner is marked **(primary)** below.

| Artifact | setup | status | plan | go | checkpoint | audit | integrate | cleanup |
|----------|-------|--------|------|----|------------|-------|-----------|---------|
| `project.md` | C | R | U | — | U (rare) | R | U | U |
| `architecture.md` | C (seed) | R | U (propose) | R | **U (primary)** | R | U | C (from decisions/run-env/code) |
| `knowledge/*.md` | C (dir) | R | C/U | R | **C/U (primary)** + graduate/retire-on-close | R | C/U (absorb) | C (graduate-at-migration, gated) |
| `glossary.md` | C (empty) | R (silent) | R | R | **propose→gate (primary)** | R | — | C (if absent) |
| `roadmap.md` | C | R | U (add/remove Backlog index line) | — | U (+ remove shipped) | R (flag stale) | R (classify) | U (build milestone index) |
| `backlog/<slug>.md` | C (dir) | — | **C/D (primary)** — with its index line, always both | — | C (routed finding) / D (shipped) | R (already built; trigger fired) | — | C (one per old backlog line) |
| `state.md` | C | R | U | R | U + sweep | R | — | U |
| `decisions/NNNN-slug.md` | C (dir) | R (on ref) | **propose→gate** | — | **propose→gate** | R | — | migrate (Adam gates survivors) |
| `investigations/YYYYMMDD-slug.md` | C (dir) | R (lists) | R | C (opportunistic) | R | R | — | U (rename + stamp) |
| `milestones/NN-slug/` (container) | C (first) | R | **C** (new chunk) | — | **move → `archived/` on close** | R | — | C (wrap existing roadmap) |
| `…/milestone.md` | C (seed) | R | **U** (+ groom/promote Deferred) | R | U (tick + groom Deferred) | R (flag stale Deferred) | — | C (from old roadmap body) |
| `…/spec/` | — | R | — | R | — | R | **C** (absorb/pointer) | move or pointer |
| `…/phases/NN-slug.md` | — | R (state; names next unexecuted) | **C/U** + finalize (`## Targets`, `## Governed by`, neighbour check) + stale-sweep | **execute (final&fresh only)**; reads `## Governed by` first | × (done; tick lands in `milestone.md`) | R (grade `## Targets` + `## Governed by`; flag plan-set overlap) | R (flag read-set predating a placed knowledge doc) | C (move old `plans/`, keep `09.1`) |

`update` is omitted — it pulls skill files and touches no `.scaffold/` content. `audit`
is read-only — it grades and reports across every artifact, never writes. The coherence
reconcile is `checkpoint`'s job — every checkpoint, auto-detecting the no-work case.

The table covers `.scaffold/` artifacts. **Project code** is `go`'s to write, with the single bounded exception of `checkpoint`'s closing repair licence (session residue only, approved in the pre-commit review).

## Workflows

Skills are optional. These are common patterns, not mandatory sequences.

### Freeform (minimum ceremony)

```
status → work with Claude → checkpoint
```

No plan, no go. Just collaborate and save. Checkpoint captures everything from
conversation context and runs its light structural + coherence sweep.

### Guided (consultation + authoring)

```
status → plan → work with Claude → checkpoint
```

Plan figures out what to do and persists it — updating the roadmap, authoring phase
plans, setting `state.md` Next. Then you work and save.

### Predetermined milestone (execute from plans)

```
status → plan --final → go → checkpoint   (repeat per phase)
```

A spec has already been absorbed and phase plans pre-written **as drafts**. Each phase
gets a **finalize** pass first — `plan --final` validates the draft against the code as it
is now (writing `## Targets` + `as of HEAD`, confirming the approach in plain terms) — then
`go` executes the final & fresh plan and `checkpoint` ticks the `milestone.md` checklist and
reconciles. Repeat until the milestone closes.

`plan --final` per phase is extra ceremony on a predetermined run, accepted deliberately: validation has to happen *when it can be correct* — against the code as it is — not when the plan was written ahead of it.

### Periodic deep check

```
audit
```

Run `/scaffold-audit` when you want an independent conformance + reality review — before
a release, after a long gap, or after heavy hand-editing. It reports drift; fixes go
back through the owning skill.

### Mix and match

Skills can be invoked at any point. Run `plan` deep into a session to recalibrate. Run
`go` whenever a plan is ready and Next points at it. Run `checkpoint` whenever you want
to save.

## State Determination

State is content-derived, not enum-driven. Skills determine what's true by reading
disk. This removes the drift risk of a status field that doesn't stay in sync with
reality.

| Signal | Detection |
|--------|-----------|
| Document type | frontmatter `type:` (authoritative); filename/location as fallback |
| Active milestone | `state.md` `## Next` names it (authority). Fallback hint only: highest `NN` folder, when Next is silent |
| Active phase | `state.md` `## Next` names the phase plan |
| Plan state | no `## Targets` → **draft**; `## Targets` + `as of <sha>` that still **holds** (sha is an ancestor of HEAD, and every changed path is in `## Targets` or under `.scaffold/`) → **final & fresh**; otherwise → **stale**. A malformed read-set is `go`'s to refuse at load, not a state `status` reports. `go` executes only final & fresh |
| Phase done? | the milestone's `milestone.md` checklist entry is checked (with a date) |
| Milestone ready to close? | `milestone.md` fully checked AND its done-contract met (emergent: only when Adam says the chunk is done). The `roadmap.md` `[done]` flip is the *output* of closing, not a precondition |
| Milestone mode | derived: has `spec/` + pre-written plans → predetermined; else emergent |
| Blocked | `state.md` `## Blockers` has content other than "None." |
| Deferred work parked | the active milestone's `milestone.md` `## Deferred` is non-empty |
| Plan executed? | its `milestone.md` `## Phases` entry is ticked. **Unexecuted** = unticked **or absent** — a plan file with no `## Phases` entry counts as unexecuted (and the missing entry is `checkpoint`'s structural finding). Unexecuted is the set the pivot sweep, the neighbour check and audit's plan-set check walk |
| Phase read-set | the plan's `## Governed by` paths; `go` reads them before executing |

Signals are not mutually exclusive — a session can be blocked AND have an active phase.
`status` surfaces all that apply. No status keyword is stored anywhere; every signal is
read off disk.

## AI Instruction Strategy

### Skills inject fresh instructions at point of need

At 400k tokens deep, whatever the session loaded at the start is far away. A skill dumps precise instructions into context at the moment they're needed. That is why a skill carries its own rules rather than relying on project-level instructions read hours ago — not redundancy, but reliability at depth.

### Don't tell Claude what it already knows

If a behavior is already covered by Claude's defaults, by a hook, or by a skill's own body, no scaffold document restates it.

### Explicit boundaries prevent bleeding

Each skill states what it does NOT do:

- `plan`: scaffold docs only — never code.
- `go`: project files (and optional investigations) only — never scaffold
  truth/execution docs.
- `checkpoint`: scaffold write-back + commit; project code **only** under the closing repair licence (session residue, shown in the pre-commit review) — never new capability.
- `audit`: read-only — grades and reports, never writes.
- `integrate`: ingest only — never executes work or writes project files.

`integrate` is the thinnest skill, and that is deliberate: it owns the *ingest-vs-author*
boundary. A thin skill that holds a clean boundary is worth more than folding its job into
an authoring skill — placing an external artifact as-is (and never cracking a pointer'd
spec open) is the opposite instinct from `plan`, whose job is to dissect and compose. The
thinness reads as intentional, not vestigial.

### Skills present options, not directives

`status` says "you can do X or Y," not "run X now." `plan` ends with options. The user
controls what happens next.

### Gates prevent premature advancement

Interactive phases require explicit user response. ADR writes are the hardest gate of
all: a skill may *propose* a decision but must **stop for Adam's approval** before
writing, superseding, or pruning anything in `decisions/`. `glossary.md` carries the same gate on **additions and definition changes** (removal is ungated), and `milestone.md`'s `## Deferred` carries it on additions.

## Edge Cases

**Freeform work without any skills (except status/checkpoint):**
Collaborate and build. Checkpoint reviews the conversation, captures decisions
(proposing ADRs through the gate), updates the roadmap and state, and runs its
light structural + coherence sweep. Works.

**A later phase insertion stales a downstream plan:**
`plan`, on the pivot, sweeps all unexecuted plans (drafts included) in the active
milestone against the change and flags/rewrites the stale one. That is the *plan-set*
defense. Separately, a plan that was *finalized* and then left while code moved is
caught deterministically at execution time by `go`'s freshness check — a change outside
the plan's declared `## Targets` makes it refuse, name the files, and route to
re-finalize. `checkpoint`'s coherence sweep is the backstop for a finalized
plan whose targets/approach conflict with a later decision.

**A plan depends on a not-yet-approved decision:**
`plan` resolves the ADR gate first — it presents the draft, stops for Adam's approval,
and only then authors the plan premised on it. It never writes a plan on an
unratified decision.

**A later-numbered milestone is pre-created while an earlier one runs:**
Folder order is not the authority — `state.md` `## Next` is. `status` reads the active
milestone off Next, not off the highest `NN`.

**A milestone closes:**
`checkpoint` graduates the spec's enduring rules into `knowledge/` (reconciling and
retiring contradicted docs, surfaced for Adam), flips the `roadmap.md` line to done,
`git mv`s the folder to `milestones/archived/NN-slug/`, stamps `archived: YYYY-MM-DD`
into that folder's `milestone.md` frontmatter, and repoints the roadmap link at the new
path. Only `milestone.md` is stamped — the spec and the phase plans are moved untouched,
because the path already says what they are and a stamp on each buys nothing. It repoints
`state.md`'s `## Next` in the same act — the cursor was pointing into the folder that just
moved, and Next is the authority for what is *active*. And it prints the old and new paths,
because references from **outside** `.scaffold/` (a project `CLAUDE.md`, a code comment, a
README link) break on the move and scaffold neither owns nor sweeps those files.

**A closed milestone turns out not to be done:**
There is a reverse gear, and it is Adam's call rather than a skill's: `git mv` the folder
back, drop the `archived:` key, flip the roadmap line to `[active]` and repoint it, set
`## Next`. It exists because the alternative a session reaches for otherwise is a duplicate
milestone with a copied spec — two specs for one feature, which is the drift the archive was
built to prevent. **Editing in place inside `archived/` is never the answer**: no check in
the system can see it.

**A spec lives outside `.scaffold/` (shared or grandfathered):**
The milestone's `spec/` is a pointer, not a copy. The external spec stays whole and is
maintained in place until the milestone closes; its internals are never cracked open or
absorbed.

**Context crash mid-execution:**
`state.md` Next still points at the milestone + phase plan; the plan persists on disk.
`status` detects the active phase and resumes.

**Requirements discovered mid-session:**
`plan` captures the constraint in `project.md` (as plain truth) or routes a verifiable
invariant to where it's tested (a spec, phase acceptance, or a `knowledge/` doc) — never
as a checkbox in a truth doc.
