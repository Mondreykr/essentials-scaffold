---
description: Session briefing — read scaffold files and orient on current state
---

**Precondition:** Verify that CLAUDE.md, `.scaffold/project.md`,
`.scaffold/state.md`, and `.scaffold/roadmap.md` exist. If any are missing,
stop and say: "Scaffold files missing — run /scaffold:setup first."

**Pause check:** Before doing anything else, check if `.scaffold/continue-here.md`
exists. If it does:

> "Paused session detected. Run `/scaffold:resume` to restore context
> and pick up where you left off."

Stop here. Do not proceed with the full status briefing.

Read the following files in order:
1. CLAUDE.md
2. .scaffold/project.md
3. .scaffold/state.md
4. .scaffold/roadmap.md

Do NOT read .scaffold/decisions.md unless something in state or roadmap references
a decision that needs context — it's reference material, not session briefing.

Then give me a brief orientation:

1. **Project** — What this is, in one sentence (from .scaffold/project.md)
2. **Phase** — Which phase is `[IN-PROGRESS]`, how many tasks done vs remaining
3. **State** — Current status and any blockers (from .scaffold/state.md)
4. **Open threads** — Open questions or things being figured out
5. **Investigations** — If `.scaffold/investigations/` exists and contains files:
   > **Investigations:** [N] investigation file(s) in `.scaffold/investigations/`.
   > [list filenames with one-line descriptions]

   Skip this section if the directory doesn't exist or is empty.
6. **Quick tasks** — If `.scaffold/quick/` exists, scan for directories with
   `plan.md` but no `summary.md` (pending quick tasks):
   > "Quick task NNN has a plan but hasn't been executed yet.
   > Run `/scaffold:quick-execute` to complete it."

   Skip this section if no pending quick tasks exist.
7. **Next action** — Based on state.md's "Next Action" section:
   - If Next Action has a plan pointer: "Pending execute: [plan summary].
     Run `/scaffold:execute` to continue."
   - If Next Action says plan needed: "Run `/scaffold:plan` to determine next steps."
   - If state is blocked: surface the blocker and suggest addressing it
8. **Health check** — Flag any contradictions between files. Examples:
   - State says something is blocked but roadmap shows it as complete
   - Roadmap shows a task `>>` in progress but state's Next Action doesn't reference it
   - A decision contradicts the current tech stack in CLAUDE.md
   - Project scope boundaries say "no X" but roadmap includes X

   If everything is consistent, say so. Note: this check catches pattern-level
   contradictions. It cannot reliably detect semantic drift or stale-by-omission.
   If something feels off, investigate the codebase rather than trusting file
   consistency alone.

9. **Staleness check** — Check the `<!-- Last updated: YYYY-MM-DD -->` date at the
   top of each scaffold file. If any file is more than 7 days old, flag it:
   "[filename] last updated [date] — may be stale."

Keep it short. This is a briefing, not a report. If everything is early/empty,
just say so and ask me what I want to work on.
