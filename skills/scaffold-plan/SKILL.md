---
name: scaffold-plan
argument-hint: "[--draft|--final] [what to plan]"
description: Persist an agreed direction into the scaffold docs — the single authoring skill. Routes each thing to its one home: a backlog idea to a backlog/ file + roadmap index line, a new chunk to a milestone + milestone.md, how-to-build-it to phase plans, a cross-cutting truth shift to architecture.md, and always updates state.md's Next cursor. Proposes ADRs (Adam-gated) and sweeps stale plans on a pivot. Use whenever the user wants to plan, scope, decide what to build next, add a milestone or phase, capture a decision or requirement, or write down a direction you've agreed on — even if they only say "plan this", "let's scope it", or "write that down". Writes scaffold docs only, never code.
---

# scaffold-plan

The single scaffold-**authoring** skill. The conversation before you needs no skill; your job is to **persist** the direction you and Adam agreed on into the right docs, each thing to its one home, and to **finalize** a plan against the current code when asked.

**Boundary.** You write scaffold docs only. Never: code or project files (`scaffold-go`); the post-build sweep or write-back of results (`scaffold-checkpoint`); a plan premised on an unratified decision (resolve the gate first); skipping the Phase 4 confirmation; an ADR, `## Backlog` line or `## Deferred` line without Adam's explicit approval (propose, STOP); anything under `milestones/archived/` (read it freely; a rule found there that is still live is restated in `architecture.md` or `knowledge/`). The finalize pass reads code and still writes only the plan.

**Precondition.** `project.md`, `architecture.md`, `roadmap.md`, `state.md` exist under `.scaffold/`. If not, stop: "Scaffold files missing or incomplete — run /scaffold-setup first."

**Version guard.** Any doc with `schema_version: 1`, `type: milestone-plan` / `type: phase-brief`, or a milestone folder holding `plan.md` → stop: "Old scaffold format (pre-rename) — run /scaffold-cleanup to migrate first; the current skills will misread it."

**Frontmatter.** Every doc you create or touch carries `type` / `schema_version: 2` / `updated:`; set `updated:` to today.

---

## Guards

Read `state.md` and `roadmap.md` first.

- **Blockers present** (`## Blockers` ≠ "None."): "State shows blockers: [reason]. Resolved? If yes, we plan forward; if not, let's address the blocker first." Wait.
- **Executed-but-unrecorded work** — `go` ran in *this* conversation and no `checkpoint` followed (the box is still unticked; this is a conversation signal, not a disk fact): "There's executed-but-unrecorded work on [plan]. Run /scaffold-checkpoint first to record it, then re-plan." Stop.

## Inline description

Invoked with a description ("plan add an export endpoint"): treat it as the agreed direction, run Phase 1 silently, then weigh it. A backlog idea → run the admission bar, **propose the index line and the file's four sections and wait**, then write both — nothing more. Anything creating a milestone, authoring plans, shifting architecture truth or touching a decision → Phase 2.

## Draft or final (`--draft` / `--final`)

A plan's state is derived from its content, never stored: **draft** = no `## Targets` (code-blind, may be written ahead of the code); **final** = `## Targets` stamped `as of <sha>` plus `## Governed by` (or the fixed `Governed by: none` line in `## Approach`).

Absent the argument, **ask**: "Draft this, or finalize it against the current code?" — you may name the likely option, never decide it. `--final` (or the user choosing finalize) → run `references/finalize.md` on the plan `## Next` points at, or the one named, in place of Phases 1–6 (it does its own reading), then report per Phase 7. Everything else runs Phases 1–7.

## Phase 1: Triage (silent)

Read: `state.md` (a `## Next` already carrying a concrete instruction from `checkpoint` — "re-finalize `…/04-y.md`, its `## Targets` predate [[0007-…]]" — is the agreed direction; confirm it in Phase 2 and act on it); `roadmap.md`; `project.md`; `architecture.md`; `glossary.md` if present (write in the project's words; entries are `checkpoint`'s to propose). Then the **active milestone** — the one `## Next` names; folder order is only a fallback when Next is silent: its `milestone.md`, the phase plan Next points at, its `spec/` (follow a pointer, never crack open the target's internals), relevant `knowledge/`. Scan `decisions/` and `investigations/` by filename; read what is directly relevant.

Assess: where does the direction land (backlog idea / new milestone / plans / requirement / architecture-truth shift / decision)? **Is it a pivot** — a decision reversed, or phases reordered, replaced or inserted in the active milestone (an interstitial like `09.1` is the canonical case)? **Does any intended plan rest on a not-yet-approved decision?**

## Phase 2: Confirm direction — WAIT

Skip only for an unambiguous inline one-liner. Restate in one sentence: "So the direction is [restatement]. Right?" Wait. The user's direction overrides the docs. If they don't know what to work on, surface the milestone index and open questions and help them choose — never author against a guess. If the direction changes mid-discussion, drop the stale proposal and re-confirm.

## Phase 3: Resolve the decision gate FIRST

Never author a plan premised on an unratified decision. If the direction rests on a significant, durable, cross-cutting choice not yet in `decisions/`, resolve it before authoring anything that depends on it. A choice clears the **ADR bar** only if a reader would want the *why* in a year — not a routine guardrail or build-record; below the bar, write nothing.

1. **Propose** the full draft: `NNNN — [title]` · Status: Proposed · Context · Decision · Why · Alternatives considered · Consequences.
2. **STOP. Wait for Adam's explicit approval.**
3. On approval write `.scaffold/decisions/NNNN-slug.md`: `type: decision`; `# NNNN — <title>`; `**Status:** Accepted`; `## Context` / `## Decision` / `## Why` / `## Alternatives considered` / `## Consequences`. `NNNN` is the next sequential number, 4-digit zero-padded. If architectural, add or update its referencing statement in `architecture.md` (`[[NNNN-…]]`) in the same turn — the references are the index.
4. **Superseding:** flip the prior file's `Status:` to `Superseded by [[NNNN-…]]`, write a NEW file, update the referencing architecture statement — same turn. Never edit the original ruling.

## Phase 4: Confirm the slicing, then the write-set

**4a — the slicing** (only when authoring new phase plans). Present the cut, one line per phase — "**07-slug** — [what it delivers, and what you'd see working]" — and ask: "Right number of phases, cut in the right places?" Wait. Three rules:

- **Vertical slice.** Each phase cuts through every layer the change touches — no further — and ends in something observable (a backend-only phase qualifies when it can be run and checked in its own scope). No horizontal cuts (all the schema, then all the queries, then the wiring).
- **One agent session per phase.** A phase needing a mid-phase `/clear` is two phases.
- **Wide refactor → expand–contract.** Add the new form, migrate call sites, remove the old: three phases, green at each boundary.

**4b — the write-set.** State exactly what you'll touch — "`roadmap.md` — add backlog index line", "`backlog/<slug>.md` — new", "`milestones/NN-slug/phases/07-slug.md` — new phase plan", "`milestone.md` — add Phase 07 to the checklist", "`state.md` — Active focus + Next", … — and ask "Approve?" Wait; adjust to whatever Adam changes.

## Phase 5: Author — one home each

Write only what the direction calls for. Every datum has exactly one home below; never add a catch-all / "misc" / "notes" section — a datum with no home is a design question for Adam, not a bucket.

- **Admission bar, before routing.** An item earns a `## Deferred` / `## Backlog` line only if it **needs a decision**, is **materially out of scope**, or is **real work that can't ride along safely**. Clears none → fixed in place or dropped, never parked. Propose each addition with the gate it clears; write only what Adam approves. Removal is ungated.
- **Backlog ↔ Deferred — one test:** *tied to the active milestone (its scope, code or goal)?* Not tied, or no active milestone → `backlog/<slug>.md` (`type: backlog`; `## What` / `## Trigger` / `## Shape` / `## Not doing`, `Unknown.` where not yet known; it holds shape and cites `knowledge/` / `decisions/`, never restates them) plus its index line `- [ ] <slug> — <one line> → backlog/<slug>.md` in `roadmap.md` `## Backlog`, always both. Tied → that milestone's `## Deferred`, one terse `- [ ]` line. Never ticked; an item leaves by removal when promoted or shipped.
- **Grooming.** You own *promotion*: pull an item into a milestone or phase plan (its `## Shape` and `## Not doing` inform the scope) and delete its file and index line in the same write. Never remove an item as "done" on your own judgment — shipped-removal is `checkpoint`'s, stale-detection `audit`'s. When an item no longer clears the admission bar, say so and remove it on Adam's nod.
- **New milestone** → `.scaffold/milestones/NN-slug/`. `NN` = one above the highest across BOTH `milestones/*/` and `milestones/archived/*/` (counting live folders alone re-issues `01` once earlier milestones are archived). The slug is a sticky namespace. Seed `milestone.md`: `type: milestone`; `# Milestone NN — <slug>`; `## Objectives`; `## Phases` (checkbox + completion-date slot per phase); `## Done-contract`. Add it to `roadmap.md` `## Milestones` (`[planned]` / `[active]` token + one-liner + folder pointer). Heavy scoping → `spec/`, the spec itself or a pointer file.
- **Phase plan(s)** → `milestones/NN-slug/phases/NN-slug.md`, each added to the milestone's `## Phases`. Numbers reset per milestone; interstitials (`09.1`) allowed and preserved — never renumber siblings. `type: phase-plan`. Sections: `# Phase NN — <slug>`; `## Objective` (what it delivers, a sentence or two); `## Scope` (numbered deliverables `go` executes, human-owned items marked `[USER]`; an investigation deliverable notes `Output: .scaffold/investigations/YYYYMMDD-slug.md`); `## Approach` (key decisions and what to watch — point at the spec or ADR, never copy); `## Acceptance` (an outcome the user can observe without reading code — never "tests pass"). A fresh plan is a **draft**: no `## Targets`, no `## Governed by`; only finalize adds them.
- **Requirement / product constraint** → `project.md` (`## Scope` or `## Not building`) as plain truth, **never a checkbox**. A verifiable invariant goes where it is tested — a plan's `## Acceptance`, a done-contract, `spec/`, or `knowledge/` — not a truth doc.
- **Cross-cutting technical-truth shift** → `architecture.md`, in place, only when the direction changes how the system is built. Tiebreak: changes on re-platform → `architecture.md`; changes only when the business rule changes → `knowledge/`. Apply the ADR coupling rule.
- **Durable invariant settled in discussion** → `knowledge/*.md`, in the contract's form (invariant + why + pointer to where code enforces it), only when it is load-bearing and has no single code home.
- **`state.md`, always.** **Active focus** — one plain-words paragraph. **Next** — the cursor: milestone + phase plan path, e.g. "Execute `milestones/01-rebuild/phases/07-slug.md` — say 'go ahead' or run /scaffold-go." **Blockers / Open Questions** — only what the discussion resolved or surfaced; remove resolved lines. No `## Notes`: a resume precondition rides in `## Next`, a run/env fact goes to `architecture.md`.

**Auto-finalize when next up.** If a plan you just authored is the one `## Next` will point at, offer: "I'll finalize 07-slug now so it's ready to run?" — on yes, run `references/finalize.md` without re-invocation, **after** Phase 6's sweep on a pivot (it rewrites the siblings the neighbour check reads). **Only that one plan.** Siblings stay drafts: a stamp against code that will move before they run arrives at `go` stale.

## Phase 6: Pivot — stale-plan sweep

Run whenever the direction is a pivot. For **every unexecuted plan** in the active milestone, drafts included (executed ones are history): re-read it against the change; if its scope, approach or acceptance now conflicts, **rewrite it in place**, or propose removing it and updating `milestone.md`. Rewriting a **finalized** plan demotes it to draft: delete its `## Targets` in the same edit (a kept stamp still reads *final & fresh* to `go`) and report `rewritten → draft, needs --final`. Report each plan `OK / rewritten / removed`. A plan authored earlier in this invocation is swept like any other.

## Phase 7: Summary + route

Report per file: roadmap / milestone-index changes; milestone created; plans authored or rewritten (+ checklist updates); architecture / project / knowledge changes; decision proposed and its status; state updates (Active focus + new Next); sweep results on a pivot; on a finalize, the `## Governed by` entries and each neighbour-check resolution. Then:

> "[Summary]. Ready to build — say 'go ahead' or run /scaffold-go. Or keep planning."
