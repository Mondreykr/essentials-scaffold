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

**4. Update CLAUDE.md:**
- Remove all scaffold-specific rules (the /status and /checkpoint references,
  the file-reading rules)
- Keep "Who I am", "Hard constraints", and "Tech stack"
- Add a pointer: "Previous scaffold context is at `.claude/scaffold/snapshot/PROJECT-CONTEXT.md`"

**5. Commit:**
`git add -A && git commit -m "graduate: essentials scaffold -> [new framework]"`

**6. Tell me:**
- What was consolidated into the snapshot
- What was archived
- "Point your new framework at `.claude/scaffold/snapshot/PROJECT-CONTEXT.md` for
  full project context."
