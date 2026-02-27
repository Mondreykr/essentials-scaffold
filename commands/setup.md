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
