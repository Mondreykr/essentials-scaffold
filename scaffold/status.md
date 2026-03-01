---
description: Session briefing — read scaffold files and orient on current state
---

**Precondition:** Verify that CLAUDE.md, `.scaffold/project.md`,
`.scaffold/state.md`, and `.scaffold/roadmap.md` exist. If any are missing,
stop and say: "Scaffold files missing — run /scaffold:setup first."

Read the following files in order:
1. CLAUDE.md
2. .scaffold/project.md
3. .scaffold/state.md
4. .scaffold/roadmap.md

Do NOT read .scaffold/decisions.md unless something in state or roadmap references
a decision that needs context — it's reference material, not session briefing.

Then give me a brief orientation:

1. **Project** — What this is, in one sentence (from .scaffold/project.md)
2. **State** — What's broken and any open questions (from .scaffold/state.md)
3. **Roadmap** — Current phase, what's in progress, what's up next (from .scaffold/roadmap.md)
4. **Open threads** — Any open questions or things I was figuring out
5. **Suggested pickup** — What makes sense to work on now, based on "Next session"
   in .scaffold/state.md plus your own judgment
6. **Health check** — Flag any contradictions between files. Examples:
   - State says something is broken but roadmap shows it as done
   - Roadmap shows something "in progress" but state's "Next session" treats it as not started
   - A decision in .scaffold/decisions.md contradicts the current tech stack in CLAUDE.md
   - Project scope boundaries say "no X" but roadmap includes X

   If everything is consistent, say so. Note: this check catches pattern-level
   contradictions (e.g., "state says X broken, roadmap says X done"). It cannot
   reliably detect semantic drift, omission contradictions, or information that
   became stale by absence. If something feels off, investigate the codebase
   rather than trusting file consistency alone.

7. **Staleness check** — Check the `<!-- Last updated: YYYY-MM-DD -->` date at the
   top of each scaffold file. If any file is more than 7 days old, flag it:
   "[filename] last updated [date] — may be stale."

If parking lot has 5+ items, mention: "You have X parking lot items — worth a
quick review?"

Keep it short. This is a briefing, not a report. If everything is early/empty,
just say so and ask me what I want to work on.
