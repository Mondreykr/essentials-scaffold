---
description: Save session progress — update scaffold files and commit
argument-hint: [--audit]
---

**Precondition:** Verify that CLAUDE.md, `.scaffold/state.md`, and
`.scaffold/roadmap.md` exist. If any are missing, stop and say:
"Scaffold files missing — run /scaffold:setup first."

Review everything we did and discussed this session. Then update the scaffold files.

**Capture routing — map conversation content to the right file:**
- Decisions or technology/architecture choices → .scaffold/decisions.md (include what was considered and rejected in the "Context" field)
- Bugs discovered or things broken → .scaffold/state.md "What's not working"
- Ideas, brainstorms, maybes → .scaffold/state.md "Parking lot"
- "Let's do X next time" or stated intentions → .scaffold/state.md "Next session"
- Scope changes or boundary shifts → .scaffold/project.md "Scope boundaries"
- Feature specs discussed but not built → .scaffold/roadmap.md (as detail under the relevant "Up next" or "Later" item)
- Preferences or positive reactions → .scaffold/state.md "What's working well"
- Approaches explicitly rejected → .scaffold/decisions.md (as context on the decision that won)

**1. `.scaffold/state.md`** (always update)
- Update "What's not working" — add new issues, remove resolved ones
- Update "Open questions" — add new ones, remove answered ones
- Update "What's working well" if I expressed a preference or positive reaction
- Review "Parking lot" — prune items that meet any of these criteria:
  - **Done:** already built or merged
  - **Irrelevant:** no longer fits the project's direction
  - **Superseded:** replaced by a different approach or decision
  - **Stale:** 5+ sessions with no interest or discussion
  Add new ideas that came up. The goal is a short, relevant list.
- Write 2-3 specific, actionable items in "Next session" based on where we left off
- Update the `<!-- Last updated: YYYY-MM-DD -->` comment at the top to today's date

**2. `.scaffold/roadmap.md`** (always update)
- Move completed items to "Done" — an item is done when it is merged and working.
  Features with known bugs stay in "In progress" until the bugs are resolved.
- Update "In progress" to reflect what's actively being worked on
- Adjust "Up next" and "Later" if priorities shifted
- Update "Current phase" if the nature of the work has changed
- Update the `<!-- Last updated: YYYY-MM-DD -->` comment at the top to today's date

**3. `.scaffold/decisions.md`** (update only if we made meaningful choices)
- Add an entry under the appropriate category (Tech, Architecture, Design, Scope)
  for any decision made this session
- Use today's date
- Include context and reasoning even if informal
- Skip trivial decisions (variable names, minor styling, etc.)
- If we reversed or reconsidered a previous decision, update its status and move
  the entry to Archived
- If 20+ active entries: suggest archiving older stable ones, but keep any decision
  still referenced by active roadmap items or open questions
- If updated, update the `<!-- Last updated: YYYY-MM-DD -->` comment at the top to today's date

**4. `.scaffold/project.md`** (update only if vision/scope evolved)
- Update "What is this?" if our understanding of the project sharpened
- Update "Scope boundaries" if we decided to include or exclude something
- Update "What does success look like?" if the goal shifted
- Skip if nothing changed about the vision
- If updated, update the `<!-- Last updated: YYYY-MM-DD -->` comment at the top to today's date

**5. CLAUDE.md** (update only if structural things changed)
- Update "Tech stack" if we added or changed technologies
- Update "Hard constraints" if new constraints emerged
- Skip if nothing structural changed

**Review before committing:**
- Re-read all updated files. Flag any contradictions between them.
- For each file updated, show the specific changes:
  - What was added
  - What was removed
  - What was reworded
- Present the changes and ask: "These are the checkpoint changes. Anything to adjust before I commit?"
- Wait for confirmation before proceeding to git commit
- If the user requests changes, make them and show the updated diff
- Only commit after explicit approval

**After approval:**
- If git is initialized: `git add CLAUDE.md .scaffold/*.md && git commit -m "checkpoint: [brief summary of session]"`
  If the commit fails, show the error and stop. Don't retry automatically.
- List any open questions or loose threads heading into next session.

**Enhanced mode (`/scaffold:checkpoint --audit`):**

If "--audit" appears in the arguments, after the standard checkpoint completes
(including user approval and git commit), launch an Explore subagent
(thoroughness: "very thorough") to verify scaffold claims against the codebase:

1. **Done items** — Do completed roadmap items actually exist in the code?
   Look for the features, routes, components, or functions they describe.
2. **In progress items** — Do they have recent changes or uncommitted work?
3. **What's not working** — Can you find evidence of these bugs or issues
   in the code (error handling gaps, TODOs, failing patterns)?
4. **Tech stack** — Does CLAUDE.md's tech stack match actual dependencies
   in manifest files?
5. **Decisions** — Do active decisions in .scaffold/decisions.md match what
   the code actually does? (e.g., decision says "using Redis" but no Redis
   client in dependencies)

Report discrepancies: "Audit found N issues:" followed by specifics.
Do NOT modify scaffold files — report only, let the user decide what to fix.

If the subagent fails or times out, the checkpoint already committed. Note
the audit failure and move on.
