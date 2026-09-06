# Stand up `architecture.md`

Applies when `architecture.md` is absent or thin. Sort durable technical truth out of where it hides — architectural content in `decisions.md`, run/env facts in `state.md`, the real code.

**Tiebreak per fact:** changes on re-platform (business rule stays) → `architecture.md`; changes only when the business rule changes → `knowledge/` — not cleanup's to write; flag it for a later `integrate` / `plan` (the sole exception is the graduation pass in `archive-closed.md`).

Sections: `# Architecture` / `## Stack` / `## Tenancy / isolation` / `## Auth` / `## Data access` / `## Deployment` / `## Conventions` / `## Run / env`. Frontmatter `type: architecture`. No `## Decisions` section — each truth statement cites its ADR inline (`[[NNNN-…]]`); the `decisions/` folder plus those citations are the index. Write the truth statements now; wire the citations during decisions curation, once the ADRs are numbered.
