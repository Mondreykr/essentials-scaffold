# Phase plans → the milestone

Applies when a `plans/` folder exists. Move every `plans/phase-*.md` to `milestones/NN-slug/phases/`:

- Strip the `phase-` prefix; keep number + slug. **Never renumber** — `phase-09.1-currency-model.md` → `phases/09.1-currency-model.md`.
- `phase-00` does not move — it folded into `milestone.md` (see `roadmap-split.md`).
- Stamp `type: phase-plan`; rename an old `## Goal` to `## Objective`. Current shape: `# Phase NN — <slug>` / Objective / Scope / Approach / Acceptance. Write neither `## Governed by` nor `## Targets` — a migrated plan is a draft.
- `git mv`; repoint every reference in the rename map.

A downstream plan staled by a later change (a Phase 10 plan written before a 09.1 insertion) is flagged, not fixed:
> "`phases/10-*.md` predates the 09.1 insertion and may be stale. Kept as-is; run /scaffold-plan to re-sweep downstream plans."
