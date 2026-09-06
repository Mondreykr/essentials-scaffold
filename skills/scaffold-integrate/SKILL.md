---
name: scaffold-integrate
argument-hint: "[path/to/doc-or-dir]"
description: Absorb an external artifact (a spec or design doc) into a scaffold project and route it to its one home — a milestone's spec/ (copy or pointer) or knowledge/ — then lift operational facts into the truth docs. Pure ingest; never authors plans or ADRs, and never touches code. Use whenever the user wants to integrate, absorb, ingest, bring in, or pull in an external doc/spec — even if they only say "integrate this", "absorb that spec", or "add this doc to the scaffold". To migrate an old scaffold layout, use /scaffold-cleanup instead.
---

# scaffold-integrate

Pure ingest: absorb an external artifact, route it to its one home, lift operational facts into the truth docs. Place; don't dissect. The original is never modified or deleted unless the user says so.

**Boundary.** Never: author plans or a `milestone.md` (`plan`); sweep or write back build results (`checkpoint`); migrate an old layout (`cleanup`); create, supersede or prune a decision (surface the ruling for `plan`/`checkpoint`, Adam-gated); write `investigations/` (`go`'s band); place anything under `milestones/archived/` (closed work takes no new content — route to `knowledge/` or the active milestone); edit a plan; change code.

**Precondition.** `project.md`, `architecture.md`, `roadmap.md`, `state.md` exist under `.scaffold/`. If not, stop: "Scaffold files missing or incomplete — run /scaffold-setup first."

**Version guard.** Any doc with `schema_version: 1`, `type: milestone-plan` / `type: phase-brief`, or a milestone folder holding `plan.md` → stop: "Old scaffold format (pre-rename) — run /scaffold-cleanup to migrate first; the current skills will misread it."

**Frontmatter.** Any doc you create or touch carries `type` / `schema_version: 2` / `updated:` (today).

---

## Step 1: Locate the artifact

Named in the invocation — a file or a directory. None named → ask; do not scan or guess. Path doesn't exist → stop and report; try no alternatives.

## Step 2: Read for routing

Read the artifact (a directory's entry doc plus its structure — note any `references/`, `DECISIONS.md`, `STATE.md` it carries), `roadmap.md` (which milestone, or a new one?), and `architecture.md` (which operational facts the truth docs lack). Read no more than placement needs.

## Step 3: Classify — spec or knowledge

Exactly one primary home; state it and the destination before writing:

- **Scopes a milestone** (a spec, contract or design doc for a chunk of work, active or about to start) → that milestone's `spec/` (4a). Never a closed one: a spec arriving for archived work routes by what it is — enduring rules → `knowledge/`; anything else → say it describes closed work and place nothing.
- **Cross-cutting durable knowledge** (a rulebook that outlives any one milestone) → `knowledge/` (4b).

Tiebreak: authority bounded by a milestone's lifecycle → spec; durable truth that stays current as code changes → knowledge. Graduating a spec's enduring rules later is `checkpoint`'s close job. The two bins are exhaustive: a research doc routes by the same test, and raw analysis that is neither is **not absorbed** — it stays in its own home; any durable rule it yields graduates to `knowledge/`, any decision becomes a proposed ADR.

## Step 4a: A milestone spec → `spec/`

Identify the milestone from `roadmap.md` (confirm if ambiguous or the folder doesn't exist). Then copy or pointer — ask if not obvious:

- **Copy in** — no other home. Place at `.scaffold/milestones/NN-slug/spec/` (file or directory contents). Copy, don't move. An embedded spec keeps its own convention; no frontmatter imposed.
- **Pointer** — the spec stays where it lives (shared, owned by another tool, grandfathered in `docs/`). Write `.scaffold/milestones/NN-slug/spec/POINTER.md`:

  ```markdown
  ---
  type: spec-pointer
  schema_version: 2
  updated: [today]
  ---

  # Spec pointer

  The spec for this milestone lives at: `[relative/path/to/spec]`

  It is maintained in place and is the **live rulebook** for this milestone until it closes; its `references/` (if any) are the active rules. Do not copy its content into `.scaffold/`. At milestone close, its enduring rules graduate to `knowledge/` (a `/scaffold-checkpoint` job).

  Why it lives outside scaffold: [shared / external tool owns it / grandfathered].
  ```

**A pointer'd spec's internals are never cracked open.** Its `DECISIONS.md` / `STATE.md` / `references/` stay whole — nothing is split into `decisions/`, `state.md` or `knowledge/`.

## Step 4b: Durable knowledge → `knowledge/`

Place at `.scaffold/knowledge/<slug>.md`, slug from subject (`ledger-replay.md`), `type: knowledge`. A doc on the same topic already exists → show the overlap and ask: merge / save as distinct / replace — never silently overwrite or append. A sprawling rulebook is placed as-is; conforming it to *invariant + why + pointer* is `checkpoint`'s.

**A new rule can bind an already-finalized plan.** After placing, read every unexecuted plan carrying `## Targets` in every live milestone (never `archived/`; a draft gets its read-set at finalize). For each: **if that phase were built in violation of this document's rule, would the phase be wrong?** Yes, and its `## Governed by` does not name this path (a `Governed by: none` line counts) → report it in Step 6: "run `/scaffold-plan --final` on it — its read-set predates `knowledge/<slug>.md`." Absence of the path alone is never the trigger.

## Step 5: Lift operational facts into the truth docs

Only these, and only what the artifact states plainly:

- **Durable run/env facts and conditions** (how to run, env vars, deployment shape, "runs against a dev DB until cutover") → `architecture.md` `## Run / env`. A one-off resume precondition is flagged for `plan`/`checkpoint` to fold into `## Next`, not written.
- **An explicit scope boundary** → `project.md` `## Scope` or `## Not building`, as plain truth, never a checkbox. A verifiable invariant goes where it is tested (done-contract, a plan's acceptance, `knowledge/`), not a truth doc.
- **An implied milestone or backlog item** → flag for `/scaffold-plan`; propose, don't author.

Present the set and **STOP for confirmation** if there is anything beyond the primary placement:
> "Extracting into truth docs:
> - architecture.md: [run/env facts + any durable run/env condition]
> - project.md: [scope boundary made explicit]
> Flagging for /scaffold-plan (not authored here): [implied milestone/backlog; any resume precondition for state.md ## Next]."

## Step 6: Report + commit

> "## Integration summary
> **Artifact:** [path]
> **Routed to:** [`milestones/NN-slug/spec/` (copy | pointer)] or [`knowledge/<slug>.md`]
> **Truth docs touched:** [architecture.md / project.md — or none]
> **Handed off (not done here):** [ADR → plan/checkpoint; milestone → plan; plans whose `## Governed by` predates a placed knowledge doc → `/scaffold-plan --final` — or none]"

Show `git diff .scaffold/`. **STOP for confirmation before committing.** Then `git add .scaffold/ && git commit -m "integrate: [artifact]"`. If a milestone or backlog item was implied: "Run /scaffold-plan to author it."
