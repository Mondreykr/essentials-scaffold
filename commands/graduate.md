**Precondition:** Verify that all five scaffold files exist: CLAUDE.md,
CLAUDE-project.md, CLAUDE-state.md, CLAUDE-roadmap.md, CLAUDE-decisions.md.
If any are missing, stop and report which files are absent.

The project is graduating from the essentials scaffold to a more capable framework.
Your job is to consolidate everything into a clean handoff package and remove the
scaffold so it doesn't conflict.

**1. Read all scaffold files:**
- CLAUDE-project.md
- CLAUDE-state.md
- CLAUDE-roadmap.md
- CLAUDE-decisions.md
- CLAUDE.md

**2. Create the snapshot:**
Create `.claude/scaffold/snapshot/PROJECT-CONTEXT.md` — a single structured file that
consolidates everything worth carrying forward:

```
# Project Context (Scaffold Graduation Snapshot)

## Vision
[From CLAUDE-project.md — what this is, who it's for, success criteria, scope]

## Current State
[From CLAUDE-state.md — what's broken, open questions, things working well]

## Roadmap
[From CLAUDE-roadmap.md — current phase, done, in progress, up next, later]

## Decisions
[From CLAUDE-decisions.md — all active decisions with their context and reasoning]

## Tech Stack
[From CLAUDE.md]

## Hard Constraints
[From CLAUDE.md]

## Who I Am
[From CLAUDE.md — comfort levels and communication preferences]
```

**3. Archive the scaffold:**
- Move CLAUDE-project.md, CLAUDE-state.md, CLAUDE-roadmap.md, CLAUDE-decisions.md
  to `.claude/scaffold/archive/`
- Move all scaffold commands (setup.md, status.md, checkpoint.md, graduate.md)
  from `.claude/commands/` to `.claude/scaffold/archive/commands/`

**4. Verify the archive:**
Before modifying CLAUDE.md, confirm all expected files landed in their archive
locations:
- `.claude/scaffold/archive/CLAUDE-project.md`
- `.claude/scaffold/archive/CLAUDE-state.md`
- `.claude/scaffold/archive/CLAUDE-roadmap.md`
- `.claude/scaffold/archive/CLAUDE-decisions.md`
- `.claude/scaffold/archive/commands/setup.md`
- `.claude/scaffold/archive/commands/status.md`
- `.claude/scaffold/archive/commands/checkpoint.md`
- `.claude/scaffold/archive/commands/graduate.md`

If anything is missing, stop and report what failed to move.

**5. Update CLAUDE.md:**
- Remove all scaffold-specific rules (the /status and /checkpoint references,
  the file-reading rules)
- Keep "Who I am", "Hard constraints", and "Tech stack"
- Add a pointer: "Previous scaffold context is at `.claude/scaffold/snapshot/PROJECT-CONTEXT.md`"

**6. Commit:**
`git add -A && git commit -m "graduate: essentials scaffold -> [new framework]"`

**7. Tell me:**
- What was consolidated into the snapshot
- What was archived
- "Point your new framework at `.claude/scaffold/snapshot/PROJECT-CONTEXT.md` for
  full project context."
