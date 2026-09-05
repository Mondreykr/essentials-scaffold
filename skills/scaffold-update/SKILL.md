---
name: scaffold-update
description: Update the scaffold skills to the latest version and clean up legacy installs — pull the current /scaffold-[skill] skills, remove stale command-era installs that would shadow them, and flag an old .scaffold/ layout that needs migrating. Touches no .scaffold/ project content. Use whenever the user wants to update, upgrade, or refresh scaffold itself (the skills), or pull the latest version — even if they only say "update scaffold" or "get the latest scaffold".
---

# scaffold-update

Pull the latest scaffold **skills** and tidy up after older installs. This touches only
the installed skills under `~/.claude/skills/` — project data in `.scaffold/` is never modified.

**Boundary.** Updates the installed skill files only. It never **writes or modifies** any `.scaffold/` content (that's `cleanup`/`checkpoint`), never touches project code, and never migrates an old layout itself — Step 3 detects one and routes to `/scaffold-cleanup`. It *does* read the Step 3 layout markers; that read is the point of the step.

---

## Step 1: Pull the latest skills

Scaffold ships as skills, each a folder `scaffold-<skill>/SKILL.md` installed at
`~/.claude/skills/`. Pull the current set:

```bash
npx degit mondreykr/scaffold/skills $HOME/.claude/skills --force
```

This overwrites the `scaffold-*` skill folders in place and leaves any unrelated skills in
`~/.claude/skills/` untouched. After the pull, confirm all nine `scaffold-*/SKILL.md`
landed (setup, status, plan, go, checkpoint, audit, integrate, cleanup, update) and that `scaffold-audit/references/` holds its 11 contract copies — audit is the sole grader of per-contract rules, so a truncated copy that lands its `SKILL.md` without `references/` leaves it grading against nothing. If either check fails, re-run the command.

## Step 2: Retire command-era installs

Scaffold once shipped as **commands**. A leftover command install will shadow
or duplicate the skills — find and offer to remove it:

- **User-level commands** at `~/.claude/commands/scaffold/` — the old global install.
  Offer to delete: "Found command-era scaffold at `~/.claude/commands/scaffold/`. Scaffold
  is skills now; these are stale and can shadow the new `/scaffold-[skill]` skills. Remove
  them?"
- **Per-project commands** at `.claude/commands/scaffold/` (in the project dir, not home)
  — a legacy per-project install. Same offer; if its parent `.claude/commands/` is then
  empty, remove that too.

If the user declines, warn that stale command files may shadow the skills.

## Step 3: Detect an old `.scaffold/` layout + direct to cleanup

New skills against an **old layout** is the most dangerous window — the skills expect the
current structure and will misread a pre-restructure one. Check the project for markers.

**Pre-restructure layout** (the milestone migration): a single `.scaffold/decisions.md`
(file, not a `decisions/` folder), a `.scaffold/plans/` directory, a per-phase build plan
inside `roadmap.md`, a missing `.scaffold/architecture.md`, or `.scaffold/` docs lacking
`type`/`schema_version` frontmatter.

**Pre-rename layout (`schema_version: 1`)** — the brief→plan / plan.md→milestone.md rename.
Markers, any one of which means the repo predates it and every current skill will misread
it: any `.scaffold/` doc carrying **`schema_version: 1`**, a frontmatter **`type:
milestone-plan`** or **`type: phase-brief`**, or a milestone folder holding a **`plan.md`**
(the current name is `milestone.md`). Without this check, `update` would report a v1 repo
as "already current" — the exact silent misread this step exists to prevent.

Current-schema layout changes (`schema_version: 2`, so the version marker cannot catch them). Every format change adds a marker here — that is the policy, not an afterthought. Two so far: a `roadmap.md` `[done]` milestone line whose path does not point into `milestones/archived/` (or a `[done]` milestone folder still sitting outside `archived/`), and an absent `.scaffold/glossary.md`. Either one means the repo predates a change `cleanup` migrates.

If any marker (any layout) is present, emit a hard directive (do not soften):
> "⚠ This project is on an OLD scaffold layout, but the skills were just updated. Run
> /scaffold-cleanup NOW — before any other scaffold skill (status / plan / go /
> checkpoint). They expect the current layout and will misread the old one."

If the layout is already current, no migration is needed.

## Step 4: Report

State what happened: whether a command-era install was found and removed; that the skills
were updated at `~/.claude/skills/`; and the old-layout directive above, if it applied.
