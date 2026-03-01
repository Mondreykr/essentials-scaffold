---
description: Initialize essentials scaffold — context persistence for Claude Code
argument-hint: [--deep]
---

I'm setting up the essentials scaffold for this project — a lightweight system of
markdown files that maintain context across sessions.

**Preflight checks:**
- Check if git is initialized. If not, warn: "This project has no git repo.
  The scaffold works without it, but git gives you undo for checkpoint. Consider
  running `git init` first."
- Scan for existing files:
  - **New-path scaffold files** (`.scaffold/project.md`, `.scaffold/state.md`,
    `.scaffold/roadmap.md`, `.scaffold/decisions.md`, and `CLAUDE.md` in root)
    are **collisions** — if all five exist AND look like scaffold files, tell me and stop —
    this project is already set up.
  - **Legacy scaffold files** (`CLAUDE-project.md`, `CLAUDE-state.md`, `CLAUDE-roadmap.md`,
    `CLAUDE-decisions.md` in project root) — archive them to `.scaffold/archive/`
    before creating fresh scaffold files. Log what was archived and why.
  - **Everything else** (`README.md`, `NOTES.md`, `CONTEXT.md`, `TODO.md`,
    `ARCHITECTURE.md`, etc.) is a **context source** — read for context. Most
    will be incorporated into scaffold files and archived (see Scope analysis).

**Scope analysis (existing projects only — skip for empty/new projects):**

If this project has existing code, do these three things before creating files:

1. **Auto-detect the tech stack** from dependency manifests and config files:
   `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `requirements.txt`,
   `Gemfile`, `pom.xml`, `build.gradle`, `composer.json`, etc. Note framework
   choices, database references, and major dependencies.

2. **Scan for context-bearing files:** Look for files that carry project context:
   `TODO.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `CONTRIBUTING.md`, `PROJECT.md`,
   `CHANGELOG.md`, `.cursor/rules`, `.github/CODEOWNERS`, etc. For each file found,
   report:
   - The filename
   - Which scaffold file its content maps to (e.g., `TODO.md` → parking lot in
     `.scaffold/state.md`, `ARCHITECTURE.md` → `.scaffold/decisions.md`)
   - A one-line summary of what it contains
   - Whether it will be archived or left in place

3. **Incorporate and archive by default:** The scaffold supersedes these files:
   - Pull content into the appropriate scaffold file during creation
   - Move originals to `.scaffold/archive/` (e.g. `TODO.md` → `.scaffold/archive/TODO.md`)
   - Log what was incorporated, where it went, and that the original was archived
   - **Exception:** `README.md` stays in place (serves GitHub/npm/external purposes) — read for context only
   - Present scan results and tell the user what will happen. Don't wait for file-by-file confirmation. If the user objects to a specific file being archived, respect that.

**Create the file structure:**

Create all five files using the templates below. For existing projects, populate
the templates with information gathered during scope analysis (after confirmation).
For new projects, use the placeholder text as-is.

1. **CLAUDE.md** — The hub. Claude reads this automatically. Lives in project root.

```markdown
# [Project Name]

## Who I am
- Comfortable with: [e.g. "terminal, git basics, reading code"]
- Less familiar with: [e.g. "databases, deployment, CSS"]
- Communication: [e.g. "Explain the why, skip the how unless I ask"]

## Rules
- Run /scaffold:status at the start of every session. For substantial work, discuss direction with the user, then run /scaffold:plan in plan mode.
- If /scaffold:status wasn't run, read .scaffold/project.md, .scaffold/state.md, and .scaffold/roadmap.md before doing any work.
- Before checkpoint: verify claims with evidence (run tests, check output). Don't claim "done" without verification.
- Consult .scaffold/decisions.md when making or revisiting technology/architecture/design choices
- Ask before making major architectural or structural changes
- If any scaffold file contradicts what you observe in the codebase, trust the codebase. State the contradiction to me explicitly before proceeding.
- When I say "checkpoint" — run /scaffold:checkpoint
- If we made decisions, found bugs, discussed scope changes, or planned future work and I haven't said "checkpoint" — remind me before the session ends

## Hard constraints
- [Things that must be true. Examples:]
- [Must work on mobile]
- [Budget under $X/month for services]
- [No paid APIs unless I approve]
- [Remove this section if none yet]

## Tech stack
- [e.g. "Next.js with App Router, Tailwind CSS, Supabase"]
- [Empty is fine early on]
```

2. **`.scaffold/project.md`** — The vision. What this project is and where it's going.

```markdown
<!-- Last updated: [today's date] -->
# Project Vision

## What is this?
[What are you building, or what problem are you trying to solve?
It's fine to be vague: "A tool that might help dog walkers manage their routes."
It's fine to be specific: "A SaaS platform for freelance dog walkers to plan
optimized multi-stop routes, manage client scheduling, and track walk history."
Write what's true right now.]

## Who is it for?
[Who would use this? Can be "just me" or a target audience.]

## What does success look like?
[How will you know it's working? What's the minimum thing that would make
this feel real? e.g. "I can add stops to a map and it saves them."]

## Scope boundaries
[What is this NOT? What are you explicitly choosing not to build, at least for now?
e.g. "Not a social network. No sharing features yet. Single user only for now."]
```

3. **`.scaffold/state.md`** — Health and context. Changes every session.

```markdown
<!-- Last updated: [today's date] -->
# Current State

## What's not working
- [Bugs, broken things, rough edges]
- [e.g. "Login redirect fails after signup"]
- [e.g. "Map component renders but doesn't save pin locations"]

## Open questions
[Things you're actively figuring out or undecided on:]
- [e.g. "Should routes be stored as coordinates or addresses?"]
- [e.g. "Is a map even the right interface for this?"]

## What's working well
[Things you like and want to preserve. Brief bullets:]
- [e.g. "The card-based layout feels right"]
- [e.g. "Supabase auth was painless"]

## Parking lot
[Ideas you don't want to lose but aren't acting on now:]
- [e.g. "Maybe add Stripe payments later"]
- [e.g. "What if users could share routes publicly?"]
- [e.g. "Push notifications for upcoming walks"]

## Next session
[Specific pickup points. Be concrete enough that future-you can act immediately:]
- [e.g. "Try adding drag-and-drop route ordering"]
- [e.g. "Fix the login redirect bug"]
- [e.g. "No idea yet — ask me what I'm thinking about"]
```

4. **`.scaffold/roadmap.md`** — The plan. All progress lives here.

```markdown
<!-- Last updated: [today's date] -->
# Roadmap

## Current phase
[What are you focused on right now? e.g. "Prototyping core features"
or "Getting the MVP functional" or "Just exploring"]

## Done
- [Completed milestones, features, or tasks]
- [e.g. "v Project setup and basic layout"]
- [e.g. "v User authentication working"]

## In progress
- [What's actively being worked on]
- [e.g. ">> Route builder with map integration"]

## Up next
- [What comes after the current work]
- [e.g. "Schedule management interface"]
- [e.g. "Figure out data model for recurring walks"]

## Later
- [Things you know you'll need eventually but aren't close to yet]
- [e.g. "Payment processing"]
- [e.g. "Mobile optimization"]
- [e.g. "Deploy to production"]
```

5. **`.scaffold/decisions.md`** — The record. Why things are the way they are.

Organize decisions under category headers. Each entry uses this format:

```markdown
<!-- Last updated: [today's date] -->
# Decisions

## Tech

### [Date] — [What was decided]
**Context:** [What prompted this choice]
**Decision:** [What was chosen]
**Why:** [The reasoning — even if informal]
**Status:** Active | Revisiting | Reversed

---

[Example:]

### 2026-02-27 — Next.js with App Router
**Context:** Needed to pick a framework. No strong preference.
**Decision:** Next.js with App Router and Tailwind CSS
**Why:** Claude recommended it as the most straightforward full-stack option
for a solo builder. Good defaults, large community, easy Vercel deployment.
**Status:** Active

## Architecture

### 2026-02-27 — Supabase for database and auth
**Context:** Need a database and user authentication. Don't want to manage infrastructure.
**Decision:** Supabase (PostgreSQL + built-in auth)
**Why:** Free tier covers prototyping. Auth is built in so I don't have to wire it up
separately. Claude has strong familiarity with the SDK.
**Status:** Active

## Design

## Scope

## Archived
[Reversed or superseded decisions. Kept for historical context.]
```

6. **Verify companion commands** — confirm that `status.md`, `checkpoint.md`,
   `plan.md`, and `graduate.md` exist as sibling files in this same folder. If
   any are missing, tell me — they should have been installed together.

7. **Create or update `.claude/hooks.json`** — SessionStart hook for automatic
   scaffold context loading.

   If `.claude/hooks.json` does not exist, create it:
   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "type": "command",
           "command": "test -f .scaffold/state.md && echo '{\"additionalContext\": \"[SCAFFOLD] This project uses essentials-scaffold for context persistence. Scaffold files are at .scaffold/. Run /scaffold:status to orient before starting work. Do not skip this step even if the task seems simple.\"}' || true"
         }
       ]
     }
   }
   ```

   If `.claude/hooks.json` already exists, add the SessionStart hook entry
   to the existing hooks without overwriting other hooks. If a SessionStart
   hook already exists, append to the array.

**After creating everything:**
- If git is initialized: stage new files and any deletions from archiving, then commit: `git add CLAUDE.md .scaffold/ && git add -u && git commit -m "init: essentials scaffold"`
- Give me a summary of what was set up, what content was incorporated (and from where), what was archived, and what I should fill in or verify.

**Enhanced mode (`/scaffold:setup --deep`):**

If "--deep" appears in the arguments, do everything above AND launch an Explore
subagent (thoroughness: "very thorough") after creating scaffold files to:

1. Analyze code structure — identify top-level modules, key entry points,
   and how the codebase is organized
2. Map architectural patterns — routing approach, state management, data flow,
   API layer structure
3. Surface conventions — naming patterns, file organization rules, import style,
   test location conventions
4. Identify undocumented dependencies — things that aren't in manifests but
   matter (build tools, CI assumptions, environment requirements)

Feed subagent findings back into the scaffold files:
- Architectural patterns → .scaffold/decisions.md (as discovered conventions, not decisions)
- Module structure → .scaffold/project.md "What is this?" section
- Known issues or TODOs found in code → .scaffold/state.md

If the subagent fails or times out, the standard setup is already complete.
Tell the user what the deep scan found and what was added to which files.
