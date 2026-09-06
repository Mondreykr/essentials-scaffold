# Backlog lines → files

Applies when `roadmap.md` `## Backlog` has any `- [ ]` line without a `→ backlog/<slug>.md` pointer.

For each bare line, after the admission bar in `roadmap-split.md` has run: derive a slug from the line; create `backlog/<slug>.md` with `type: backlog`, `# <Title>`, and the four sections `## What` / `## Trigger` / `## Shape` / `## Not doing`. `## What` is the line's own text (plus any paragraph detail the old line carried); the other three are whatever Adam supplies when you present the list, else exactly `Unknown.`. Rewrite the line to `- [ ] <slug> — <one line> → backlog/<slug>.md`; line and file land in the same pass.
