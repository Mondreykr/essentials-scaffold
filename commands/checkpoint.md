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
