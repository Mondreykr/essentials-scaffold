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
| `CLAUDE-project.md` | Vision — what you're building, for whom, success criteria |
| `CLAUDE-state.md` | Health — bugs, open questions, parking lot, next session pickup |
| `CLAUDE-roadmap.md` | Progress — current phase, done, in progress, up next, later |
| `CLAUDE-decisions.md` | Record — why things are the way they are, with dates and reasoning |

## Daily workflow

```
Start:    /status
Work:     [build, iterate, discuss]
Close:    /checkpoint
Resume:   /status (new session after /clear or new conversation)
Graduate: /graduate (when moving to a heavier framework)
```

`/status` reads your files and gives a briefing. `/checkpoint` reviews the session and updates every file that changed. That's the whole loop.

## Recovery

**Checkpoint wrote bad state:**
`git diff CLAUDE-*.md` to see what changed. `git checkout -- <file>` to revert any file to its last commit.

**Files contradict each other:**
Run `/status` — the health check flags contradictions. Tell Claude which file is correct and it will fix the other.

**Everything feels stale:**
Delete `CLAUDE-state.md` and `CLAUDE-roadmap.md`, then run `/checkpoint` to regenerate them from the codebase and conversation.

**Context rot mid-session:**
`/clear` then `/status` to start fresh from files.

## Graduation

When the project outgrows the scaffold — you need structured planning, task breakdown, or execution discipline — run `/graduate`. It consolidates all five files into a single snapshot, archives the scaffold commands, and gets out of the way. Point your new framework at the snapshot for full project context.

## Full reference

See [essentials-scaffold.md](essentials-scaffold.md) for complete file templates, design rationale, the decisions file format, and everything else under the hood.
