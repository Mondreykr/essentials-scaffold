# Archive closed milestones retroactively

Applies to each milestone `roadmap.md` marks `[done]` that still sits in `milestones/`. For each:

1. **Graduation pass first — Adam-gated.** The move is the last legal read of that spec: nothing walks `archived/` for rules again, and a rule missed here is unrecoverable. Read its `spec/references/` (or its accrued rules) and account for every rule: it graduates to `knowledge/`, it has a code home that enforces it (name the file), or it died with the milestone. Surface the full set before writing any of it.
2. **Check `## Next`.** If it resolves inside this folder, do not follow it to the archived path — repoint it at the next live milestone, or write "no active phase; run `/scaffold-plan`."
3. **Move whole, unrenamed:** `git mv .scaffold/milestones/NN-slug .scaffold/milestones/archived/NN-slug`; create `archived/` on the first. Check the destination does not already exist (re-runs; a plain `mv` would nest `archived/NN-slug/NN-slug/`).
4. **Stamp `archived: YYYY-MM-DD`** in that folder's `milestone.md` only, below `updated:`. Date: when the roadmap line flipped to `[done]` (`git log -S"[done] NN-slug" -- .scaffold/roadmap.md`), else the file's last commit date.
5. **Repoint** the roadmap line to `milestones/archived/NN-slug/` and any other `.scaffold/` reference in the rename map.

Report each move with old and new paths — references outside `.scaffold/` break on it and are not swept. Contents are never edited after the move.
