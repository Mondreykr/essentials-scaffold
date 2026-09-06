# Pre-rename (v1) migration

Applies to a repo that already has `milestones/NN-slug/` but predates the rename: a `plan.md`, `type: milestone-plan` / `type: phase-brief`, or `schema_version: 1`. Migrates in place; on an otherwise-current repo it is the only thing cleanup does.

- **Each milestone:** `git mv .scaffold/milestones/NN-slug/plan.md .../milestone.md`; `type: milestone-plan` → `type: milestone`. Content unchanged.
- **Each phase plan:** `type: phase-brief` → `type: phase-plan`. Never fabricate `## Targets` / `as of <sha>` or `## Governed by` — a plan without `## Targets` is a draft, which is correct. Leave an existing `## Governed by` in place.
- **A plan that already carries `## Targets`: strip it**, demoting it to a draft, and say so. Every path cleanup moves is under `.scaffold/`, so `go`'s freshness check would read the plan as fresh on a stamp you cannot vouch for.
  > "`<plan>` carried a `## Targets` stamped `as of <sha>` that I can't validate — removed, so it's a draft again. Run `/scaffold-plan --final` before `go`."
- **Bump `schema_version: 1` → `2`** on every `.scaffold/` doc.
- **Repoint** every `plan.md` path (`## Next`, cross-links) to `milestone.md`. Phase-plan paths are unchanged.
- Both `plan.md` and `milestone.md` present, or mixed `schema_version` → STOP and surface.
