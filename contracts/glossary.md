---
schema_version: 2
---

# Contract — `.scaffold/glossary.md`

**Purpose.** The project's anchor terms: the small set of words that must mean exactly one thing here, each with its canonical form named and its rivals retired. A ruling on what things are called — not a dictionary of the domain.

**Band.** Living truth — one of it, always current, overwritten in place.

**Owner(s).** Created **empty** by `scaffold-setup` (and by `scaffold-cleanup` when migrating a scaffold that predates it). Read by `scaffold-status` (every session), `scaffold-plan`, and `scaffold-go`. Entries are **proposed** by `scaffold-checkpoint` on a naming collision and written only on Adam's approval. Graded by `scaffold-audit`.

**Optional by construction.** Unlike the four mandatory truth docs, an absent or term-less `glossary.md` is **not** a conformance finding — it is the correct state for a project with no anchor terms yet, exactly as an empty `knowledge/` is.

## Required frontmatter

```yaml
---
type: glossary
schema_version: 2
updated: YYYY-MM-DD
---
```

## Required structure

```markdown
# Glossary

### <Canonical term>
[Definition — one or two lines. Precise enough that two readers cannot take it differently.]

**Not:** [the thing it is most easily mistaken for]

**Also called:** [rival forms, and where each appears] → use **<Canonical term>**.
```

Terms are `###` headings, **alphabetical**, and carry no other structure. `**Not:**` and `**Also called:**` are each optional and appear only when there is a real confusion to kill or a real rival to retire. An empty glossary is the `# Glossary` heading plus at most one bracketed placeholder line — the convention every doc `scaffold-setup` writes uses; it is deleted when the first term lands.

## The admission bar (applied BEFORE anything is written)

A word is not a term. An entry is admitted only if it clears **at least one** gate:

1. **Collision** — the same concept is being called more than one thing, or the same word is being used for more than one thing. This is the highest-value gate, because a collision is invisible to anyone who only reads one surface.
2. **Load-bearing and non-obvious** — the term names something central to how the product works, *and* its meaning here is narrower than, or different from, its ordinary meaning.
3. **Boundary** — it marks a distinction that is easy to blur and expensive to blur.

Clears none → it is a word, not a term, and it gets no line.

**Additions and definition changes are Adam-gated** — the same hard gate `decisions/` carries, for the same reason: a definition is cheap to write and expensive to be wrong about, and a silently reworded definition is more dangerous than a new term, because nothing signals that it moved. **Removal is ungated.** The friction belongs on the way in.

## Rules

- **Every entry rules.** Name the canonical form and retire the rivals. Recording that two words exist accomplishes nothing; choosing one is the entire point. An entry that lists alternatives without naming a winner is not an entry.
- **Alphabetical, flat, no grouping.** Ordering is mechanical so insertion needs no judgment, and a taxonomy is a structure nobody maintains.
- **Define, don't describe.** A definition states what the thing *is*, in a form that can be checked against usage. Why the concept matters belongs elsewhere.
- **Point at nothing.** A glossary defines a word; `knowledge/` states an invariant and points at the code enforcing it. Keeping the two distinct keeps both short.
- **Short by construction.** A long glossary is an admission failure, not a thorough one. Read length as a signal about the bar.

## Exclusions (route these elsewhere)

- **A word whose ordinary meaning is already correct** — do not define "invoice" if it means invoice.
- **A value, constant, enum, or field name with a single code home** — the code owns it; a copy here drifts (the same rule `knowledge/` applies). This excludes it as a *defined term*, not as a *named rival*: a schema identifier may appear in an `**Also called:**` line, since retiring it in favour of the canonical word is the point.
- **A rule about behavior** → `knowledge/`. A term says what a thing is called; an invariant says what must always hold.
- **A fact about how it's built** → `architecture.md`.

## Anti-patterns

- **A dictionary** — terms admitted for appearing often rather than for clearing a gate.
- **An entry that lists alternatives without ruling on which to use.**
- **A definition that restates the code** (a threshold, an enum's members) — it belongs in code and the copy will drift.
- **A definition edited without Adam's approval** (edits are gated, like additions).
- **Grouped or thematically ordered terms** — ordering is alphabetical.
- **An entry grown into prose** — an explanation, a rationale, a history. Trim it back to the ruling.
- **Dated entries / an append-log** (Law 1).
