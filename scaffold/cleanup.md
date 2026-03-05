---
description: Migrate scaffold files to current format
---

**Precondition:** Verify that `.scaffold/` directory exists with at least
`state.md` and `roadmap.md`. If not, stop and say:
"No scaffold files found — run /scaffold:setup first."

This command migrates existing scaffold files to the current format. It handles
both the old flat-section format and any intermediate formats.

---

## Step 1: Read All Existing Files

Read all scaffold files and CLAUDE.md:
- `.scaffold/state.md`
- `.scaffold/roadmap.md`
- `.scaffold/project.md`
- `.scaffold/decisions.md`
- `CLAUDE.md`

---

## Step 1.5: Scratch Migration

Check if `.scaffold/scratch/` exists:

1. If it does, read each file in the directory
2. Present each file: "Found `.scaffold/scratch/[filename]` — [one-line summary of contents]"
3. Propose migration: move files to `.scaffold/investigations/`, rename to match
   `YYYYMMDD-NN-slug.md` convention (date without dashes, zero-padded counter, brief slug)
4. For each file, propose the new name based on content and creation date
5. Wait for user approval
6. Create `.scaffold/investigations/` if needed and move files with new names
7. Remove the empty `.scaffold/scratch/` directory

If `.scaffold/scratch/` does not exist, skip this step.

---

## Step 2: Identify Format Differences

Check each file against the current format:

**roadmap.md — check for:**
- Old flat sections: "Done", "In progress", "Up next", "Later", "Current phase"
- Old checkbox convention: `- v Item` (should be `- [x] Item`)
- Old in-progress convention: `- >> Item` (should be `- [ ] >> Item`)
- Missing phase grouping (should be `## Phase N — Title [STATUS]`)
- Missing `Backlog` section

**state.md — check for:**
- Old sections: "What's not working", "What's working well", "Parking lot",
  "Next session"
- Missing new sections: "Status", "Current Position", "Next Action",
  "Blockers", "Key Documents"

**CLAUDE.md — check for:**
- Missing "Session Protocol" table
- Missing "Command Reference" table
- Missing "Core Principle" section
- Missing "Key Documents" section
- Missing `execute` and `cleanup` command references
- Old session protocol missing "execute" row

---

## Step 3: Propose Restructured Content

For each file that needs changes, build the new content by mapping old → new:

**roadmap.md migration:**
- "Current phase" text → becomes the title of the `[IN PROGRESS]` phase
- "Done" items → become `[x]` tasks in completed phases or Phase 1
  - If items suggest natural phase boundaries, group into separate phases
  - Otherwise, group all into "Phase 1 — [inferred title] [COMPLETE]"
- "In progress" items → become `[ ] >>` tasks in the `[IN PROGRESS]` phase
- "Up next" items → become `[ ]` tasks in the `[IN PROGRESS]` or next `[PLANNED]` phase
- "Later" items → move to `Backlog`
- Old `- v Item` → `- [x] Item`
- Old `- >> Item` → `- [ ] >> Item`

**state.md migration:**
- "What's not working" → "Blockers"
- "Open questions" → "Open Questions" (unchanged)
- "What's working well" → Drop (preferences route to CLAUDE.md)
- "Parking lot" / "Future Ideas" → move to roadmap.md Backlog
- "Next session" → "Next Action" (rewrite as action pointer, not vague intentions)
- Add "Status" section (infer from current state: idle / executing / blocked)
- Add "Current Position" section (synthesize from existing content)
- Add "Key Documents" section

**CLAUDE.md migration:**
- Add Session Protocol table if missing (with "execute" row)
- Add Command Reference table if missing (with execute, cleanup)
- Add Core Principle text if missing
- Add Key Documents section if missing
- Update existing tables to include new commands

---

## Step 4: Present Changes for Review

For EACH file that needs changes, show before/after:

```
### [filename]

**Current format issues:** [list what's wrong]

**Proposed new content:**
[full new content]
```

Present ALL proposed changes at once so the user can review holistically.

**Wait for explicit approval before writing any changes.**

If the user wants modifications, incorporate them and re-present.

---

## Step 5: Write Approved Changes

Write all approved changes to their respective files.

---

## Step 6: Commit

If git is initialized:
`git add CLAUDE.md .scaffold/ && git commit -m "scaffold: migrate to v2 format"`

Show a summary of what was migrated.
