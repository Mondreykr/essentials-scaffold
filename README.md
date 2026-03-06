# Essentials Scaffold

Lightweight context persistence for Claude Code. Markdown files, slash commands, nothing else.

## What this is

Claude Code loses context between sessions — every `/clear` or new conversation starts from zero. Essentials Scaffold gives it memory with five markdown files and a set of slash commands. No dependencies, no config, no build step. Works in any project with or without git.

## Install

One-time setup (installs commands for all projects):

```bash
npx degit Mondreykr/essentials-scaffold/scaffold $HOME/.claude/commands/scaffold
```

Or copy the `scaffold/` folder to `~/.claude/commands/scaffold/` manually if you already have the repo.

Then, in any project:

1. Open Claude Code
2. Run `/scaffold:setup`

That's it. The setup command creates your context files and walks you through filling them in. Commands are installed once at the user level and available in every project.

## Updating

Run `/scaffold:update` to pull the latest commands. This also detects and removes legacy per-project installs.

Or manually:

```bash
npx degit Mondreykr/essentials-scaffold/scaffold $HOME/.claude/commands/scaffold --force
```

This is safe — it only replaces the command files in `~/.claude/commands/scaffold/`. Your project data in `.scaffold/` and `CLAUDE.md` is never touched.

After updating from an older version, run `/scaffold:cleanup` to migrate your scaffold files to the current format.

## Migration from per-project install

If you previously installed scaffold commands per-project (into `.claude/commands/scaffold/`), you can migrate to the global install:

1. Run `/scaffold:update` — it detects the per-project install and offers to remove it
2. Or manually: delete `.claude/commands/scaffold/` from your projects after installing globally

## Architecture

The scaffold is a state machine. Every command leaves ALL state documents accurate and self-consistent. Any command could be the last thing that runs before a week-long gap.

### Command Lifecycle

```
status → plan → /clear → [prep → /clear] → execute → checkpoint
                                                  ↕
                                           pause ↔ resume

quick → quick-execute  (lightweight — runs independently of main workflow)
```

**Plan** updates scaffold files directly — the roadmap and state are always accurate after plan runs. User approves roadmap changes before they're written. Plan produces a **plan document** with scoped tasks.

**Prep** (optional) researches tactical detail for planned tasks — exact file paths, verification commands, implementation approach. Appends a Prep Detail section to the plan doc. Recommended for complex or unfamiliar code; skip for simple tasks.

**Execute** reads the plan doc (found via a pointer in state.md) and does the work. Uses Prep Detail if available, otherwise works from basic task descriptions. No strategic decisions, no scaffold updates.

**Checkpoint** closes the loop — verifies work, marks tasks complete, handles phase sign-off, and commits.

### Two Plan Paths

1. **State-only session** — Brainstorming, roadmap restructuring, no codebase changes. Plan updates files, produces a record, done.
2. **Execution session** — Codebase changes needed. Plan produces a plan doc with tactical detail. Execute follows it.

## Workflow

1. **Status** — run `/scaffold:status` to read your files and get oriented
2. **Plan** — run `/scaffold:plan` to scope work, update roadmap, write a plan doc
   - Run in plan mode (Shift+Tab) for enhanced research
   - State-only sessions end here
3. **Prep** (optional) — run `/scaffold:prep` to research tactical detail for planned tasks
   - Recommended for complex tasks or unfamiliar code
   - `/clear` after prep for a fresh context window
4. **Execute** — run `/scaffold:execute` to do the work from the plan doc
   - `/clear` first for a fresh context window (recommended for large tasks)
5. **Checkpoint** — run `/scaffold:checkpoint` to verify, update files, and commit
6. **Resume** — next session, start again from step 1

## Commands

| Command | What it does | When to use it |
|---------|-------------|----------------|
| `/scaffold:setup` | Creates context files and a SessionStart hook. Pass `--deep` to scan the codebase (best for brownfield projects). | Once per project, at the start |
| `/scaffold:status` | Reads scaffold files, gives a session briefing with health checks. Shows pending execute if one exists. | Every session start, or after `/clear` |
| `/scaffold:plan` | Triages state, consults you on direction, updates roadmap, scopes work, writes a plan doc. Run in plan mode (Shift+Tab). | Before substantial work sessions |
| `/scaffold:prep` | Researches tactical detail for planned tasks — file paths, verification commands, approach. Appends Prep Detail to plan doc. | After plan, before execute (optional — recommended for complex tasks) |
| `/scaffold:execute` | Reads the plan doc from state.md pointer, executes scoped tasks. Uses Prep Detail if available. Does not update scaffold files. | After plan (and optionally prep), when ready to do the work |
| `/scaffold:checkpoint` | Verifies work, updates scaffold files, handles phase sign-off, commits. Pass `--audit` to verify claims against code. | End of every work session |
| `/scaffold:pause` | Captures full session context to a handoff file for seamless resumption. | When you need to stop mid-work and pick up later |
| `/scaffold:resume` | Restores context from a paused session and routes to next action. | Start of session when a pause file exists |
| `/scaffold:quick` | Plans a quick fix — lightweight task that skips the full plan/execute ceremony. Pass `--discuss` for a clarification phase. | Urgent issues that don't warrant full planning |
| `/scaffold:quick-execute` | Executes a pending quick task — fix, verify, record, commit. | After `/scaffold:quick` plans a task |
| `/scaffold:cleanup` | Migrates existing scaffold files to current format. Handles old checkbox/section conventions. | After updating from an older version |
| `/scaffold:update` | Pulls latest scaffold commands to `~/.claude/commands/scaffold/`. Detects and removes legacy per-project installs. | When a new version is available |
| `/scaffold:graduate` | Consolidates into snapshot, archives commands, hands off. Pass `--thorough` to scan for breaking references. | When you outgrow the scaffold |

## Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Hub — identity, rules, constraints, tech stack (auto-read by Claude) |
| `.scaffold/project.md` | Vision — what you're building, for whom, success criteria |
| `.scaffold/state.md` | Status — current position, next action pointer, blockers, open questions |
| `.scaffold/roadmap.md` | Progress — phase-grouped tasks with completion tracking |
| `.scaffold/decisions.md` | Record — decisions logged chronologically (newest first), with dates and reasoning |
| `.scaffold/plans/` | Plan documents — execution contracts produced by `/scaffold:plan` |
| `.scaffold/investigations/` | Investigation output — durable research findings from investigation tasks |
| `.scaffold/quick/` | Quick task plans and summaries — lightweight fixes tracked outside the main workflow |

All scaffold data lives in `.scaffold/` at project root. Plan files, investigation output, and archives are created inside `.scaffold/` as you work.

## Roadmap Format

Tasks are tracked in phase-grouped sections:

```markdown
## Phase 1 — Setup [COMPLETE]
- [x] Project initialization (2026-03-01)
- [x] Auth integration (2026-03-02)

## Phase 2 — Core Features [IN-PROGRESS]
- [x] Data model design (2026-03-03)
- [ ] >> API endpoints
- [ ] Frontend components

## Phase 3 — Polish [PLANNED]
- [ ] Error handling improvements
- [ ] Performance optimization

## Backlog
- Mobile app
- Public API
```

- Only ONE phase `[IN-PROGRESS]` at a time
- Phase sign-off requires explicit user approval during checkpoint
- ALL phases use checkboxes for tasks; plain sub-bullets for detail only
- `Backlog` holds unassigned ideas and future work

## Recovery

**Checkpoint wrote bad state:**
`git diff .scaffold/` to see what changed. `git checkout -- .scaffold/<file>` to revert any file.

**Files contradict each other:**
Run `/scaffold:status` — the health check flags contradictions. Tell Claude which file is correct.

**Everything feels stale:**
Clear the contents of `state.md` and `roadmap.md` (keep the files with empty sections), then run `/scaffold:checkpoint` to regenerate from the codebase.

**Context rot mid-session:**
`/clear` then `/scaffold:status` to start fresh from files.

**Lost context mid-session:**
Run `/scaffold:pause` before `/clear` to save context. If you already cleared, run `/scaffold:status` — it reads from files.

**Old format after update:**
Run `/scaffold:cleanup` to migrate files to the current format.

## Limitations

**Context rot within a session.** Long conversations degrade Claude's attention. This scaffold solves between-session memory, not within-session degradation. Use `/clear` and `/scaffold:status` to reset.

**No enforcement.** The persistence chain depends on Claude following the SessionStart hook and CLAUDE.md rules. Nothing forces `/scaffold:status` to run — the hook and CLAUDE.md reinforce it, but can't enforce it.

**Solo-only.** No multi-user conflict detection. Git handles merge conflicts at the file level.

**No re-setup.** Setup checks if all five files exist and stops. To re-detect tech stack or pick up new context, delete the scaffold files and re-run setup, or update them manually.

**No session history.** Git commits serve as the session record. There's no built-in session log beyond what checkpoint commits capture.
