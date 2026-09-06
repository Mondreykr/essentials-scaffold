---
name: scaffold-cleanup
description: Bring a scaffold in ANY prior or partial state up to the current standard. Reads whatever is actually on disk without assuming a shape, works with you to map it onto the current structure, and proves the result conforms. Handles the known pre-restructure layout (single decisions.md, plans/ folder, per-phase roadmap, no architecture.md, no milestones/, missing frontmatter) and also partial, hand-edited, or unfamiliar states — it migrates the gap, not a presumed whole, so it is safe to re-run. Cautious and interactive; confirms every judgment call and stops on anything ambiguous. Use whenever the user has an old, partial, or messy scaffold and wants to migrate, upgrade, clean up, or convert it — even if they only say "migrate the scaffold", "clean this up", or "upgrade the layout". For a fresh project with no scaffold yet, use /scaffold-setup instead.
---

# scaffold-cleanup

Migrate an existing `.scaffold/` — any old, partial or hand-edited layout — to the current structure. Fix the target (below), read what is actually on disk without assuming a shape, map the gap onto the target with the user, then prove the result reached it.

**Cautious and interactive.** Mechanical renames: just do. Judgment calls: stop and confirm. Ambiguous, contradictory or half-migrated: surface it and stop — never guess, never run a step against an assumption the inventory did not confirm.

**Migrate the gap, not a presumed whole.** Anything already conformant is left untouched — a stamped doc is not rewritten, a plan at its target path is not moved again. Safe to re-run.

**Boundary.** Touch `.scaffold/` only. Never: project code; `CLAUDE.md`; a grandfathered spec's internals (point at it or update paths, nothing more); an ADR without approval; renumbering a phase or interstitial (`09.1` stays `09.1`); fixing a stale downstream plan (flag it — `plan` re-sweeps); grading docs rule-by-rule against the contracts (`audit`'s job — your Step 7 check is structural only); populating `knowledge/`, except the retroactive graduation pass when archiving a milestone whose close never ran, Adam-approved.

**Run at a clean phase boundary**, before any other scaffold skill runs on the repo — they expect the current layout.

---

## The target

The end-state `/scaffold-setup` produces and the contracts define. When a placement is in doubt, the two Laws decide: truth ≠ history; a doc lives at the layer that owns its lifecycle. Done means every one of these holds:

- `project.md`, `architecture.md`, `roadmap.md`, `state.md` exist and are conformant. `roadmap.md` holds `## Milestones` + `## Backlog` at program altitude only, every backlog line pointing at an existing `backlog/<slug>.md`. `state.md` holds exactly Active focus / Next / Blockers / Open Questions, `None.` where empty, no `## Notes`.
- `knowledge/` exists. `glossary.md` exists — created empty if the scaffold predates it, **never seeded** from the old docs or the code.
- `decisions/NNNN-slug.md` (4-digit) and `investigations/YYYYMMDD-slug.md` (no dashes in the date) are folders with conformant names.
- Each chunk of work is `milestones/NN-slug/` holding `milestone.md` (Objectives / Phases as checkbox + date / Done-contract / optional Deferred), `phases/NN-slug.md` (interstitials like `09.1` preserved), optional `spec/`.
- Every milestone the roadmap marks `[done]` sits under `milestones/archived/NN-slug/`, its `milestone.md` stamped `archived: YYYY-MM-DD`, the roadmap path pointing there. No `[active]` / `[planned]` milestone is under `archived/`.
- No legacy shape remains: no single `decisions.md`, no `plans/`, no per-phase build plan in `roadmap.md`, no `## Notes` in `state.md`, no catch-all section, no `project.md` checkbox.
- No pre-rename name remains: no milestone `plan.md`, no `type: milestone-plan`, no `type: phase-brief`.
- Every doc carries `type` / `schema_version: 2` / `updated` frontmatter. A `schema_version: 1` is the un-migrated marker.
- No pointer dangles within the live `.scaffold/` docs. `milestones/archived/` is frozen: a dangling pointer there is reported, never fixed. Pointers held by files outside `.scaffold/` are out of scope.

## Step 1: Inventory

Read everything under `.scaffold/` — do not presume what is present or its shape. Record each doc's presence, frontmatter and `schema_version`.

Two hard stops:
- No `.scaffold/` → "No scaffold files found — run /scaffold-setup first."
- Every target invariant already holds → "Already on the current structure; nothing to migrate."

Otherwise report the real state, one line per finding, each with its target:
> - `roadmap.md` — per-phase build plan (target: program-altitude index + Backlog)
> - `roadmap.md` — N bare `## Backlog` lines (target: one `backlog/<slug>.md` per line — `references/backlog-files.md`)
> - `plans/` — N phase plans, incl. interstitials 06.1, 09.1
> - `decisions.md` — single file, N entries (target: curated `decisions/`)
> - `architecture.md` — absent
> - `investigations/2026-06-11-*.md` — nonconformant name
> - [anything unexpected, partial or contradictory]

## Step 2: Triage every gap

- **Mechanical** — rename, move, stamp frontmatter on content already right, strip a `phase-` prefix. Apply in Step 6.
- **Judgment** — milestone slug(s); which legacy decisions become ADRs; architecture-vs-knowledge tiebreaks; which doc is the milestone plan; how many milestones the old work becomes. Gate in Step 3.
- **Ambiguous / partial / contradictory → STOP and surface.** `milestones/` and `plans/` both present; a `decisions/` folder and a `decisions.md`; both `plan.md` and `milestone.md`; mixed `schema_version`; a `## Next` that does not resolve; two docs that contradict; a shape matching no known pattern; a `schema_version` newer than 2 (cleanup migrates up, never down). Report exactly what is inconsistent and ask.

## Step 3: Propose, gate the judgment calls

Lay out the whole plan, then confirm gate by gate — only those the inventory surfaced. Write nothing until Step 6.

1. **Milestone slug(s).** Default one `01-<slug>` from the work's identity; one container per distinct chunk if the old layout tracked several, order preserved. The slug is a sticky namespace.
2. **Which doc is the milestone plan** — normally the old `roadmap.md` build-plan body.
3. **Which legacy decisions become ADRs** — most retire to git.
4. **The spec, if any** lives elsewhere — it stays there; you write a `spec/` pointer, not a copy.

## Step 4: Reference sweep — before any move

Grep `.scaffold/` for every pointer that breaks on move or rename: `state.md` `## Next` → milestone and phase paths; `roadmap.md` → `plans/phase-*`; phase plans → siblings, `decisions.md`, investigations; knowledge docs → decisions by old path. Build a rename map (old → new) for every moving file and report it. A pointer that already dangles is flagged, not given an invented target.

## Step 5: Apply the playbooks the inventory turned up

Each legacy pattern has a playbook in `references/`. Read only those your inventory matched; each assumes triage confirmed the pattern.

| Inventory found | Playbook |
|---|---|
| `roadmap.md` holds a per-phase build plan | `references/roadmap-split.md` |
| a `plans/` folder | `references/plans-move.md` |
| `plan.md`, `type: milestone-plan` / `phase-brief`, or `schema_version: 1` | `references/v1-rename.md` |
| `architecture.md` absent or thin | `references/architecture-standup.md` |
| a monolithic `decisions.md` | `references/decisions-curation.md` |
| a `[done]` milestone outside `archived/` | `references/archive-closed.md` |
| a `## Backlog` line without a `→ backlog/` pointer | `references/backlog-files.md` |

Two more are small enough to state here:

**Nonconformant names.** Investigations → `YYYYMMDD-slug`; decisions → `NNNN-slug` continuing the sequence; phases → `NN-slug`, interstitials preserved. `git mv`; list each rename.

**`state.md`.** Repoint `## Next` per the rename map; ensure exactly the four sections in order, `None.` where empty. Drain a legacy `## Notes` to each item's home: run/env fact → `architecture.md`; deferred work → the milestone's `## Deferred`, through the admission bar and Adam gate (needs a decision / materially out of scope / can't ride along safely — propose, don't append); resume precondition → `## Next`; blocker → `## Blockers`. Surface each re-home.

Stamp `type` on every doc you touch (`project`, `state`, `knowledge`, `investigation`, …).

## Step 6: Present the full change set, then execute in one pass

Present everything at once — moves, new files, renames, rewrites, deletions, pointers repointed, what was left untouched, staleness flags:

```
## Migration plan
**milestones/NN-slug/** (created): milestone.md ← roadmap build plan; phases/ ← N plans; spec/ ← pointer to [path]
**roadmap.md** → program altitude; **architecture.md** → NEW
**decisions/** → N ADRs promoted (approved); M retired to git
**investigations/** → K names normalized
**state.md / project.md / knowledge/** → stamped; Next repointed; Notes drained
**Reference sweep:** N repointed, 0 dangling
**Untouched (already conformant):** …   **Staleness flags:** …
```

**STOP. Wait for explicit approval.** Incorporate changes and re-present. Then, in one pass:

1. Create `milestones/NN-slug/{milestone.md, phases/}` and any `spec/` pointer (`type: spec-pointer`).
2. `git mv` plans, renamed investigations, archived milestones.
3. Write `architecture.md` and each approved ADR.
4. Rewrite `roadmap.md`; update `state.md`, `project.md`; stamp all frontmatter.
5. Repoint every reference in the rename map.
6. Create `glossary.md` if absent: `type: glossary` frontmatter, `# Glossary`, the placeholder line, no entries.
7. Delete the migrated `decisions.md` and the now-empty `plans/`.

## Step 7: Verify against the target, then commit

Run the light structural + coherence check `/scaffold-checkpoint` runs, over every migrated doc: required sections present and in order, frontmatter correct, no catch-all or append-log, no `project.md` checkbox; every cross-reference resolves within live `.scaffold/`; `## Next` resolves and not inside `archived/`; no Law-1 / Law-2 violation; no duplication. Not per-rule contract grading. A failing check is fixed before commit; one needing a judgment call is surfaced.

Commit: `git add -A .scaffold/ && git commit -m "scaffold: migrate to milestone structure"`. Summarize what moved, promoted vs retired, renamed, left untouched, and staleness flags. Recommend `/scaffold-audit` for the deep pass.
