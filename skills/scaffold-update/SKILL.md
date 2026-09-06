---
name: scaffold-update
description: Update the scaffold skills to the latest version and clean up legacy installs — pull the current /scaffold-[skill] skills, remove stale command-era installs that would shadow them, and flag an old .scaffold/ layout that needs migrating. Touches no .scaffold/ project content. Use whenever the user wants to update, upgrade, or refresh scaffold itself (the skills), or pull the latest version — even if they only say "update scaffold" or "get the latest scaffold".
---

# scaffold-update

Pull the latest scaffold **skills** into `~/.claude/skills/` and tidy up after older installs.

**Boundary.** Writes installed skill files only. Never writes `.scaffold/` content, never touches project code, never migrates a layout — Step 3 reads the layout markers and routes to `/scaffold-cleanup`.

---

## Step 1: Pull the latest skills

```bash
rm -rf $HOME/.claude/skills/scaffold-*
npx degit mondreykr/scaffold/skills $HOME/.claude/skills --force
```

Remove first: degit overwrites but never deletes, so a retired contract copy or reference file would survive and audit would grade against it. Unrelated skills are untouched. Confirm all nine `scaffold-*/SKILL.md` landed (setup, status, plan, go, checkpoint, audit, integrate, cleanup, update) and that `scaffold-audit/references/` is non-empty — audit without it grades against nothing. Either check fails → re-run.

## Step 2: Retire command-era installs

Scaffold once shipped as commands; a leftover shadows the skills. Offer to remove:

- `~/.claude/commands/scaffold/`: "Found command-era scaffold at `~/.claude/commands/scaffold/`. Scaffold is skills now; these are stale and can shadow the new `/scaffold-[skill]` skills. Remove them?"
- `.claude/commands/scaffold/` in the project — same offer; remove an emptied parent `.claude/commands/` too.

Declined → warn that stale command files may shadow the skills.

## Step 3: Detect an old `.scaffold/` layout

New skills on an old layout misread it. Check for any marker:

- **Pre-restructure:** a single `.scaffold/decisions.md` file, a `.scaffold/plans/` folder, a per-phase build plan inside `roadmap.md`, no `architecture.md`, docs lacking `type` / `schema_version` frontmatter.
- **Pre-rename (v1):** any doc with `schema_version: 1`, `type: milestone-plan` or `type: phase-brief`, or a milestone folder holding `plan.md`.
- **Current-schema changes** (`schema_version: 2` cannot catch these; every format change adds a marker here): a `roadmap.md` `[done]` line whose path is not under `milestones/archived/` (or a `[done]` folder outside `archived/`); no `.scaffold/glossary.md`; a `## Backlog` line without a `→ backlog/` pointer.

Any marker → emit, unsoftened:
> "⚠ This project is on an OLD scaffold layout, but the skills were just updated. Run /scaffold-cleanup NOW — before any other scaffold skill (status / plan / go / checkpoint). They expect the current layout and will misread the old one."

## Step 4: Report

Whether a command-era install was found and removed; that the skills were updated at `~/.claude/skills/`; the old-layout directive if it applied.
