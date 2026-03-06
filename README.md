# Essentials Scaffold

Lightweight context persistence for Claude Code. Markdown files, slash commands, nothing else.

## What this is

Claude Code loses context between sessions — every `/clear` or new conversation starts from zero. Essentials Scaffold gives it memory with five markdown files and a set of slash commands. No dependencies, no config, no build step. Works in any project with or without git.

## Install

**Prerequisite:** [Node.js](https://nodejs.org/) (for `npx`).

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

If you previously installed scaffold commands per-project (into `.claude/commands/scaffold/`), you need to remove them — project-level commands shadow user-level ones, so the old copies would take priority over updates.

1. Delete `.claude/commands/scaffold/` from each project that has it (delete `.claude/commands/` too if it's now empty)
2. Install at user level if you haven't already: `npx degit Mondreykr/essentials-scaffold/scaffold $HOME/.claude/commands/scaffold`

After that, `/scaffold:update` works normally — it will also detect and remove any remaining per-project installs.

## How it works

The scaffold is a state machine. Every command leaves ALL state documents accurate and self-consistent. Any command could be the last thing that runs before a week-long gap.

There are two workflows: the **main workflow** for substantial work, and a **quick workflow** for small fixes.

### Main workflow

```
status → plan → execute → checkpoint
```

Each step is a separate command. Between commands, you can `/clear` to free up Claude's context window — the scaffold files carry all state, so nothing is lost. This is especially useful before execute on large tasks.

| Step | Command | What happens |
|------|---------|--------------|
| **Orient** | `/scaffold:status` | Reads scaffold files, gives a session briefing with health checks |
| **Plan** | `/scaffold:plan` | Triages state, consults you on direction, updates roadmap, writes a plan doc |
| **Prep** (optional) | `/scaffold:prep` | Researches tactical detail — file paths, verification commands, approach. Appends to the plan doc |
| **Execute** | `/scaffold:execute` | Reads the plan doc from state.md, does the work. No strategic decisions, no scaffold updates |
| **Checkpoint** | `/scaffold:checkpoint` | Verifies work, marks tasks complete, handles phase sign-off, commits |

**Plan** has two possible outcomes:
1. **Execution session** — codebase changes needed. Plan produces a plan doc, you proceed to execute.
2. **State-only session** — brainstorming, roadmap restructuring, no codebase changes. Plan updates files and you're done.

**Prep** is optional. Recommended for complex tasks or unfamiliar code. Skip for simple changes.

### User tasks

Some tasks require human action — deploying, configuring hardware, manual testing.
Mark these `[USER]` in the roadmap.

**Flow patterns:**

| Pattern | Flow | When |
|---------|------|------|
| AI only | plan → execute → checkpoint | All tasks are code changes |
| AI then USER | plan → execute → checkpoint → *user works* → verify | AI work first, then user work |
| USER only | plan → *user works* → verify | Only user tasks, no code changes |
| USER then AI | plan → *user works* → verify → plan → execute → checkpoint | User tasks must complete before AI can proceed |

When a plan contains `[USER]` tasks, checkpoint notes them as pending. After
completing your work, run `/scaffold:verify` to walk through each task, confirm
completion, and update the roadmap.

**Tip:** Run plan in plan mode (`Shift+Tab` in Claude Code — a read-only research mode where Claude can explore but not edit files) for more thorough analysis.

### Interrupting and resuming

Use `/scaffold:pause` when you need to stop mid-work — it captures full session context to a handoff file. Next session, `/scaffold:status` detects the pause and routes you to `/scaffold:resume`.

### Quick workflow

```
quick → quick-execute
```

For small fixes that don't warrant the full plan/execute ceremony. Quick tasks are tracked separately in `.scaffold/quick/` and don't disrupt the main workflow.

## Commands

| Command | What it does | When to use it |
|---------|-------------|----------------|
| `/scaffold:setup` | Creates context files and a SessionStart hook. Pass `--deep` to scan the codebase (best for brownfield projects). | Once per project, at the start |
| `/scaffold:status` | Reads scaffold files, gives a session briefing with health checks. Detects paused sessions and pending executes. | Every session start, or after `/clear` |
| `/scaffold:plan` | Triages state, consults you on direction, updates roadmap, scopes work, writes a plan doc. Run in plan mode (`Shift+Tab`). | Before substantial work sessions |
| `/scaffold:prep` | Researches tactical detail for planned tasks — file paths, verification commands, approach. Appends to the plan doc. | After plan, before execute (optional — recommended for complex tasks) |
| `/scaffold:execute` | Reads the plan doc from state.md pointer, executes scoped tasks. Uses prep detail if available. Does not update scaffold files. | After plan (and optionally prep), when ready to do the work |
| `/scaffold:checkpoint` | Verifies work, updates scaffold files, handles phase sign-off, commits. Pass `--audit` to verify claims against code. | End of every work session |
| `/scaffold:pause` | Captures full session context to a handoff file for seamless resumption. | When you need to stop mid-work and pick up later |
| `/scaffold:resume` | Restores context from a paused session and routes to next action. | Start of session when a pause file exists |
| `/scaffold:quick` | Plans a quick fix. Pass `--discuss` for a clarification phase. Pass a description inline (e.g., `/scaffold:quick fix the broken login redirect`). | Urgent fixes that don't warrant full planning |
| `/scaffold:quick-execute` | Executes a pending quick task — fix, verify, record, commit. | After `/scaffold:quick` plans a task |
| `/scaffold:verify` | Walks through pending `[USER]` tasks one at a time, verifies completion, updates roadmap and state. | After completing user tasks from a plan |
| `/scaffold:cleanup` | Migrates existing scaffold files to current format. Handles old checkbox/section conventions. | After updating from an older version |
| `/scaffold:update` | Pulls latest scaffold commands to `~/.claude/commands/scaffold/`. Detects and removes legacy per-project installs. | When a new version is available |
| `/scaffold:graduate` | Consolidates into snapshot, archives commands, hands off. Pass `--thorough` to scan for breaking references. | When you outgrow the scaffold |

## Files

Five core files provide context persistence. Additional directories are created as you work.

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

All scaffold data lives in `.scaffold/` at project root (except `CLAUDE.md`, which lives at the root so Claude auto-reads it).

## Roadmap format

Tasks are tracked in phase-grouped sections:

```markdown
## Phase 1 — Setup [COMPLETE]
- [x] Project initialization (2026-03-01)
- [x] Auth integration (2026-03-02)

## Phase 2 — Core Features [IN-PROGRESS]
- [x] Data model design (2026-03-03)
- [ ] >> API endpoints
- [ ] Frontend components
- [ ] [USER] Deploy DLL to vault

## Phase 3 — Polish [PLANNED]
- [ ] Error handling improvements
- [ ] Performance optimization

## Backlog
- Mobile app
- Public API
```

- `[IN-PROGRESS]` / `[COMPLETE]` / `[PLANNED]` — phase status. Only ONE phase `[IN-PROGRESS]` at a time.
- `[x]` — completed task. `[ ]` — incomplete task. Plain sub-bullets are detail, not tasks.
- `>>` — marks the current active task (what's being worked on right now).
- `[USER]` — marks tasks that require human action (deploying, configuring, manual testing). Verified via `/scaffold:verify` rather than executed by Claude.
- `Backlog` — unassigned ideas and future work, no checkboxes needed.
- Phase sign-off requires explicit user approval during checkpoint.

## Recovery

**Lost context mid-session:**
Run `/scaffold:pause` before `/clear` to save context. If you already cleared, run `/scaffold:status` — it reads from files and gets you oriented.

**Context rot mid-session:**
`/clear` then `/scaffold:status` to start fresh from files. Long conversations degrade Claude's attention — this resets it.

**Checkpoint wrote bad state:**
`git diff .scaffold/` to see what changed. `git checkout -- .scaffold/<file>` to revert any file.

**Files contradict each other:**
Run `/scaffold:status` — the health check flags contradictions. Tell Claude which file is correct.

**Everything feels stale:**
Clear the contents of `state.md` and `roadmap.md` (keep the files with empty sections), then run `/scaffold:checkpoint` to regenerate from the codebase.

**Old format after update:**
Run `/scaffold:cleanup` to migrate files to the current format.

**Want to re-detect tech stack or pick up new context:**
Setup won't re-run if scaffold files already exist. Delete `.scaffold/` and re-run `/scaffold:setup`, or update the files manually.

## Limitations

**Context rot within a session.** Long conversations degrade Claude's attention. This scaffold solves between-session memory, not within-session degradation. Use `/clear` and `/scaffold:status` to reset.

**No enforcement.** The persistence chain depends on Claude following the SessionStart hook and CLAUDE.md rules. Nothing forces `/scaffold:status` to run — the hook and CLAUDE.md reinforce it, but can't enforce it.

**Solo-only.** No multi-user conflict detection. Git handles merge conflicts at the file level.

**No session history.** Git commits serve as the session record. There's no built-in session log beyond what checkpoint commits capture.
