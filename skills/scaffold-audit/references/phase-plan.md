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

`## Targets` is what the phase **writes**; `## Governed by` is what it must have **read**.
It lists the `knowledge/` and `decisions/` documents whose rules bind this phase, each as a
repo-relative path, each with a short note naming *which* rule binds it.

**Why paths, not prose.** A plan is paper: it cannot read, only point. Scaffold already
learned this on `## Targets` — a file named only in prose is invisible to the freshness
check. A rule pointer is inert for the same reason: `scaffold-go` resolves and reads what
this section names before executing, so a rule mentioned in `## Approach` prose is a rule
nobody loaded.

**The consequence, stated so it is not lost: a plan that points reliably stops carrying its
own copy of the rules.** Phase plans inflate because reading a knowledge doc has been a
suggestion, so authors paste the rules in ("the rules this plan leans on") to be safe. Once
the pointer is honoured by `go`, the paste is redundant — restating a `knowledge/` rule in a
plan is a second home for that rule, and the second home is the one that goes stale. Point;
do not copy.

**Mandatory at finalize, optional in the contract.** A draft may omit it. The finalize pass
either writes the section or writes the **exact sentence** below into `## Approach` —
optional-and-nobody-authors-it is how the section dies quietly. Both readings are auditable:
a finalized plan has exactly one of them — the section or the sentence, never both.

The sentence is **fixed wording**, not a paraphrase, because a grader that has to judge prose
intent is the one non-computable test in a system built on computable state:

> Governed by: none — no `knowledge/` or `decisions/` document constrains this phase.

Its presence is a `grep`; a finalized plan carrying neither the section nor that line is
malformed.

**What belongs.** Only `.scaffold/knowledge/*.md` and `.scaffold/decisions/*.md` paths — the
two homes of durable rules. Not the milestone spec (that is scope, not rule), not another
phase plan (a plan is not a rule; a genuine dependency on a sibling is a seam, written into
`## Approach`), not source files (those are `## Targets`).

**A `decisions/` entry is an *Accepted* ADR.** A superseded ADR is kept on disk, so its path
resolves and passes every other test here while its ruling is dead — and `go` would read it as
binding law. Check the candidate's `**Status:**` line: `Superseded by [[NNNN-…]]` → point at the
successor instead; `Proposed` → the ADR gate resolves first (a plan is never authored on a
not-yet-approved ADR), never a pointer.

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
sweep — never to this check. **A project file a `checkpoint` commit touched since the stamp** is exempt on the same reasoning: `checkpoint`'s repair licence commits session residue under `checkpoint:` / `reconcile:` subjects, and a resume must not be refused for the tidy-up the last save performed. Identify them with `git log --format=%H%x09%s <sha>..HEAD` and exempt the paths of commits whose subject starts `checkpoint:` or `reconcile:`. Untracked files never trip the gate.

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
- **`## Governed by` is mandatory on a finalized plan.** Finalize writes the section, or
  writes into `## Approach` the fixed sentence given above — **verbatim** ("Governed by:
  none — …"), so the check is a grep and not a judgement about prose. A finalized plan with neither is malformed.
- **The two forms are exclusive — a plan carries the `## Governed by` section or the
  `Governed by: none` line, never both.** Both present is malformed, and the re-finalize path
  is how it arises: a plan that carried the sentence and now points at real documents must lose
  the sentence in the same edit. Otherwise the plan asserts on disk that nothing constrains the
  phase while its own read-set names two documents, and every reader passes it — `go` reads the
  section and never looks at the line, presence checks are satisfied twice over, and the next
  reader (stranger test, `scaffold-integrate` deciding whether a doc binds, a human) believes the
  false sentence. Both forms are a grep; so is the contradiction.
- **An empty `## Governed by` is malformed.** The heading with no entries under it satisfies
  every presence check while naming nothing to read — the section dying quietly behind a
  passing grade, which is the exact failure the mandatory rule exists to prevent. It also
  erases the distinction the fixed sentence carries: governed-by-nothing *asserted* versus
  never filled in. A phase governed by nothing carries the sentence in `## Approach` and no
  section at all; a section present carries at least one entry.
- **Every `## Governed by` entry is a repo-relative path under `.scaffold/knowledge/` or
  `.scaffold/decisions/`.** Not a style preference: `scaffold-go` resolves and reads these
  before executing, so a `[[wikilink]]` or a prose mention is inert. Each entry names which
  rule binds the phase, in a few words — enough that a reader can tell whether the pointer is
  still the right one.
- **A `## Governed by` path that does not resolve is malformed** (same grade as a `## Targets`
  sha that does not resolve): `go` cannot read what is not there, and a dangling pointer reads
  as governance that isn't happening.
- **A `## Governed by` entry under `.scaffold/decisions/` names an ADR whose `**Status:**` is
  `Accepted`.** Resolving on disk is not enough: a `Superseded` ADR is deliberately kept, so it
  passes the path and existence tests while `go` reads a dead ruling as binding — and a plan
  finalized before the supersession stays *final & fresh*, because the freshness test exempts
  everything under `.scaffold/`. A superseded entry is replaced by its successor; a `Proposed`
  one goes through the ADR gate before finalize completes.
- **Point, don't copy.** A plan does not restate the content of a rule it points at. A pasted
  copy of a `knowledge/` rule is a second home for that rule and the one that goes stale;
  where a plan needs the rule *applied* to this phase, `## Approach` says how it applies and
  the pointer supplies the rule itself.
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
- **No two unexecuted plans in a milestone claim the same deliverable.** Checked at finalize
  (`scaffold-plan`'s neighbour check) against every unexecuted sibling plan in the same
  milestone — unexecuted meaning its `milestone.md` `## Phases` entry is unticked **or not
  there at all** (a just-written plan the checklist hasn't caught up with is in reach, and
  its missing entry is a separate structural finding). *Claims
  the same deliverable* is decided by subtraction, not by matching words: **if the sibling
  executed first, exactly as written, would this scope item still need doing in full?** Yes
  → the plans do not overlap. This rule is the grade; `scaffold-plan` carries the full
  procedure and its admission bar. Where two plans genuinely touch the same work, that is allowed and the seam is
  written into `## Approach` — which plan owns what, and what the other assumes. What is not
  allowed is the same deliverable sitting unresolved in two scopes, because both plans are
  correct and the work simply gets built twice. **Graded across plans, not on one plan** — its
  subject is the *other* documents, so a per-document conformance grade marks it **n-a**; it is
  checked by `scaffold-plan`'s neighbour check at finalize and by `/scaffold-audit`'s reality
  pass.

## Anti-patterns

- **A horizontal phase** — one layer built across the whole feature, leaving nothing checkable until a later phase wires it up. It cannot satisfy the observable-acceptance rule by construction.
- **A phase too large for one execution session** — it will be abandoned mid-flight or silently truncated.
- A plan premised on an unratified decision.
- A finalized plan whose `## Approach` only makes sense to someone who already knows the
  project's unwritten conventions (fails the stranger test).
- A finalized plan with no `## Governed by` and no sentence in `## Approach` saying it is
  governed by nothing (the section dies quietly exactly here).
- An empty `## Governed by` — the heading with nothing under it (passes every check, reads
  nothing; write the fixed sentence instead).
- A plan carrying both a populated `## Governed by` and the `Governed by: none` line — it names
  what governs it and denies being governed in the same document (delete the line at re-finalize).
- A `## Governed by` entry written as a `[[wikilink]]`, a doc title, or prose (`go` can't
  resolve it, so nothing is read).
- A `## Governed by` path pointing outside `.scaffold/knowledge/` or `.scaffold/decisions/` —
  a sibling phase plan, a spec, a source file.
- A plan carrying its own pasted copy of a `knowledge/` rule ("the rules this plan leans on")
  instead of pointing at it.
- A `## Governed by` entry pointing at a `Superseded` or `Proposed` ADR (`go` reads a dead or
  unratified ruling as binding law).
- Two unexecuted plans in one milestone claiming the same deliverable with no seam written
  (**graded across plans** — n-a for a per-document conformance pass).
- A `## Targets` section with no `as of <sha>` stamp (unauditable, no staleness backstop).
- A `## Targets` that names its files in prose instead of as repo-relative paths (the
  freshness check can't match them, so the phase's own edits read as undeclared drift).
- Renumbering interstitials on migration.
- An unnumbered / prose `## Scope` (nothing can report per deliverable against it).
- Silent scope expansion during `go` instead of routing out-of-scope to checkpoint.
