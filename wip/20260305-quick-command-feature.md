# Feature: `/scaffold:quick` Command

**Status:** Design draft — needs discussion before implementation
**Date:** 2026-03-05
**Context:** Real-world scenario exposed the gap: urgent PDM diagnostic issue required immediate action, but scaffold only offers the full plan→execute ceremony. Work was done outside scaffold, leaving state inconsistent. GSD's `/gsd:quick` command handles this well.

---

## Problem

When an urgent issue arises mid-workflow:
1. The full plan→prep→execute→checkpoint ceremony is too heavy
2. Skipping scaffold entirely means state gets out of sync
3. There's no way to reconcile ad-hoc work back into scaffold state
4. Blockers get resolved but the resolution isn't tracked

## Proposed Solution

A lightweight `/scaffold:quick` command that handles urgent, small-scope work without disrupting the main workflow.

### Command Definition

```yaml
---
description: Quick fix — lightweight task without full plan/execute ceremony
argument-hint: [description of the issue]
---
```

### Flow

1. **Get description** — from argument or ask
2. **Create directory** — `.scaffold/quick/NNN-slug/` (zero-padded 3-digit)
3. **Investigate and fix** — no plan doc, no prep, just do it
   - If investigation needed: write to `NNN-slug/investigation.md`
   - If broadly relevant: write to `.scaffold/investigations/YYYYMMDD-NN-slug.md`
   - **Escape hatch:** If bigger than expected → STOP, suggest converting to full plan/execute
4. **Record outcome** — write `NNN-slug/summary.md`
5. **Update state** — add to `## Quick Fixes` table in state.md (created on-demand)
6. **Handle blockers** — if resolved a blocker, move to decisions.md as `Category: Resolved Blocker`
7. **Commit** — `quick(NNN): [description]`

### Directory Structure

```
.scaffold/quick/
├── 001-fix-pdm-diagnostic/
│   ├── investigation.md    (optional)
│   └── summary.md
├── 002-hotfix-auth-token/
│   └── summary.md
```

### Summary File Format

```markdown
# Quick Task NNN: [description]

**Date:** YYYY-MM-DD
**Status:** resolved | partial | deferred-to-plan

## Issue
[What was wrong — 1-3 sentences]

## Fix
[What was changed — files modified, approach taken]

## Verification
[How it was verified — test output, manual check, etc.]

## Notes
[Anything worth remembering. Omit if nothing to note.]
```

### State Tracking

Adds/appends to `## Quick Fixes` table in state.md:

```markdown
## Quick Fixes

| # | Description | Date | Status |
|---|-------------|------|--------|
| 001 | Fix PDM diagnostic slowdown | 2026-03-05 | resolved |
```

### Key Design Principles

- **Self-contained** — works even if mid-phase on something else
- **No main workflow disruption** — does NOT change Status, Current Position, or Next Action in state.md
- **No plan doc** — no `.scaffold/plans/` file generated
- **No prep** — investigation happens inline
- **Escape hatch** — if scope creeps, convert to full plan/execute

---

## Open Questions

1. **Reconciliation mode:** Should quick also handle "I already did the work outside scaffold, reconcile it"? Or is that a separate concern? Current thinking: separate — you can manually tell Claude how to reconcile using the scaffold conventions, or we add a `/scaffold:reconcile` later if the pattern recurs.

2. **Relationship to pause:** The ideal flow for an urgent issue mid-work would be: `/scaffold:pause` → `/scaffold:quick` → `/scaffold:resume`. Does this compose well? Any edge cases?

3. **Quick task scope limit:** GSD caps at 1-3 tasks. Is that right for scaffold too? What's the threshold where "this is too big for quick" triggers?

4. **State.md Quick Fixes table:** Should this be in the setup template (always present) or created on-demand (only when first quick task runs)? Current design: on-demand to keep new projects clean.

5. **Should quick tasks appear in the roadmap?** Current design: no — they're tracked separately. But if a quick fix directly completes a roadmap task, it marks it `[x]`. Is this the right boundary?

6. **Investigation file location:** Current design says quick-scoped investigations go in the quick task folder, broadly relevant ones go in `.scaffold/investigations/`. Is this distinction clear enough, or should all investigations always go to the central location?

---

## References

- GSD quick command: `~/.claude/get-shit-done/workflows/quick.md`
- GSD quick directory: `.planning/quick/NNN-slug/`
- GSD state tracking: `### Quick Tasks Completed` table in STATE.md
