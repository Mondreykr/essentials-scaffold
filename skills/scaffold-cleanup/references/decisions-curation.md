# Curate decisions — promote the few

Applies when a monolithic `decisions.md` exists. Decisions are curated, not split: most legacy entries are build-records below the ADR bar (a rare, architecturally significant, cross-cutting choice whose *why* you would want in a year).

- An existing `decisions/NNNN-slug.md` folder → already-promoted ADRs; leave them, renumber nothing, continue after the existing numbers.
- A grandfathered spec's own decisions file → never cracked open.

Classify each entry and present grouped:
> "## Decision curation — N entries in `decisions.md`
> **Proposed ADRs:** 1. [date — title] → `decisions/NNNN-slug.md` — [why it qualifies]
> **Retire to git:** [date — title], …
> No ADR is written without your approval. Which do you confirm?"

**STOP. Wait for explicit approval.** For each approved ADR write `decisions/NNNN-slug.md`: `type: decision`; `# NNNN — <title>`; `**Status:** Accepted`; Context / Decision / Why / Alternatives considered / Consequences. 4-digit, zero-padded, sequential. The rest retire with the deleted `decisions.md` (no git → fold each as a one-line "retired" note rather than losing it). Cite each architectural ADR from `architecture.md` in the same pass.
