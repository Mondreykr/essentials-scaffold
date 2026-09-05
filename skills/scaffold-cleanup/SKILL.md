---
name: scaffold-cleanup
description: Bring a scaffold in ANY prior or partial state up to the current standard. Reads whatever is actually on disk without assuming a shape, works with you to map it onto the current structure, and proves the result conforms. Handles the known pre-restructure layout (single decisions.md, plans/ folder, per-phase roadmap, no architecture.md, no milestones/, missing frontmatter) and also partial, hand-edited, or unfamiliar states — it migrates the gap, not a presumed whole, so it is safe to re-run. Cautious and interactive; confirms every judgment call and stops on anything ambiguous. Use whenever the user has an old, partial, or messy scaffold and wants to migrate, upgrade, clean up, or convert it — even if they only say "migrate the scaffold", "clean this up", or "upgrade the layout". For a fresh project with no scaffold yet, use /scaffold-setup instead.
---

# scaffold-cleanup

The **migrator** to the current scaffold structure.

Every other skill assumes the repo is *already* conformant and computes deterministically
from it. Cleanup is the exception: its input is, by definition, **unknown** — an old
format, a half-finished migration, a hand-edited mess, something unfamiliar. You cannot
write fixed steps for unknown input. So cleanup works differently: it fixes the target
end-state, reads whatever is actually there without assuming a shape, and works with you to
map what it finds onto that target. The intelligence lives in the mapping; the safety
lives in two *fixed* ends — a known objective (below) and a structural self-check that
proves the result reached it (Step 7).

**Cautious and interactive.** Mechanical renames it just does. Every judgment call it
stops and confirms. Anything ambiguous, contradictory, or half-migrated it **surfaces
rather than guesses.** It consults; it does not predict.

**It migrates the gap, not a presumed whole.** Any part already conformant is left
untouched — so cleanup is safe to re-run and safe on a partially-migrated repo.

**Boundary — the one place this skill states it.** Touches `.scaffold/` only. Never: project code; `CLAUDE.md` (scaffold does not own it); a grandfathered spec's internals (its own `DECISIONS.md`/`STATE.md` stay whole — point at it or update paths, nothing more); an ADR without approval (`decisions/` is hard-gated); renumbering a phase or interstitial (`09.1` stays `09.1`); fixing a stale downstream plan (flag it — `plan`/`checkpoint` own re-sweeping); grading docs rule-by-rule against the contracts (`audit`'s sole job; your self-check is structural only); populating `knowledge/` beyond the retroactive graduation pass below (a milestone you are archiving whose close never ran, Adam-approved — nothing else); or guessing on an ambiguous, partial or contradictory state (surface it and stop).

**Run at a clean phase boundary** — this is a structural move; run it when no phase is
mid-build, so no pointer is in flux. Other skills expect the current layout, so run cleanup
*before* them in the install→migrate window.

---

## The objective (the fixed target)

The end-state is exactly what `/scaffold-setup` produces and the contracts define. Every
step serves it; when in doubt about where something goes, this plus the two Laws
(truth≠history; a doc lives at the layer that owns its lifecycle) decide.

```
.scaffold/
  project.md                  identity/scope          } living truth,
  architecture.md             how it's built          } conformant sections,
  roadmap.md                  ## Milestones + ## Backlog (program altitude only)
  state.md                    Active focus / Next / Blockers / Open Questions (NO ## Notes)
  glossary.md                 anchor terms; created empty if absent — never seeded
  knowledge/*.md              durable rules (living)
  decisions/NNNN-slug.md      ADRs (history; 4-digit)
  investigations/YYYYMMDD-slug.md   research (history; date, no dashes)
  milestones/NN-slug/         an ACTIVE or PLANNED milestone
    milestone.md                   ## Objectives / ## Phases (checkbox+date) / ## Done-contract / optional ## Deferred
    spec/                     OPTIONAL — copy or pointer
    phases/NN-slug.md         one phase each (interstitials like 09.1 preserved)
  milestones/archived/NN-slug/   a CLOSED milestone, moved here whole — read-only history
```

The invariants that define **done**:

- The four living-truth docs exist and are conformant; `knowledge/` exists; `glossary.md` exists (created empty if the scaffold predates it — **never seed it with terms mined from the old docs or the code**; it earns entries later, one collision at a time).
- `decisions/` and `investigations/` are **folders** with conformant names.
- Each chunk of work is a `milestones/NN-slug/` container (`milestone.md` + `phases/`, optional `spec/`).
- Every milestone the roadmap marks `[done]` sits under `milestones/archived/NN-slug/`, its
  `milestone.md` carries an `archived: YYYY-MM-DD` key, and the roadmap line's path points there.
  No `[active]` or `[planned]` milestone is under `archived/`.
- **None of the legacy shapes remain:** no single `decisions.md`, no standalone `plans/`,
  no per-phase build plan inside `roadmap.md`, no `## Notes` in `state.md`, no catch-all
  section anywhere, no `project.md` checkbox.
- **No pre-rename names remain:** no milestone `plan.md` (it's `milestone.md`), no
  `type: milestone-plan` (it's `milestone`), no `type: phase-brief` (it's `phase-plan`).
- Every `.scaffold/` doc carries `type` / `schema_version: 2` / `updated` frontmatter (a
  `schema_version: 1` doc is pre-rename and not yet migrated).
- No pointer dangles **within the LIVE `.scaffold/` docs** (the sweep's scope — pointers held by files scaffold does not own are out of scope and are not claimed). **`milestones/archived/` is excluded:** its files are frozen, so a pointer that dangles because its target later moved cannot be repaired without editing a closed record — which is forbidden. A dangling pointer there is reported, never fixed.

## Step 1: Inventory — read everything, assume nothing

Read whatever exists. Do not presume which files are present or what shape they're in —
scan and record what you actually find: `.scaffold/project.md`, `roadmap.md`,
`state.md`, `decisions.md` and/or `decisions/`, `architecture.md`, everything under
`plans/`, `knowledge/`, `investigations/`, `milestones/`, and anything else in `.scaffold/`.
Note frontmatter presence and `schema_version` on each doc.

Two hard stops:

- **No `.scaffold/` at all** → stop: "No scaffold files found — run /scaffold-setup first
  (setup is for fresh projects; cleanup migrates an existing one)."
- **Already fully conformant** (every invariant above holds) → stop: "Already on the
  current structure; nothing to migrate."

Otherwise, produce a plain **"here's what I found"** inventory — the real state, not a
format label:

> "Inventoried the scaffold. Current state:
> - `roadmap.md` — holds a per-phase build plan (target: program-altitude index + Backlog)
> - `plans/` — N phase plans (incl. interstitials 06.1, 09.1)
> - `decisions.md` — single file, N entries (target: curated `decisions/` folder)
> - `architecture.md` — absent (target: stood up from decisions/run-env/the real code)
> - no `milestones/` container; docs lack frontmatter
> - `investigations/2026-06-11-*.md` — nonconformant name
> - [anything unexpected, partial, or contradictory]"

## Step 2: Diagnose the gap and triage

Compare what you found against the target, and sort **every** piece into one of three
buckets. This triage is what makes cleanup safe on an unknown repo:

- **Mechanical** — unambiguous, no judgment: rename to a conformant name, move a file to
  its target path, stamp frontmatter on a doc whose content is already right, strip a
  `phase-` prefix. Apply these in Step 6 (after the reference sweep).
- **Judgment** — needs your call: the milestone slug; which legacy decisions become ADRs;
  an architecture-vs-knowledge tiebreak; which doc is the milestone plan; how many
  milestones the old work becomes. Gate each with you in Step 3.
- **Ambiguous / partial / contradictory → STOP and surface. Do not guess.** This is the
  safety valve for the "unknown" repo. Examples: a half-migrated layout (`milestones/` AND
  `plans/` both present; `architecture.md` present but unstamped; a `decisions/` folder AND
  a `decisions.md`); a shape that matches no known pattern; two docs that contradict each
  other; a `## Next` that doesn't resolve; a `schema_version` newer than this skill knows
  (a *future* format — cleanup only migrates *up to* the current version, never down).
  Report exactly what is inconsistent and ask how to proceed. **Never run a downstream step
  against an assumption the inventory didn't confirm.**

**Idempotency.** Any invariant already satisfied is left untouched — cleanup migrates the
gap. A doc already stamped and conformant is skipped, not rewritten; a plan already at its
target path is not moved again.

## Step 3: Propose the plan (consult, gate the judgment calls)

Lay out the whole plan as a single proposal, then proceed gate by gate. Write **nothing**
until Step 6. The judgment calls to confirm (only those the inventory actually surfaced):

1. **The milestone slug(s).** The old `plans/` + roadmap build plan become a milestone —
   default a single `01-<slug>` drawn from the work's identity. If the inventory shows the
   old layout already tracked multiple distinct chunks, propose one container each,
   preserving their order. The slug is a **sticky namespace** — get it right now.
2. **Which doc is the milestone plan** — confirm the old `roadmap.md` build-plan body is
   the source for `milestone.md`.
3. **Which legacy decisions become ADRs** (Step 5 curation) — flag that most retire to git.
4. **The spec, if any** — if a spec scoped this work and lives elsewhere, confirm it stays
   in place and you write a **pointer**, not a copy.

## Step 4: Reference sweep — BEFORE any move

Map every pointer first, so nothing dangles. Grep `.scaffold/` for references that break on move/rename:

- `state.md` `## Next` → the milestone (`milestone.md`) and phase-plan paths it points at
- `roadmap.md` → any `plans/phase-*` references
- phase plans → cross-links to siblings, to `decisions.md`, to investigations
- knowledge docs → references to decisions by old path

Build a **rename map** (old → new) covering every moving file. Report it; repoint all in
the Step 6 pass. If a pointer already dangles, flag it — don't invent a target.

## Step 5: The mapping playbook — apply what the inventory found

How the known legacy patterns map onto the target. Apply only the ones your inventory
turned up; skip the rest. Each assumes triage confirmed it — anything ambiguous went to
the STOP bucket, not here.

### Roadmap split by altitude (if `roadmap.md` holds a per-phase build plan)

The old `roadmap.md` mixes a **program index** and a **per-phase build plan** — split them.

**Build-plan body → `milestones/NN-slug/milestone.md`:** preserve the **checkbox + completion-
date checklist exactly** (the disk-derivable done-signal, not a forbidden enum — don't
reformat dates into prose); carry over the objective and the done-contract; keep
annotations terse. A `phase-00`-style "master build plan / plan authored" entry is **not**
a phase plan — it collapses *into* `milestone.md` as the plan's own preamble, never into
`phases/00-*.md`. Target shape (stamp frontmatter):

```markdown
---
type: milestone
schema_version: 2
updated: [today]
---

# Milestone NN — <slug>

## Objectives
[from the old build plan's objective]

## Phases
- [x] NN-slug — one-liner (YYYY-MM-DD)
- [ ] NN-slug — one-liner

## Done-contract
[the acceptance the phases roll up to]

## Deferred
[OPTIONAL — only if the old layout carried ground-level deferred work that clears the
admission bar. One `- [ ]` line each. See the backlog-split note below for what routes here
vs. roadmap Backlog, and what doesn't survive at all.]
```

`## Backlog` + a freshly-authored `## Milestones` index STAY in `roadmap.md`: repurpose
it to program altitude; author a `## Milestones` index, one line per milestone with a
`[done] | [active] | [planned]` token + folder pointer. Split the old backlog by the
tied-to-the-active-milestone test (where most legacy bloat hides): work **not tied** to
the active milestone (a standalone future feature) stays in `## Backlog` as one terse
`- [ ]` line; work **tied** to it (a bug, cleanup, debt, residual in its code) moves to
that milestone's `milestone.md` `## Deferred`. **First, though, run each item through the
admission bar** — a legacy list is exactly where items that never deserved a line accumulate,
and migrating them wholesale launders that debt into the new structure. An item survives
only if it **needs a decision**, is **materially out of scope**, or is **real work that
can't ride along safely**; the rest are **proposed for dropping** (cleanup never touches
project code, so it cannot fix them in place — it surfaces each with what the fix would be
and Adam decides). Make each surviving line **one line** — compress a
multi-line paragraph to a pointer (detail stays in git). Drop `someday / never` entries.
**Rewrite any backlog line the migration makes stale** (e.g. a "multi-user/tenancy" line
should point at the relevant ADR + a future milestone number, not imply debt the current
architecture doesn't carry) — surface each rewrite and each backlog→deferred move. Target
shape (stamp frontmatter):

```markdown
---
type: roadmap
schema_version: 2
updated: [today]
---

# Roadmap

## Milestones
- [active] NN-slug — [what this chunk delivers] → milestones/NN-slug/

## Backlog
- [ ] [program-altitude future feature, one line each]
```

### Phase plans → the milestone (if a `plans/` folder exists)

Move every `.scaffold/plans/phase-*.md` into `milestones/NN-slug/phases/`:

- **Preserve interstitials — NEVER renumber.** `phase-09.1-currency-model.md` →
  `phases/09.1-currency-model.md`. `NN` is the roadmap ordinal; `09.1` is a surgical
  insertion that must keep its place.
- Strip the `phase-` prefix (new convention is `phases/NN-slug.md`); keep number + slug.
- `phase-00` does **not** move here — it folded into `milestone.md` above.
- **Stamp `type: phase-plan` frontmatter** and, where the old plan used `## Goal`, rename
  to `## Objective` (current shape: `# Phase NN — <slug>` / Objective / Scope / Approach /
  Acceptance).
- `git mv` where git is present; repoint every reference from the Step 4 sweep.

If a pre-written *downstream* plan has been **staled** by a later change (e.g. a Phase 10
plan written before a Phase 9.1 insertion), don't fix it here — just **flag it**:
> "Note: `phases/10-*.md` predates the 09.1 insertion and may be stale. Migration keeps it
> as-is; run /scaffold-plan to re-sweep downstream plans."

### Pre-rename migration — `brief`→`plan`, `plan.md`→`milestone.md` (if a v1 repo)

Independent of the pre-restructure move above: a repo that already has `milestones/NN-slug/`
but predates the rename (a `plan.md` file, `type: milestone-plan` / `type: phase-brief`, or
`schema_version: 1`) migrates in place. This applies even to an otherwise-current repo — it
is the sole thing cleanup does when only the rename is behind.

- **Each milestone file:** `git mv .scaffold/milestones/NN-slug/plan.md
  .../milestone.md`; rewrite its frontmatter `type: milestone-plan` → `type: milestone`.
  Content is unchanged (Objectives / Phases / Done-contract / optional Deferred).
- **Each phase plan** (`phases/*.md`): rewrite `type: phase-brief` → `type: phase-plan`.
  Do not fabricate a `## Targets`/`as of <sha>` — cleanup cannot judge "validated against
  current code", and inventing one would forge the readiness signal. A plan with no
  `## Targets` stays a **draft** (correct — it gets a real `/scaffold-plan --final` pass
  before its next `go`).

  A plan that already carries `## Targets`: strip the section, demoting it to a draft,
  and tell the user you did. Migration is not a code change, so every path it moves is
  under `.scaffold/` — which means `go`'s freshness check would read that plan as **fresh**
  and execute it, on the strength of a stamp cleanup can't vouch for and that may predate
  real code drift. Stripping is the only thing that restores the guarantee, and a draft is
  a valid state (no conformance break). Say so plainly:
  > "`<plan>` carried a `## Targets` stamped `as of <sha>` that I can't validate — I've
  > removed it, so it's a draft again. Run `/scaffold-plan --final` before `go`."
- **Bump `schema_version: 1` → `2`** on **every** `.scaffold/` doc (the format epoch;
  uniform, so a lingering `1` is the un-migrated marker).
- **Repoint references** (Step 4 sweep): any `plan.md` path (in `state.md` `## Next`, cross-links) becomes `milestone.md`. Phase-plan file paths are unchanged
  (they always lived at `phases/NN-slug.md`), so `## Next`'s phase pointer needs no move.
- **Ambiguous** (e.g. both a `plan.md` and a `milestone.md` present, or a mixed
  `schema_version`) → **STOP and surface**, per cleanup's core rule — never guess.

### Stand up `architecture.md` (if absent or thin)

Create it by sorting durable technical truth out of where it hides — architectural content in `decisions.md`, durable run/env facts in `state.md`, and the real code. **Tiebreak per fact:** changes on *re-platform* (business rule
stays) → `architecture.md`; changes only when the *business rule* changes → `knowledge/`
(not cleanup's job to populate here — flag for a later `integrate`/`plan`; the sole exception is the retroactive graduation pass when archiving a milestone whose close never ran). Target shape (stamp
frontmatter; current section set):

```markdown
---
type: architecture
schema_version: 2
updated: [today]
---

# Architecture

## Stack
## Tenancy / isolation
## Auth
## Data access
## Deployment
## Conventions
## Run / env
```

There is **no `## Decisions` section** — each truth statement references the ADR that set
it inline (`[[NNNN-…]]`); the `decisions/` folder + these references *are* the index. Stand
up the truth statements now; **wire the ADR references while curating decisions below**,
once the ADRs are promoted and numbered.

### Curate decisions — promote the few (Adam-gated, if a monolithic `decisions.md` exists)

**Decisions are *curated, not split.*** Most legacy `decisions.md` entries are build-records
that don't clear the high ADR bar (rare, architecturally-significant, cross-cutting choices
you'd want the *why* of in a year). Detect the situation and act accordingly:

- A single `decisions.md` with many entries → run the promote-the-few session below.
- An existing `decisions/NNNN-slug.md` folder → already-promoted ADRs; leave them, renumber
  nothing, fold survivors in *after* the existing numbers.
- A grandfathered spec's own internal decisions file → **never cracked open.** Leave whole.

Walk the entries, classify each as a proposed ADR or a build-record, present grouped:

> "## Decision curation — N entries in `decisions.md`
> **Proposed ADRs** (clear the bar — durable, cross-cutting *why*):
> 1. [date — title] → `decisions/NNNN-slug.md` — [why it qualifies]
> **Retire to git** (build-records below the bar — git keeps them):
> - [date — title], …
> No ADR is written without your approval. Which do you confirm?"

**STOP. Wait for explicit approval** — stricter than every other file by design. For each
approved ADR write `.scaffold/decisions/NNNN-slug.md` (stamp `type: decision`; `# NNNN —
<title>`; `**Status:** Accepted`; Context / Decision / Why / Alternatives considered /
Consequences). Number sequentially, 4-digit, zero-padded, continuing after any existing
ADRs. The rest **retire to git** (they leave with the deleted `decisions.md`; no git? fold
each as a one-line "retired" note rather than losing it). Wire architectural ADRs into
`architecture.md`'s references in this same pass (the coupling rule).

### Normalize nonconformant names (if any)

- **Investigations** use `YYYYMMDD-slug` (date, no dashes): `2026-06-11-gap-map.md` →
  `20260611-gap-map.md`. Stamp `type: investigation`.
- **Decisions** `NNNN-slug` (4-digit, continuing the sequence); **phases** `NN-slug`
  (2-digit) — preserve interstitials.
- `git mv` to preserve history; repoint every reference from the Step 4 sweep. Report each
  rename (mechanical, but list them so the sweep is auditable).

### Archive the closed milestones (if any sit outside `archived/`)

A scaffold created before the archive rule leaves every closed milestone in
`milestones/`, where its folder is indistinguishable from a live one and its spec reads
as a current contract. For each milestone `roadmap.md` marks `[done]`:

- `git mv .scaffold/milestones/NN-slug .scaffold/milestones/archived/NN-slug` — whole, and **renamed not at all**; create `archived/` on the first one. **Verify the destination doesn't already exist first** — cleanup is re-runnable and a partially migrated repo may already hold it; `git mv` errors (a plain `mv` would silently nest `archived/NN-slug/NN-slug/`).
- **Before the move, check `state.md`'s `## Next`.** If it resolves inside the folder you are about to archive, **do not follow it to the new path** — that is the one repair the rename map gets wrong. `## Next` is the authority for what is *active*, so a cursor inside `archived/` makes `scaffold-status` brief closed work as live and `scaffold-go` execute a plan out of a frozen record. Repoint it at the next live milestone, or write "no active phase; run `/scaffold-plan`."
- Stamp `archived: YYYY-MM-DD` into that folder's `milestone.md` frontmatter, below `updated:`. Use the date the roadmap line flipped to `[done]` if git can show it
  (`git log -S"[done] NN-slug" -- .scaffold/roadmap.md`), else the file's last commit
  date. **`milestone.md` only** — the spec and phase plans move untouched.
- Repoint that roadmap line's path at `milestones/archived/NN-slug/`, and repoint any
  other `.scaffold/` reference the Step 4 sweep found.

Before each move, run the graduation pass that close should have run. This is the
last moment the spec is legal to read for rules — after the move nothing walks it again.
So for each milestone about to be archived, read its `spec/references/` (or its accrued
rules) and account for every rule: it graduates to `knowledge/`, it has a code home that
enforces it (name the file), or it died with the milestone. **Surface the set for Adam
before writing any of it** — graduation is gated, exactly as it is at close. A repo
migrating to this layout has never had that pass run, so skipping it seals every closed
milestone's rules in one command.

Report each move, naming the old path and the new one — references from outside
`.scaffold/` break on it and scaffold does not sweep those. **Contents are never edited**
once moved.

### Repoint `state.md` and drain `## Notes` (if present)

Stamp `type: state`. Repoint `## Next` to the new path per the rename map. Ensure exactly
the four sections exist in order (Active focus / Next / Blockers / Open Questions), with
literal `None.` where Blockers/Open Questions are empty. **There is no `## Notes` section** —
if the old `state.md` carried one, **drain it**: durable run/env facts → `architecture.md`;
a deferred work item → the milestone's `milestone.md` `## Deferred` **through the same admission bar and Adam gate used everywhere else** (needs a decision / materially out of scope / can't ride along safely; propose, don't append — a drain is not an exemption); a resume precondition →
folded into `## Next`; a blocker → `## Blockers`. Surface each re-home. Stamp `type:
project` on `project.md` and `type: knowledge` on any `knowledge/*.md`.

## Step 6: Present the full change set, then execute in one pass

Present the **complete** change set at once — moves, new files, renames, rewrites,
deletions (`decisions.md`, the now-empty `plans/`):

```
## Migration plan
**Milestone(s):** milestones/NN-slug/ (created)
  milestone.md   ← roadmap build-plan body (checklist preserved)
  phases/   ← N plans moved from plans/ (interstitials preserved)
  spec/     ← pointer to [path] (if any)
**roadmap.md** → program altitude (Milestones index + Backlog); frontmatter stamped
**architecture.md** → NEW (from decisions + run/env + the real code)
**decisions/** → N ADRs promoted (Adam-approved); M build-records retired to git
**investigations/** → K names normalized to YYYYMMDD; frontmatter stamped
**state.md / project.md / knowledge/** → frontmatter stamped; Next repointed; [## Notes drained → re-homed]
**Reference sweep:** N pointers repointed, 0 dangling
**Already-conformant (left untouched):** [anything the gap-diagnosis skipped]
**Staleness flags:** [downstream plans to re-sweep with /scaffold-plan, if any]
```

**STOP. Wait for explicit approval before writing anything.** Incorporate any modifications
and re-present. On approval, apply in one pass:

1. Create `milestones/NN-slug/{milestone.md, phases/}` and the `spec/` pointer if applicable (a pointer file carries `type: spec-pointer` / `schema_version: 2` / `updated:` — `audit` reads `type` as authoritative and never infers it).
2. `git mv` the plans and renamed investigations (preserve history).
3. Write `architecture.md`; write approved `decisions/NNNN-slug.md` ADRs.
4. Rewrite `roadmap.md`; update `state.md`, `project.md`; stamp all frontmatter.
5. Repoint every reference from the sweep.
6. Create `.scaffold/glossary.md` if absent — frontmatter `type: glossary` / `schema_version: 2` / `updated:`, an `# Glossary` heading, and the placeholder line. **Empty is correct**: never seed it with terms mined from the old docs or the code.
7. Delete the migrated `decisions.md` and the now-empty `plans/`.

## Step 7: Verify against the target, then commit

Before committing, **prove the mechanical result reached the target.** Run the same light
structural + coherence self-check `/scaffold-checkpoint` runs — over all migrated docs:

- **Structural** — each doc well-formed at the stable, Law-level shape: required sections
  present and in order, frontmatter correct, no catch-all / no append-log, no `project.md`
  checkbox.
- **Coherence** — cross-references resolve, **no pointer dangles within live `.scaffold/`** (`milestones/archived/` is excluded — it is a frozen record and a dangling link inside it is not yours to "fix"), `## Next` resolves and does NOT resolve inside `archived/`, no Law-1/Law-2 violation, no duplication.

This is the *structural* net only — **not** deep per-rule grading, which is
`/scaffold-audit`'s sole job (duplicating the contract rules here would re-create the exact
drift the system prevents). If a check fails, fix it before committing; if the fix needs a
judgment call, surface it.

With git: `git add -A .scaffold/ && git commit -m "scaffold: migrate to milestone
structure"`. Summarize what moved, what was promoted vs retired, what was renamed, what was
left untouched, and any staleness flags. **Then recommend `/scaffold-audit`** for the
independent deep conformance + reality pass — the right move after a migration this size.

---
