# Essentials Scaffold

Lightweight context persistence for Claude Code. Five files, five commands, nothing else.

## What this is

Claude Code loses context between sessions — every `/clear` or new conversation starts from zero. Essentials Scaffold gives it memory with five markdown files and five slash commands. No dependencies, no config, no build step. Works in any project with or without git.

## Install

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

## Workflow

1. **Status** — run `/scaffold:status` to read your files and get oriented
2. **Plan** — run `/scaffold:plan` to scope the work and write a plan file
   - Optional for quick tasks — skip straight to working
   - Run in plan mode (Shift+Tab) for enhanced performance
3. **Work** — accept the plan, Claude executes from the plan file
4. **Checkpoint** — run `/scaffold:checkpoint` to verify, update files, and commit
5. **Resume** — next session, start again from step 1

## Commands

| Command | What it does | When to use it |
|---------|-------------|----------------|
| `/scaffold:setup` | Creates the five context files and a SessionStart hook, walks you through initial content. Pass `--deep` to scan the codebase after setup (best for brownfield projects). | Once per project, at the start |
| `/scaffold:status` | Reads all scaffold files, gives a session briefing with health checks | Every session start, or after `/clear` |
| `/scaffold:plan` | Triages state, consults you on scope, writes a plan file that survives context clear. Run in plan mode (Shift+Tab) so Claude researches before writing — then execute the plan in a fresh session with full context window. | Before substantial work sessions |
| `/scaffold:checkpoint` | Verifies work against claims, updates scaffold files, commits with your approval. Pass `--audit` to verify scaffold claims against actual code after committing. | End of every work session |
| `/scaffold:graduate` | Consolidates files into a single snapshot, archives commands, hands off to your next framework. Pass `--thorough` to scan for references to scaffold paths that would break after archiving. | When you outgrow the scaffold |

## Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Hub — identity, rules, constraints, tech stack (auto-read by Claude) |
| `.scaffold/project.md` | Vision — what you're building, for whom, success criteria |
| `.scaffold/state.md` | Health — bugs, open questions, parking lot, next session pickup |
| `.scaffold/roadmap.md` | Progress — current phase, done, in progress, up next |
| `.scaffold/decisions.md` | Record — why things are the way they are, with dates and reasoning |

All scaffold data lives in `.scaffold/` at project root. Plan files, scratch notes, and archives are created inside `.scaffold/` as you work.

## Recovery

**Checkpoint wrote bad state:**
`git diff .scaffold/` to see what changed. `git checkout -- .scaffold/<file>` to revert any file.

**Files contradict each other:**
Run `/scaffold:status` — the health check flags contradictions. Tell Claude which file is correct.

**Everything feels stale:**
Clear the contents of `state.md` and `roadmap.md` (keep the files with empty sections), then run `/scaffold:checkpoint` to regenerate from the codebase.

**Context rot mid-session:**
`/clear` then `/scaffold:status` to start fresh from files.

## Limitations

**Context rot within a session.** Long conversations degrade Claude's attention. This scaffold solves between-session memory, not within-session degradation. Use `/clear` and `/scaffold:status` to reset.

**No enforcement.** The persistence chain depends on Claude following the SessionStart hook and CLAUDE.md rules. Nothing forces `/scaffold:status` to run — the hook and CLAUDE.md reinforce it, but can't enforce it.

**Solo-only.** No multi-user conflict detection. Git handles merge conflicts at the file level.

**No re-setup.** Setup checks if all five files exist and stops. To re-detect tech stack or pick up new context, delete the scaffold files and re-run setup, or update them manually.

**No session history.** Git commits serve as the session record. There's no built-in session log beyond what checkpoint commits capture.
