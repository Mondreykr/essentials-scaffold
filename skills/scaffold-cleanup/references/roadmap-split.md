# Roadmap split by altitude

Applies when `roadmap.md` mixes a program index with a per-phase build plan.

**Build-plan body → `milestones/NN-slug/milestone.md`.** Carry over the objective and done-contract; preserve the checkbox + completion-date checklist exactly (do not reformat dates into prose); keep annotations terse. A `phase-00` "master build plan / plan authored" entry is not a phase — it folds into `milestone.md` as preamble, never into `phases/00-*.md`. Sections: `# Milestone NN — <slug>` / `## Objectives` / `## Phases` (`- [x] NN-slug — one-liner (YYYY-MM-DD)`) / `## Done-contract` / optional `## Deferred` (one `- [ ]` line each). Frontmatter `type: milestone`.

**`roadmap.md` stays at program altitude.** Author a `## Milestones` index: one line per milestone with a `[done] | [active] | [planned]` token, a one-liner, and a `→ milestones/NN-slug/` pointer. Keep `## Backlog`. Frontmatter `type: roadmap`.

**Split the old backlog.** For each item, first the admission bar: it survives only if it needs a decision, is materially out of scope, or is real work that can't ride along safely. Drop `someday / never` entries outright. Everything else that fails the bar is proposed for dropping (cleanup cannot fix code, so surface each with what the fix would be; Adam decides). Then route each survivor: tied to the active milestone (a bug, cleanup, debt in its code) → that milestone's `## Deferred`; not tied (a standalone future feature) → `## Backlog`. One line each — compress a paragraph to a pointer; detail stays in git. Rewrite any line the migration makes stale (point at the relevant ADR and future milestone number rather than implying debt the architecture does not carry). Surface every rewrite, drop and move.
