# Essentials Scaffold

Lightweight context persistence for Claude Code. Five files, four commands, nothing else.

## What this is

Claude Code loses context between sessions — every `/clear` or new conversation starts from zero. Essentials Scaffold gives it memory with five markdown files and four slash commands. No dependencies, no config, no build step. Works in any project with or without git.

## Quick install

1. Copy the `commands/` folder to `.claude/commands/` in your project root
2. Open Claude Code in your project
3. Run `/setup`

That's it. The setup command creates your context files and walks you through filling them in.

## What it creates

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Hub — who you are, rules, constraints, tech stack (auto-read by Claude) |
| `.scaffold/project.md` | Vision — what you're building, for whom, success criteria |
| `.scaffold/state.md` | Health — bugs, open questions, parking lot, next session pickup |
| `.scaffold/roadmap.md` | Progress — current phase, done, in progress, up next, later |
| `.scaffold/decisions.md` | Record — why things are the way they are, with dates and reasoning |

## Directory layout

```
CLAUDE.md                    <- root, auto-read by Claude Code
.scaffold/
  project.md                 <- vision and scope
  state.md                   <- health, bugs, open questions, parking lot
  roadmap.md                 <- progress tracking
  decisions.md               <- decision record with reasoning
  archive/                   <- brownfield collision storage + graduation archive
    commands/                <- scaffold commands after graduation
  snapshot/                  <- graduation output (created by /graduate)
    PROJECT-CONTEXT.md
.claude/
  commands/
    setup.md
    status.md
    checkpoint.md
    graduate.md
```

- `.scaffold/` = project documentation, lives at root alongside your code
- `archive/` = old stuff preserved but inert
- `snapshot/` = useful context for the next framework
- `.claude/commands/` = slash commands (Claude Code internals)

## Daily workflow

```
Start:    /status
Work:     [build, iterate, discuss]
Close:    /checkpoint
Resume:   /status (new session after /clear or new conversation)
Graduate: /graduate (when moving to a heavier framework)
```

`/status` reads your files and gives a briefing. `/checkpoint` reviews the session, shows you what changed, and commits after your approval. That's the whole loop.

## Enhanced modes

Each command has an optional enhanced mode. The base commands work without arguments — these just add deeper analysis when you want it.

| Command | What it adds |
|---------|-------------|
| `/setup --deep` | Launches a codebase analysis after standard setup — maps architecture, surfaces conventions, and feeds findings into scaffold files. Best for brownfield projects. |
| `/checkpoint --audit` | After the standard checkpoint commits, verifies scaffold claims against actual code — checks that done items exist, tech stack matches manifests, decisions match reality. Reports discrepancies without modifying files. |
| `/graduate --thorough` | Before graduating, scans the entire codebase for references to scaffold file paths that would break after archiving. Reports findings and waits for you to resolve them. |

## Recovery

**Checkpoint wrote bad state:**
`git diff .scaffold/` to see what changed. `git checkout -- .scaffold/<file>` to revert any file to its last commit.

**Files contradict each other:**
Run `/status` — the health check flags contradictions. Tell Claude which file is correct and it will fix the other.

**Everything feels stale:**
Delete `.scaffold/state.md` and `.scaffold/roadmap.md`, then run `/checkpoint` to regenerate them from the codebase and conversation.

**Context rot mid-session:**
`/clear` then `/status` to start fresh from files.

## Graduation

When the project outgrows the scaffold — you need structured planning, task breakdown, or execution discipline — run `/graduate`. It consolidates all five files into a single snapshot, archives the scaffold commands, and gets out of the way. Point your new framework at the snapshot for full project context.

## What this doesn't do

**Context rot within a session.** If you work for hours in a single session, Claude
degrades as the conversation grows. This scaffold solves between-session memory, not
within-session degradation. Recovery: `/clear` then `/status` to start fresh from files.

**Automated planning or task breakdown.** This tracks what you're doing, not what you
should do. For structured planning, graduate to a heavier framework.

**Code quality enforcement.** This is a memory system, not a development methodology.
For execution discipline (testing, code review, structured implementation), add a
dedicated tool for that.

This scaffold is the foundation layer. It plays nicely underneath any tool you add later.
