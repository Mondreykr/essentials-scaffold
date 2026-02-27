I'm setting up the essentials scaffold for this project — a lightweight system of
markdown files that maintain context across sessions.

**Preflight checks:**
- Check if git is initialized. If not, warn: "This project has no git repo.
  The scaffold works without it, but git gives you undo for checkpoint. Consider
  running `git init` first."
- Scan for existing files in the project root:
  - **Scaffold filenames** (`CLAUDE.md`, `CLAUDE-project.md`, `CLAUDE-state.md`,
    `CLAUDE-roadmap.md`, `CLAUDE-decisions.md`) are **collisions** — archive them
    to `.claude/scaffold/archive/` before creating fresh scaffold files. Log what
    was archived and why.
  - **Everything else** (`README.md`, `NOTES.md`, `CONTEXT.md`, `TODO.md`,
    `ARCHITECTURE.md`, etc.) is a **context source** — read for context but leave
    in place.
- If all five scaffold files already exist AND look like scaffold files (not archived
  leftovers), tell me and stop — this project is already set up.

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
     CLAUDE-state.md, `ARCHITECTURE.md` → CLAUDE-decisions.md)
   - A one-line summary of what it contains

3. **Ask before incorporating:** Present the scan results and wait for confirmation
   before pulling any discovered content into scaffold files. Don't silently merge.

**Create the file structure:**

Create all five files using the templates below. For existing projects, populate
the templates with information gathered during scope analysis (after confirmation).
For new projects, use the placeholder text as-is.

1. **CLAUDE.md** — The hub. Claude reads this automatically.

```markdown
# [Project Name]

## Who I am
- Comfortable with: [e.g. "terminal, git basics, reading code"]
- Less familiar with: [e.g. "databases, deployment, CSS"]
- Communication: [e.g. "Explain the why, skip the how unless I ask"]

## Rules
- Run /status at the start of every session. If /status wasn't run, read CLAUDE-project.md, CLAUDE-state.md, and CLAUDE-roadmap.md before doing any work.
- Consult CLAUDE-decisions.md when making or revisiting technology/architecture/design choices
- Ask before making major architectural or structural changes
- If any scaffold file contradicts what you observe in the codebase, trust the codebase. State the contradiction to me explicitly before proceeding.
- When I say "checkpoint" — run /checkpoint

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

2. **CLAUDE-project.md** — The vision. What this project is and where it's going.

```markdown
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

3. **CLAUDE-state.md** — Health and context. Changes every session.

```markdown
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

4. **CLAUDE-roadmap.md** — The plan. All progress lives here.

```markdown
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

5. **CLAUDE-decisions.md** — The record. Why things are the way they are.

Organize decisions under category headers. Each entry uses this format:

```markdown
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

6. **Create the `.claude/commands/` directory** if it doesn't exist, and confirm
   that `status.md`, `checkpoint.md`, and `graduate.md` are present. If they're
   not, tell me — I need to add them manually.

**After creating everything:**
- If git is initialized: `git add CLAUDE-*.md .claude/ && git commit -m "init: essentials scaffold"`
- Give me a summary of what was set up, what was archived (if anything), and what I should fill in or verify.
