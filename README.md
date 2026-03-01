# Essentials Scaffold

Lightweight context persistence for Claude Code. Five files, five commands, nothing else.

## What this is

Claude Code loses context between sessions — every `/clear` or new conversation starts from zero. Essentials Scaffold gives it memory with five markdown files and five slash commands. No dependencies, no config, no build step. Works in any project with or without git.

## Quick install

From your project root:

```bash
npx degit Mondreykr/essentials-scaffold/scaffold .claude/commands/scaffold
```

Or copy the `scaffold/` folder to `.claude/commands/scaffold/` manually if you already have the repo.

Then:

1. Open Claude Code in your project
2. Run `/scaffold:setup`

That's it. The setup command creates your context files and walks you through filling them in.

## Updating

To update the scaffold commands in an existing project:

```bash
npx degit Mondreykr/essentials-scaffold/scaffold .claude/commands/scaffold --force
```

This is safe — it only replaces the command files in `.claude/commands/scaffold/`. Your project data in `.scaffold/` and `CLAUDE.md` is never touched.

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
  plans/                     <- session plan files (created by /scaffold:plan)
    session-YYYY-MM-DD-slug.md
  scratch/                   <- investigation findings (created during execution)
    YYYYMMDD-#-topic.md
  archive/                   <- brownfield collision storage + graduation archive
    scaffold/                <- scaffold commands after graduation
  snapshot/                  <- graduation output (created by /scaffold:graduate)
    PROJECT-CONTEXT.md
.claude/
  hooks.json                 <- SessionStart hook (created by /scaffold:setup)
  commands/
    scaffold/
      setup.md
      status.md
      plan.md                <- session planning with consultation gates
      checkpoint.md
      graduate.md
```

- `.scaffold/` = project documentation, lives at root alongside your code
- `archive/` = old stuff preserved but inert
- `snapshot/` = useful context for the next framework
- `.claude/commands/scaffold/` = slash commands (Claude Code internals)
- `.claude/hooks.json` = auto-injects scaffold reminder on session start

## Daily workflow

```
Start:    /scaffold:status
Plan:     /scaffold:plan in plan mode (for substantial work — optional for quick tasks)
Work:     Accept plan with "Clear context" → Claude executes from plan file
Close:    /scaffold:checkpoint
Resume:   /scaffold:status (new session after /clear or new conversation)
Graduate: /scaffold:graduate (when moving to a heavier framework)
```

`/scaffold:status` reads your files and gives a briefing. `/scaffold:plan` triages the scaffold files, asks what you're thinking, then writes a self-contained plan that survives context clear. `/scaffold:checkpoint` verifies claims with evidence, reviews the session, and commits after your approval. For quick tasks, skip the plan step — just status, work, checkpoint.

## Enhanced modes

Each command has an optional enhanced mode. The base commands work without arguments — these just add deeper analysis when you want it.

| Command | What it adds |
|---------|-------------|
| `/scaffold:setup --deep` | Launches a codebase analysis after standard setup — maps architecture, surfaces conventions, and feeds findings into scaffold files. Best for brownfield projects. |
| `/scaffold:plan` (plan mode) | In plan mode, writes a self-contained plan file with tasks, deferred items, and decisions. Plan file survives context clear — Claude executes from it in a fresh session with full 200K context. |
| `/scaffold:checkpoint --audit` | After the standard checkpoint commits, verifies scaffold claims against actual code — checks that done items exist, tech stack matches manifests, decisions match reality. Reports discrepancies without modifying files. |
| `/scaffold:graduate --thorough` | Before graduating, scans the entire codebase for references to scaffold file paths that would break after archiving. Reports findings and waits for you to resolve them. |

## Recovery

**Checkpoint wrote bad state:**
`git diff .scaffold/` to see what changed. `git checkout -- .scaffold/<file>` to revert any file to its last commit.

**Files contradict each other:**
Run `/scaffold:status` — the health check flags contradictions. Tell Claude which file is correct and it will fix the other.

**Everything feels stale:**
Clear the contents of `.scaffold/state.md` and `.scaffold/roadmap.md` (keep the files with empty sections), then run `/scaffold:checkpoint` to regenerate them from the codebase and conversation.

**Context rot mid-session:**
`/clear` then `/scaffold:status` to start fresh from files.

## Graduation

When the project outgrows the scaffold — you need parallel task execution, automated verification agents, or wave-based orchestration — run `/scaffold:graduate`. It consolidates all five files into a single snapshot, archives the scaffold commands, and gets out of the way. The scaffold's state files map directly to GSD's `.planning/` directory structure. Point your new framework at the snapshot for full project context.

## What this doesn't do

**Context rot within a session.** If you work for hours in a single session, Claude
degrades as the conversation grows. This scaffold solves between-session memory, not
within-session degradation. Recovery: `/clear` then `/scaffold:status` to start fresh from files.

**Project management or execution methodology.** The plan command does lightweight
session planning (what to work on and in what order), but doesn't enforce how you
work. For parallel execution, automated verification agents, or dedicated debug
agents, graduate to GSD (get-shit-done) or a similar framework.

**Code quality enforcement.** This is a memory system, not a development methodology.
For execution discipline (testing, code review, structured implementation), add a
dedicated tool for that.

This scaffold is the foundation layer. It plays nicely underneath any tool you add later.

## Known limitations

**Claude compliance.** The persistence chain depends on Claude following the SessionStart hook and CLAUDE.md rules. Nothing forces `/scaffold:status` to run — the system reinforces this via hook + CLAUDE.md auto-read, but can't enforce it.

**No re-setup.** Setup checks if all five files exist and stops. To re-detect tech stack or pick up new context files, delete the scaffold files and re-run setup, or update them manually.

**Solo-only.** No multi-user conflict detection. Git handles merge conflicts at the file level.

**No session history.** Git commits serve as the session record. There's no built-in session log beyond what checkpoint commits capture.

**Graduation limbo.** After graduating, if you don't immediately set up a replacement framework, you'll have a CLAUDE.md pointer to the snapshot but no active context system. The snapshot is readable but inert.
