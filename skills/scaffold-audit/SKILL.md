---
name: scaffold-audit
description: Deep, independent, read-only review of a scaffold project — grade every LIVE .scaffold/ doc hard against its format and verify the docs against the actual code. Closed milestones under milestones/archived/ are never graded. Spins up fresh agents; always does both passes (conformance gates reality); changes nothing. Use whenever the user wants a thorough audit, a deep check, a conformance or reality review, or to validate the scaffold before a release, after a long gap, or after heavy hand-editing — even if they only say "audit", "check the scaffold", or "is everything consistent". The light always-on version is built into /scaffold-checkpoint.
---

# scaffold-audit

The deep, independent review: grade the whole live tree against its contracts, then check it against the code. **Read-only** — report drift, edit nothing. **Both passes always run, no asking**, conformance first, gating reality.

**Boundary.** Write nothing; every fix routes to the owning skill. Never propose an ADR or touch code. Never read or grade anything under `milestones/archived/` — a frozen record, and nothing may act on a finding there.

**Run it independently.** Dispatch **fresh read-only subagents** (Explore / general-purpose): one or more for the conformance pass, and, only after it clears, one or more for the reality pass. Each is told it is grading, not fixing, and grades against the bundled contracts in this skill's `references/` (pass the absolute path), never from recollection. Synthesize here.

**Precondition.** `.scaffold/` exists with truth docs. If not: "No scaffold here — run /scaffold-setup (fresh) or /scaffold-cleanup (migrate an old layout)."

---

## Step 1: Inventory

In scope: the four truth docs, `glossary.md` if present, all of `knowledge/`, `decisions/`, `investigations/`, every live `milestones/NN-slug/` (`milestone.md`, `spec/`, `phases/*`). Skip `milestones/archived/`; the one archive check needs no reading: every `roadmap.md` `[done]` line points into `archived/`, and no `[active]` / `[planned]` line does. A doc's frontmatter `type:` selects its contract; filename is a fallback. Ignore `.gitkeep`.

Three gates:
1. The tree **wholesale** lacks `type` / `schema_version` frontmatter → stop: "This scaffold predates the current format — run /scaffold-cleanup to migrate, then re-audit."
2. A missing mandatory truth doc is a conformance finding. A missing or term-less `glossary.md` is not.
3. A doc whose `type` matches no bundled contract (`milestone-plan`, `phase-brief`), or any doc with `schema_version: 1` → **unmigrated**, not malformed: report "unmigrated — run /scaffold-cleanup", never force-grade or guess its type.

## Step 2: Conformance pass — first, gates the rest

`references/` holds a verbatim copy of every contract, one per `type`. The contract file is the oracle.

**One rule at a time, never a holistic verdict.** For each doc:

1. Select the contract by `type:`.
2. Walk the contract line by line — every **Required structure** item, every **Rules** bullet, every **Anti-patterns** entry — and emit **pass / fail / n-a** with evidence (the doc line or section). Every anti-pattern is checked by name. This per-rule table is the deliverable. A rule whose evidence is another doc or the disk (the cross-plan deliverable rule, a `## Governed by` path resolving, an ADR's status) takes **n-a (graded in Step 3)**, never a guessed fail; a pure text test (entry shape, the folder a path names, the fixed `Governed by: none` line, an empty heading, both forms at once) is graded here.
3. Also check frontmatter (`type` / `schema_version` / `updated`) and brevity (bloat that signals a Law-1 append-log). For `knowledge/`, flag **form-drift**: an entry restating code (a value with a single code home) or grown past *invariant + why + pointer*.

The doc's grade — **conforms / minor / malformed** — is derived: conforms only if every rule passed or was n-a, and a deferred rule counts as n-a only once Step 3 has graded it. A file no contract applies to (an embedded full spec) is n-a, not force-graded.

## Step 3: Reality pass — gated by conformance

Verify claims against the code:

- **Ticked phases really built** — each `[x]` phase's deliverables exist.
- **Architecture matches the real stack** — Stack / Data access / Deployment reflect manifests and code.
- **ADRs match reality** — an `Accepted` ruling is what the code does.
- **Knowledge invariants hold** — each entry's code pointer resolves and still implements the invariant (route to `checkpoint`).
- **`## Targets` grounded** — for each finalized plan: named files exist; the `as of <sha>` resolves (`git cat-file -e <sha>`) and is an ancestor of HEAD (`git merge-base --is-ancestor <sha> HEAD`); every file entry is a repo-relative path (a trailing `/` covers beneath), not a file named in prose (interface entries are fine). Any failure → route to `plan`.
- **`## Governed by` resolves** — the disk half (the text half was Step 2): every path exists; every `decisions/` entry is `**Status:** Accepted` (open it — a `Superseded` ADR resolves on disk while its ruling is dead); no **pasted rule** — a heading or lead-in enumerating rules, or a passage restating a rule of any `knowledge/` or `decisions/` doc inventoried at Step 1 without tying it to this phase's own items, files or steps (prose saying how a rule applies is required, never a finding). Route to `plan`.
- **Plan-set coherence** — per live milestone, compare `## Objective`, `## Scope`, `## Approach` of its **unexecuted** plans (unticked or missing entry — a missing entry is its own finding). Grade exactly what `plan`'s neighbour check grades: a hit is a scope item for which, **if the other plan executed first exactly as written, the item would not still need doing in full**, *and* you can name the one artifact both would leave in the same end state; or a forward pointer naming an unexecuted sibling without saying who owns the work. A pointer naming an owner, or a seam in either `## Approach`, is never a finding. Route to `plan`.
- **Standing blockers are real** — each Blocker corroborated, not already resolved.
- **Deferred / backlog items aren't already done** — for each `## Deferred` and `## Backlog` item, check the code: shipped or no longer applies → flag for removal (route to `checkpoint`/`plan`).
- **Deferred items cleared the admission bar** — does each still need a decision, sit materially out of scope, or constitute real work that can't ride along safely? A fix you can see is a rename, a one-line guard, a stale comment, or a duplicate of `## Next` or a plan → **fix-in-place** (or drop), not work to schedule. Report the count; a list long on these is an admission failure against the skill that parked them.
- **In-flight work** — uncommitted changes or recent edits the docs don't reflect (a checkpoint may be overdue).

**The gate (hard):** a doc too malformed to read reliably (`## Next` doesn't resolve, an unparseable checklist) → report that area as **unreliable — fix conformance first**, never infer through it. A Step 2 rule deferred here that the gate blocks → **ungraded — blocked by conformance**, naming the doc; not a pass.

## Step 4: Report

Prioritized: malformed/blocking, then reality contradictions, then minor conformance. Surface **every failed rule** from the Step 2 tables (doc → exact contract rule → evidence); never collapse to a per-doc grade. Each finding names the owning skill:

- format / section / frontmatter drift → `checkpoint` (sweep) or `cleanup` (structural)
- a truth / identity / plan change → `plan`
- an absorbed-artifact issue → `integrate`
- an ADR that should change → propose via `plan`/`checkpoint` (Adam-gated)

Close by stating audit changed nothing, naming the owners you assigned, and saying the findings live only in this transcript until a `checkpoint` disposes of them, e.g.: *"Audit wrote nothing. Two findings are `/scaffold-cleanup`'s, one is `/scaffold-plan`'s, the rest `/scaffold-checkpoint` can dispose of. They live only in this conversation — nothing on disk records that this audit ran, so anything you don't act on now goes with the session."* **Run a named owning skill before `checkpoint`** — a cleanup-class finding sent to `checkpoint` hits its version guard or tempts a repair it isn't scoped for.
