# Essentials Scaffold

Lightweight context persistence for Claude Code. Five files, four commands, no dependencies.

Works best in a git repo. If you're not using git, start — it's your undo button for checkpoint.

---

## Session lifecycle

```
Start:    /status
Work:     [build, iterate, discuss]
Close:    /checkpoint
Resume:   /status (new session after /clear or new conversation)
Graduate: /graduate (when moving to a heavier framework)
```

---

## Directory layout

```
CLAUDE.md                              <- root, auto-read by Claude Code
CLAUDE-project.md                      <- root, visible
CLAUDE-state.md
CLAUDE-roadmap.md
CLAUDE-decisions.md
.claude/
  commands/
    setup.md
    status.md
    checkpoint.md
    graduate.md
  scaffold/
    archive/                           <- brownfield collision storage (created by /setup if needed)
      commands/                        <- scaffold commands after graduation
    snapshot/                          <- graduation output (created by /graduate)
      PROJECT-CONTEXT.md
```

- `archive/` = old stuff preserved but inert
- `snapshot/` = useful context for the next framework
- Separate locations prevent confusion about which files matter

---

## The files

### `CLAUDE.md`

The hub. Claude reads this automatically. It tells Claude who you are, how to behave, and where to find everything else.

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

---

### `CLAUDE-project.md`

The vision. What this project is and where it's trying to go. Can be one vague sentence on day one or a full product description by month two. This file evolves as your understanding evolves.

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

---

### `CLAUDE-state.md`

Health and context. What's broken, what you're thinking about, what to pick up next. Changes every session. Progress lives in the roadmap — this file tracks everything else.

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

---

### `CLAUDE-roadmap.md`

The plan. All progress lives here — what's done, what's in flight, what's next. On day one this might be nearly empty. By week three it has phases. It grows with the project.

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

---

### `CLAUDE-decisions.md`

The record. Why things are the way they are. Prevents re-debating settled choices across sessions. Grows over time, consulted when relevant.

Organize decisions under category headers. When the list gets long, move old stable entries to Archived.

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

---

## The slash commands

Create `.claude/commands/` in your project root. Add these four files.

---

### `.claude/commands/setup.md`

Run once when starting a new project or adopting the scaffold on an existing one.

```markdown
I'm setting up the essentials scaffold for this project — a lightweight system of
markdown files that maintain context across sessions.

**Preflight checks:**
- Check if git is initialized. If not, warn: "This project has no git repo.
  The scaffold works without it, but git gives you undo for checkpoint. Consider
  running `git init` first."
- Scan for existing CLAUDE-*.md files or other context documents (README.md,
  NOTES.md, CONTEXT.md, etc.) that could collide with scaffold files.
  - If colliding CLAUDE-*.md files exist: move them to `.claude/scaffold/archive/`
    before creating scaffold files. Log what was archived and why.
  - Non-colliding files (README.md, NOTES.md, etc.): read them for context but
    leave them in place.
- If CLAUDE.md, CLAUDE-project.md, CLAUDE-state.md, CLAUDE-roadmap.md, and
  CLAUDE-decisions.md all already exist AND look like scaffold files (not archived
  leftovers), tell me and stop — this project is already set up.
- If this is a new/empty project, create all five files from scratch using the
  templates below.
- If this is an existing project with code but no scaffold files, create all five
  files AND analyze the existing codebase to populate them with accurate information
  about what's already here (tech stack, current state, any decisions you can infer
  from the code).

**Create the file structure:**

1. **CLAUDE.md** — The hub file. Include:
   - "Who I am" section (ask me to fill in if you don't know):
     - Comfortable with: [areas]
     - Less familiar with: [areas]
     - Communication: [preference]
   - "Rules" section with these exact rules:
     - Run /status at the start of every session. If /status wasn't run, read CLAUDE-project.md, CLAUDE-state.md, and CLAUDE-roadmap.md before doing any work.
     - Consult CLAUDE-decisions.md when making or revisiting technology/architecture/design choices
     - Ask before making major architectural or structural changes
     - If any scaffold file contradicts what you observe in the codebase, trust the codebase. State the contradiction to me explicitly before proceeding.
     - When I say "checkpoint" — run /checkpoint
   - "Hard constraints" section (ask me, or leave placeholder)
   - "Tech stack" section (populate from codebase if existing, otherwise leave blank)

2. **CLAUDE-project.md** — The vision file. Include:
   - "What is this?" (ask me)
   - "Who is it for?" (ask me)
   - "What does success look like?" (ask me)
   - "Scope boundaries" (ask me)

3. **CLAUDE-state.md** — The health and context file. Include:
   - "What's not working" (empty or populate if obvious issues found)
   - "Open questions" (empty)
   - "What's working well" (empty)
   - "Parking lot" (empty)
   - "Next session" (empty)

4. **CLAUDE-roadmap.md** — The roadmap file (all progress lives here). Include:
   - "Current phase"
   - "Done" (populate from codebase if existing)
   - "In progress"
   - "Up next"
   - "Later"

5. **CLAUDE-decisions.md** — The decisions file with category headers. Include:
   - Categories: Tech, Architecture, Design, Scope, Archived
   - Any decisions you can infer from existing code (framework choice, database choice, etc.)
   - Each entry: date, what was decided, context, decision, why, status

6. **Create the `.claude/commands/` directory** if it doesn't exist, and confirm
   that `status.md`, `checkpoint.md`, and `graduate.md` are present. If they're
   not, tell me — I need to add them manually.

**After creating everything:**
- If git is initialized: `git add CLAUDE-*.md .claude/ && git commit -m "init: essentials scaffold"`
- Give me a summary of what was set up, what was archived (if anything), and what I should fill in or verify.
```

---

### `.claude/commands/status.md`

Run at the start of every session.

```markdown
Read the following files in order:
1. CLAUDE.md
2. CLAUDE-project.md
3. CLAUDE-state.md
4. CLAUDE-roadmap.md

Do NOT read CLAUDE-decisions.md unless something in state or roadmap references
a decision that needs context — it's reference material, not session briefing.

Then give me a brief orientation:

1. **Project** — What this is, in one sentence (from CLAUDE-project.md)
2. **State** — What's broken and any open questions (from CLAUDE-state.md)
3. **Roadmap** — Current phase, what's in progress, what's up next (from CLAUDE-roadmap.md)
4. **Open threads** — Any open questions or things I was figuring out
5. **Suggested pickup** — What makes sense to work on now, based on "Next session"
   in CLAUDE-state.md plus your own judgment
6. **Health check** — Flag any contradictions between files (e.g., state says
   something is broken but roadmap shows it as done). If everything is consistent,
   say so.

If parking lot has 5+ items, mention: "You have X parking lot items — worth a
quick review?"

Keep it short. This is a briefing, not a report. If everything is early/empty,
just say so and ask me what I want to work on.
```

---

### `.claude/commands/checkpoint.md`

Run at the end of every session (or anytime you say "checkpoint").

```markdown
Review everything we did and discussed this session. Then update the scaffold files:

**1. CLAUDE-state.md** (always update)
- Update "What's not working" — add new issues, remove resolved ones
- Update "Open questions" — add new ones, remove answered ones
- Update "What's working well" if I expressed a preference or positive reaction
- Review "Parking lot" — remove done/irrelevant/superseded items, add new ideas.
  Don't just add — curate.
- Write 2-3 specific, actionable items in "Next session" based on where we left off

**2. CLAUDE-roadmap.md** (always update)
- Move completed items to "Done"
- Update "In progress" to reflect what's actively being worked on
- Adjust "Up next" and "Later" if priorities shifted
- Update "Current phase" if the nature of the work has changed

**3. CLAUDE-decisions.md** (update only if we made meaningful choices)
- Add an entry under the appropriate category (Tech, Architecture, Design, Scope)
  for any decision made this session
- Use today's date
- Include context and reasoning even if informal
- Skip trivial decisions (variable names, minor styling, etc.)
- If we reversed or reconsidered a previous decision, update its status and move
  the entry to Archived
- If 20+ active entries, suggest archiving older stable ones

**4. CLAUDE-project.md** (update only if vision/scope evolved)
- Update "What is this?" if our understanding of the project sharpened
- Update "Scope boundaries" if we decided to include or exclude something
- Update "What does success look like?" if the goal shifted
- Skip if nothing changed about the vision

**5. CLAUDE.md** (update only if structural things changed)
- Update "Tech stack" if we added or changed technologies
- Update "Hard constraints" if new constraints emerged
- Skip if nothing structural changed

**After updating all files:**
- Re-read all updated files. Flag any contradictions between them.
- For each file updated, show the specific changes (what was added, removed, or
  reworded) — not just "updated state file". Keep it scannable but precise.
- List any open questions or loose threads heading into next session.
- If git is initialized: `git add CLAUDE-*.md && git commit -m "checkpoint: [brief summary of session]"`
```

---

### `.claude/commands/graduate.md`

Run when the project is ready to move to a heavier framework (GSD, Spec-Kit, etc.).

````markdown
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
````

---

## Usage

**New project:**
```
/setup
```
Answer the questions. Files get created. You're ready.

**Existing project (adopting the scaffold):**
```
/setup
```
Same command — it detects existing code and populates the files from what's already there. Colliding files get archived, not deleted.

**Every session start:**
```
/status
```

**Every session end:**
```
/checkpoint
```

**If Claude gets confused mid-session or context feels degraded:**
```
/clear
/status
```
This nukes the conversation and reloads from files. Manual context rot recovery.

**When you outgrow the scaffold:**
```
/graduate
```

---

## Recovery

**Checkpoint wrote bad state:**
`git diff CLAUDE-*.md` to see what changed. `git checkout -- <file>` to revert any file to its last commit.

**Files contradict each other:**
Run `/status` — the health check flags contradictions. Tell Claude which file is correct and it will fix the other.

**Everything feels stale:**
Delete CLAUDE-state.md and CLAUDE-roadmap.md, then run `/checkpoint` to regenerate them from the codebase and conversation.

**Context rot mid-session:**
`/clear` then `/status` to start fresh from files.

---

## What this doesn't do

**Context rot within a session.** If you work for hours in a single session, Claude
degrades as the conversation grows. This scaffold solves between-session memory, not
within-session degradation. Recovery: `/clear` then `/status` to start fresh from files.

**Automated planning or task breakdown.** This tracks what you're doing, not what you
should do. For structured planning, graduate to Spec-Kit or GSD.

**Code quality enforcement.** This is a memory system, not a development methodology.
For execution discipline (testing, code review, structured implementation), add
Superpowers.

This scaffold is the foundation layer. It plays nicely underneath any tool you add later.
