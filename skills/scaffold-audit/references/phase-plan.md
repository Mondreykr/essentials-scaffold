---
schema_version: 2
---

# Contract — `milestones/NN-slug/phases/NN-slug.md` (phase plan)

**Purpose.** The atomic execution unit: one phase's scope, approach, and acceptance.
Authored by `scaffold-plan`, executed by `scaffold-go`, persists as the record.

**Band.** Execution — temporal; persists in place (may go stale; see Rules).

**After the milestone closes it is FROZEN.** `scaffold-checkpoint` moves the whole milestone folder to `milestones/archived/NN-slug/`; this file travels with it, unrenamed and unstamped — only the milestone's `milestone.md` carries the `archived:` date, because the path already marks everything beneath it. Nothing edits it afterwards, and nothing cites it as a statement of current behaviour: it records what was built. A rule still live at close lives in `knowledge/` or `architecture.md` instead.

**Owner(s).** Created/updated by `scaffold-plan` (+ stale-sweep on pivot), executed by
`scaffold-go`; on completion `scaffold-checkpoint` ticks the milestone's `## Phases`
checklist (this file itself isn't modified); moved by `scaffold-cleanup` (preserving
interstitials); moved into `milestones/archived/` at milestone close by
`scaffold-checkpoint`. **Written by nothing once archived.**

## Required frontmatter

```yaml
---
type: phase-plan
schema_version: 2
updated: YYYY-MM-DD
---
```

## Required structure

```markdown
# Phase NN — <slug>

## Objective
[What this phase delivers, in a sentence or two.]

## Scope
[What's in — the numbered deliverables. `scaffold-go` reads THIS to bound execution.
Mark any human-owned deliverable `[USER]` (e.g. `2. [USER] create the OAuth app`).
Out-of-scope discoveries route to checkpoint, never silent expansion.]

## Approach
[How to build it.]

## Acceptance
[How we know the phase is done — an OBSERVABLE outcome the reader can verify
without reading code (a behavior, an output, a visible state), never "tests pass".]

## Governed by   ← OPTIONAL in the contract; MANDATORY on a FINALIZED plan
- `.scaffold/knowledge/<slug>.md` — [which rule in it constrains this phase]
- `.scaffold/decisions/NNNN-<slug>.md` — [which ruling constrains this phase]

## Targets   ← OPTIONAL; present only on a FINALIZED plan
_as of <sha>_
- `path/to/file.ts` — [what this phase touches here]
- `path/to/dir/` — [a trailing slash covers everything beneath]
- non-path note: [an interface or surface, prose — ignored by the freshness comparison]
```

## `## Governed by` — the read-set (the twin of `## Targets`)

`## Targets` is what the phase **writes**; `## Governed by` is what it must have **read**: the `knowledge/` and `decisions/` documents whose rules bind this phase, each a repo-relative path with a short note naming *which* rule binds. `scaffold-go` resolves and reads every entry in full before executing, so an entry is a path, never a `[[wikilink]]`, a title or prose — a pointer `go` cannot resolve is a rule nobody loaded. **Point, don't copy:** a plan does not restate a rule it points at; `## Approach` says how the rule applies to this phase.

**Mandatory on a finalized plan, optional on a draft.** A finalized plan carries exactly one of two forms: the section with at least one entry, or — for a phase governed by nothing — this sentence in `## Approach`, **verbatim**, so the check is a grep and not a judgement about prose:

> Governed by: none — no `knowledge/` or `decisions/` document constrains this phase.

**What belongs.** Only `.scaffold/knowledge/*.md` and `.scaffold/decisions/*.md` — the two homes of durable rules. Not the milestone spec (scope, not rule), not a sibling plan (a dependency on one is a seam in `## Approach`), not source files (those are `## Targets`). A `decisions/` entry names an **Accepted** ADR: a `Superseded` one is kept on disk and resolves while its ruling is dead, so it points at its successor instead; a `Proposed` one resolves through the ADR gate before finalize completes.

## Draft vs. final (the two plan states)

A plan has two states, **derived from content with grounding evidence** — never a
stored status enum (Principle 7). The `## Targets` section is the signal, and its
`as of <sha>` stamp is the evidence that makes the signal auditable:

- **no `## Targets`** → **draft** (code-blind; may be pre-written; not executable).
- **`## Targets` present and its stamp still HOLDS** → **final & fresh** (nothing has
  moved that this plan didn't declare; `scaffold-go` may execute).
- **`## Targets` present and its stamp does NOT hold** → **stale** (something moved
  outside what the plan declared; must be re-finalized before `go`).

**The stamp holds** when both are true — a deterministic test, no judgement:

1. `<sha>` resolves **and is an ancestor of HEAD** (`git merge-base --is-ancestor <sha> HEAD`).
2. Every changed tracked path between `<sha>` and the working tree
   (`git diff --name-only <sha> --` — this covers the committed span *and* uncommitted
   edits in one command) is either **matched by a path entry in `## Targets`** or lives
   **under `.scaffold/`**.

Anything else → stale, and `go` names the offending files.

**Why those two exemptions.** The check asks *"did anything move that this plan didn't
declare?"*, not *"did the repo move?"* — the broad question makes a routine checkpoint
and a stranger's commit indistinguishable, so it fires on every multi-session resume and
gets rubber-stamped. **Target files** already move under `go` item-by-item within one
session with no re-check (the code moving is what executing *is*), so letting them move
across a session boundary is exactly as safe. **`.scaffold/` files** belong to the other
staleness defense — `scaffold-plan`'s pivot sweep and `scaffold-checkpoint`'s coherence
sweep — never to this check. **A project file touched only by `checkpoint:` / `reconcile:` commits since the stamp** is exempt on the same reasoning: `checkpoint`'s repair licence commits session residue under those subjects, and a resume must not be refused for the tidy-up the last save performed. Identify them with `git log --format=%H%x09%s <sha>..HEAD`; a path is exempt only if every commit touching it in that range has a subject starting `checkpoint:` or `reconcile:` and it has no uncommitted change. Untracked files never trip the gate.

`## Targets` lists the files/interfaces the phase touches; `scaffold-plan` writes it
during a **finalize** pass (`as of HEAD`) and `scaffold-go`'s deterministic freshness
check reads it. A plan with no `## Targets` is a valid draft — existing plans are drafts,
no conformance break.

## Rules

- `## Scope` is load-bearing: `scaffold-go` executes exactly what it names. Keep it
  crisp.
- **Scope deliverables are NUMBERED.** Not a style preference: `scaffold-go` executes them
  one at a time and its end-of-phase scope check reports per item ("which scope items are not
  built?"), so an unnumbered prose scope makes both unanswerable and the check silently
  weaker. One numbered line per deliverable.
- **A phase is a vertical slice.** It cuts through every layer *the change itself touches* — no further — and ends in something observable: a number that comes out right, a command that produces the expected output, an API response, a generated file, a visible state. **It does not have to reach the UI.** A backend-only phase is a complete slice when its change can be exercised and checked end-to-end within its own scope. This is the `## Acceptance` rule seen from the other end. What it forbids is the *horizontal* cut — all the schema, then all the queries, then all the logic, then the wiring — where nothing works and nothing can be checked until the final phase lands.
- **A phase fits one agent session.** Size it so a single execution run finishes it without exhausting context. A phase that would need a mid-phase `/clear` is two phases.
- **A wide refactor is the exception, and sequences expand–contract.** Add the new form, migrate the call sites to it, then remove the old form — three phases, with the build green at every boundary. A wide refactor cut as one vertical slice breaks everything in between.
- **`[USER]` marks a human-owned deliverable.** A scope item the user must do (not the
  AI) carries a `[USER]` tag; `scaffold-go` does not execute it, and `scaffold-checkpoint`
  verifies each `[USER]` item with the user before ticking the phase.
- `NN` is the roadmap ordinal and admits interstitials (`09.1`); never renumber.
- **`## Targets` requires its `as of <sha>` stamp.** Bare section-presence is not a valid
  signal — the sha is the grounding evidence (audit checks it resolves to a real commit)
  *and* the staleness backstop (`go` runs the freshness test from it). A `## Targets`
  without a sha is malformed.
- **A finalized plan carries exactly one read-set form.** Either a `## Governed by` section with at least one entry, or the verbatim `Governed by: none` line in `## Approach`. Neither, both, or an empty heading is malformed — each passes a presence check while asserting something false about what `go` will read. A re-finalize that changes form deletes the other in the same edit.
- **Every `## Governed by` entry is a repo-relative path under `.scaffold/knowledge/` or `.scaffold/decisions/` that resolves on disk, followed by a few words naming the rule that binds.** A path that does not resolve is malformed (same grade as a `## Targets` sha that does not resolve).
- **A `decisions/` entry names an ADR whose `**Status:**` is `Accepted`.** Resolving on disk is not enough — a `Superseded` ADR is deliberately kept and `go` would read the dead ruling as binding. Superseded → repoint at the successor; Proposed → the ADR gate resolves first.
- **Point, don't copy.** A plan does not restate the content of a rule it points at; `## Approach` says how the rule applies to this phase and the pointer supplies the rule.
- **Every `## Targets` entry that names a file is a repo-relative path.** Not a style
  preference: the freshness check compares changed paths against this list, so a file
  named in prose is invisible to it and shows up as undeclared movement. A trailing `/`
  covers everything beneath. An entry that names an *interface or surface* rather than a
  file is allowed and simply ignored by the comparison — but if that surface lives in a
  file the phase will touch, the file gets its own path entry too.
- **Uncommitted edits count.** The freshness check reads the working tree, not just the
  committed span, so an uncommitted change to a file outside `## Targets` and `.scaffold/`
  makes the plan **stale** exactly as a commit would.
- **Staleness:** a pre-written downstream plan can go stale when a later decision/plan lands. `scaffold-plan` sweeps unexecuted plans (drafts included) on a pivot; `scaffold-checkpoint`'s coherence sweep also flags a *finalized* plan whose targets/approach conflict with a later decision.
- **Rewriting a finalized plan DEMOTES it to draft — delete `## Targets` in the same edit.** The freshness test exempts everything under `.scaffold/`, so a rewritten plan that keeps its old stamp reads as **final & fresh** to `scaffold-go`: it would execute a scope that was never validated against the code and never passed the finalize approval seam, against a target list that no longer describes the files it touches. Whoever rewrites the scope, approach or acceptance of a plan carrying `## Targets` removes that section and routes the plan back through `/scaffold-plan --final`. This binds `scaffold-plan`'s pivot sweep and `scaffold-cleanup`'s migration alike.
- **A finalized plan passes the stranger test.** Could a competent builder who has never
  seen this project execute it from the plan alone? Each place the answer is no is a rule
  the plan leans on without stating — name it in `## Approach` or point to where it is
  written. Applied at finalize (`scaffold-plan`), because a plan that only works for a
  builder who already knows the unwritten conventions is underspecified and nothing else
  reveals where.
- A plan is never authored on a not-yet-approved ADR (the ADR gate resolves first).
- **No two unexecuted plans in a milestone claim the same deliverable.** Unexecuted = the plan's `milestone.md` `## Phases` entry is unticked or absent. *Claims the same deliverable* is decided by subtraction, not word-matching: **if the sibling executed first, exactly as written, would this scope item still need doing in full?** Yes → no overlap. Two plans that genuinely touch the same work write the seam into `## Approach` — who owns what, and what the other assumes. **Graded across plans, not on one plan** — a per-document conformance grade marks it **n-a**; `scaffold-plan`'s neighbour check enforces it at finalize and `/scaffold-audit`'s reality pass grades it after the fact.

## Anti-patterns

- **A horizontal phase** — one layer built across the whole feature, leaving nothing checkable until a later phase wires it up. It cannot satisfy the observable-acceptance rule by construction.
- **A phase too large for one execution session** — it will be abandoned mid-flight or silently truncated.
- A plan premised on an unratified decision.
- A finalized plan whose `## Approach` only makes sense to someone who already knows the
  project's unwritten conventions (fails the stranger test).
- A finalized plan whose read-set is malformed — no `## Governed by` and no verbatim `Governed by: none` line, an empty heading, or both forms at once.
- A `## Governed by` entry that is not a resolving repo-relative path under `.scaffold/knowledge/` or `.scaffold/decisions/` (a `[[wikilink]]`, a title, prose, a sibling plan, a spec, a source file), or that names a `Superseded` or `Proposed` ADR.
- A plan carrying its own pasted copy of a `knowledge/` rule ("the rules this plan leans on") instead of pointing at it.
- Two unexecuted plans in one milestone claiming the same deliverable with no seam written (**graded across plans** — n-a for a per-document conformance pass).
- A `## Targets` section with no `as of <sha>` stamp (unauditable, no staleness backstop).
- A `## Targets` that names its files in prose instead of as repo-relative paths (the
  freshness check can't match them, so the phase's own edits read as undeclared drift).
- Renumbering interstitials on migration.
- An unnumbered / prose `## Scope` (nothing can report per deliverable against it).
- Silent scope expansion during `go` instead of routing out-of-scope to checkpoint.
