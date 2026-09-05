---
name: scaffold-audit
description: Deep, independent, read-only review of a scaffold project — grade every LIVE .scaffold/ doc hard against its format and verify the docs against the actual code. Closed milestones under milestones/archived/ are never graded. Spins up fresh agents; always does both passes (conformance gates reality); changes nothing. Use whenever the user wants a thorough audit, a deep check, a conformance or reality review, or to validate the scaffold before a release, after a long gap, or after heavy hand-editing — even if they only say "audit", "check the scaffold", or "is everything consistent". The light always-on version is built into /scaffold-checkpoint.
---

# scaffold-audit

The deep, independent review. Where `checkpoint`'s inline sweep *samples*, audit grades
the whole tree hard and checks it against reality. It is **read-only** — it reports drift
and never edits. Depth is already chosen by invoking audit at all, so it **always does both
passes, no asking**: conformance, then reality.

`.scaffold/milestones/archived/` is out of scope, entirely and always. A closed
milestone is a frozen record of what was built, not a claim about the code — grading it
can only produce findings nobody may act on, since nothing edits the archive. Do not
inventory it, do not grade it, do not read it looking for drift.

**Boundary.** Read-only. Audit grades and reports; it writes nothing. Every fix routes back through the skill that owns the doc (`plan`/`checkpoint`/`integrate`/`cleanup`) — audit never edits, proposes ADRs, or touches code. It also never **reads or grades anything under `milestones/archived/`**, and never skips a pass: both always run, conformance first, gating reality.

**Run it independently.** To grade without the bias of the working session's context,
dispatch **fresh read-only subagents** (Explore / general-purpose) rather than judging
from memory: one (or more) for the conformance pass over the doc tree, and — only after
conformance clears — one or more for the reality pass against the code. Synthesize their
findings here. Each agent is told it is grading, not fixing, and grades against the
**bundled contracts** (Step 2), not from recollection.

**Precondition.** `.scaffold/` exists with truth docs. If not: "No scaffold here — run
/scaffold-setup (fresh) or /scaffold-cleanup (migrate an old layout)."

---

## Step 1: Inventory

List every doc in scope: the four `.scaffold/` truth docs, `glossary.md` if present, all of
`knowledge/`, `decisions/`, `investigations/`, and every **live** `milestones/NN-slug/`
(`milestone.md`, `spec/`, `phases/*`). **Skip `milestones/archived/` and everything under
it** — closed milestones are records, not graded docs. The one thing worth checking about
the archive costs no reading: every `roadmap.md` `[done]` line should point into
`milestones/archived/`, and no `[active]`/`[planned]` line should. Read each doc's frontmatter `type:` — that is
authoritative and selects which conformance rules apply (filename/location is only a
fallback). Ignore `.gitkeep` placeholders.

**Three gates before grading.** (1) If the tree *wholesale* lacks `type`/`schema_version`
frontmatter (a pre-current-format / un-migrated layout), stop and report: "This scaffold
predates the current format — run /scaffold-cleanup to migrate, then re-audit," rather
than flooding per-doc 'missing frontmatter' findings. (2) A *missing* mandatory truth doc
(`project` / `architecture` / `roadmap` / `state`) is itself a conformance finding — the
four are always present in a current scaffold. A missing or term-less `glossary.md` is **not** a finding — it is optional by construction, like an empty `knowledge/`. (3) **Unknown / pre-rename doc** — a doc
whose frontmatter `type` matches **no** bundled contract (e.g. `milestone-plan` /
`phase-brief`, the pre-rename names), **or** any doc still carrying `schema_version: 1`
(a partial-migration marker, even when its `type` is current), is an **un-migrated** doc,
not a malformed one. Do **not** force-grade it against a same-shaped contract or guess its
type from filename; report it as "unmigrated — run /scaffold-cleanup" and move on. (Current
type names are `milestone` and `phase-plan`.)

## Step 2: Conformance pass (runs FIRST — gates the rest)

Grade each doc **against its contract.** This skill bundles a verbatim copy of every
format contract in `references/` — one file per `type` (`references/roadmap.md`,
`references/state.md`, `references/project.md`, …). The contract is the oracle: grade
against the file, never from memory or a remembered paraphrase. (The copies are kept
identical to the factory masters by `scripts/sync-contracts.sh`; they are the authority
here.)

**Grade one rule at a time — never a holistic verdict.** A whole-doc "this looks fine"
judgment is exactly how a real violation slips through: the grader skims, the doc reads
clean, and a present-but-ignored rule is never checked. To prevent that, for each doc:

1. **Select the contract** from the doc's frontmatter `type:` (authoritative;
   filename/location is only a fallback).
2. **Walk the contract line by line** — every item in its **Required structure**, every
   bullet in **Rules**, and every entry in **Anti-patterns**. For *each* one, emit an
   explicit verdict — **pass / fail / n-a** — with the evidence (the doc line or section
   that satisfies or violates it). Every anti-pattern is checked **by name**; you may not
   drop one because the doc "seems clean." This per-rule table is the deliverable.
3. **Also check** frontmatter (`type` / `schema_version` / `updated`)
   and brevity (no bloat that signals a Law-1 append-log). For `knowledge/` specifically,
   flag **form-drift**: an entry that restates code (a value/constant with a single code
   home) or has grown past a concise *invariant + why + pointer*.

Dispatch the fresh grading subagent(s) with the absolute path to this skill's
`references/` directory and the instructions above, so they grade against the bundled
contracts rather than recalling rules. A doc's overall grade — **conforms / minor /
malformed** — is *derived* from its table: **conforms only if every rule passed.** A
contract whose `type` doesn't apply to a given file (e.g. an embedded full spec, which
keeps its own authoring convention) is marked n-a, not force-graded.

## Step 3: Reality pass (gated by conformance)

Verify the scaffold's claims against the actual code:

- **Ticked phases really built** — for each `[x]` phase in an active/closed `milestone.md`,
  the deliverables exist in the code.
- **Architecture matches the real stack** — `architecture.md`'s Stack / Data access /
  Deployment reflect the manifests and code, not an aspiration.
- **ADRs match reality** — an `Accepted` ADR's ruling is actually what the code does (a
  contradiction means the ADR is stale or silently violated).
- **Knowledge invariants hold in the code** — for each `knowledge/` entry, the code
  site(s) it points to exist and still implement the invariant. Flag a pointer that no
  longer resolves, or a rule the code now violates (route to `checkpoint`). This is the
  payoff of the pointer form and the backstop for a thin milestone-close graduation.
- **Finalized-plan `## Targets` are grounded** — for each plan carrying a `## Targets`
  section, the named files/interfaces exist in the code and the `as of <sha>` stamp
  resolves to a real commit (`git cat-file -e <sha>`). A `## Targets` with no sha, an
  unresolvable sha, or a named file that doesn't exist is a finding — it means the
  readiness signal is ungrounded (route to `plan` to re-finalize). This closes the
  "unfalsifiable by construction" hole: the signal is only trustworthy because it's
  auditable.
- **Finalized-plan `## Targets` are machine-comparable** — every entry that names a file
  is a repo-relative path (a trailing `/` covers what's beneath), not a file named in
  prose. `go`'s freshness check matches changed paths against this list, so a prose-named
  file is invisible to it and the phase's own edits read as undeclared drift. An entry
  that names an *interface or surface* rather than a file is fine and simply ignored by
  that comparison. Also flag a stamp that is **not an ancestor of HEAD**
  (`git merge-base --is-ancestor <sha> HEAD`) — the plan was validated against a history
  that no longer exists, so it is stale regardless of what its targets say.
- **Standing blockers are real** — each `state.md` Blocker is corroborated by the code /
  state, not stale or already resolved.
- **Deferred / backlog items aren't already done** — this is the deliberate, expensive
  check the lighter skills can't do: for each `milestone.md` `## Deferred` and `roadmap.md`
  `## Backlog` item, verify against the actual code whether it's already built or no longer
  applies. Flag every item that looks shipped or stale for removal (route to
  `checkpoint`/`plan`) — audit reports, never deletes. This is the housekeeping pass that
  keeps the lists from silently accreting done work.
- **Deferred items actually cleared the admission bar** — the same pass, one question
  further, and only audit can answer it because it needs the code: for each item, does it
  still **need a decision**, sit **materially out of scope**, or constitute **real work that
  can't ride along safely**? An item whose fix you can see is a rename, a one-line guard, a
  stale comment, or a duplicate of something `state.md` `## Next` or a phase plan already
  carries **failed admission** — flag it as *fix-in-place* (or *drop*), not as work to
  schedule. Report the count: a list long on fix-in-place items is an admission failure, and
  the finding is against the skill that parked them, not just the list.
- **In-flight / uncommitted work** — flag uncommitted changes or recent edits the docs
  don't yet reflect (a checkpoint may be overdue).

**The gate (hard):** if a doc is malformed enough that its state can't be read reliably
(e.g. `## Next` doesn't resolve, a `milestone.md` checklist is unparseable), report the reality
of that area as **unreliable — fix conformance first**, rather than guessing. Don't infer
through a broken doc.

## Step 4: Report

Return findings **prioritized** (malformed/blocking first, then reality contradictions,
then minor conformance). Conformance findings come straight from the Step 2 per-rule
tables — surface **every failed rule** (doc → the exact contract rule → evidence); do not
collapse them into a single per-doc grade. Each finding names the doc, the specific rule,
and **which skill owns the fix**:

- format / section / frontmatter drift → `scaffold-checkpoint` (sweep) or
  `scaffold-cleanup` (structural)
- a truth/identity/plan change → `scaffold-plan`
- an absorbed-artifact issue → `scaffold-integrate`
- an ADR that should change → propose via `scaffold-plan`/`scaffold-checkpoint`
  (Adam-gated)

End by stating audit changed nothing, and what to run next.

**Say where the findings live until they're acted on.** Audit is read-only by design — that independence is the point of the tier — but read-only must not mean *lost*. These findings exist only in this transcript. Each already names its owning skill above; `scaffold-checkpoint` disposes of the rest (it fixes, gets a ruling and applies it, or routes each to a section on disk). Close by saying so plainly and **naming the owners you actually assigned**, e.g.: *"Audit wrote nothing. Two findings are `/scaffold-cleanup`'s, one is `/scaffold-plan`'s, the rest `/scaffold-checkpoint` can dispose of. They live only in this conversation — nothing on disk records that this audit ran, so anything you don't act on now goes with the session."*

**Run the owning skill first when one is named.** A structural-migration finding sent to `/scaffold-checkpoint` hits its version guard and bounces straight back to `/scaffold-cleanup` — and under its repair licence it might instead attempt a cleanup-class fix it isn't scoped for.
