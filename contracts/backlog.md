---
schema_version: 2
---

# Contract — `backlog/<slug>.md`

**Purpose.** One future item not tied to the active milestone: what it is, what makes it
real, its rough shape, and its no-gos. The body behind one `roadmap.md` `## Backlog` line.

**Band.** Living truth — rewritten in place while the item waits.

**Owner(s).** Created by `scaffold-plan` and `scaffold-checkpoint`, always with its index
line; deleted by `scaffold-plan` on promotion and `scaffold-checkpoint` on ship.
Reality-checked by `scaffold-audit`. Created from bare backlog lines on migration by
`scaffold-cleanup`.

## Required frontmatter

```yaml
---
type: backlog
schema_version: 2
updated: YYYY-MM-DD
---
```

## Required structure

```markdown
# <Title>

## What
<what the item is, one paragraph>

## Trigger
<what makes this real — a demand, a metric, a dependency landing; "demand, not a date" is a valid trigger>

## Shape
<rough scope and known traps, one paragraph; points at knowledge/ and decisions/ rather than restating them>

## Not doing
<explicit no-gos, one line each>
```

## Rules

- Filename is `<slug>.md`, the same slug as its index line; one line ↔ one file.
- Every section is present. A section not yet known reads exactly `Unknown.` — never
  omitted, never guessed.
- One paragraph per section (`## Not doing` is one line per no-go).
- The file holds *shape* and *points*: a durable rule routes to `knowledge/`, a choice with
  alternatives to `decisions/`, and this file cites them.
- Leaves by deletion, with its index line, when promoted or shipped.

## Anti-patterns

- A rule stated here instead of in `knowledge/`; a decision argued here instead of an ADR.
- A build plan (scope items, acceptance) — that is a phase plan.
- A missing section, or a blank one instead of `Unknown.`.
- A file with no index line, or kept after the item was promoted or shipped.
