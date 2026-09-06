# Backlog files + the development protocol

**Written:** 2026-09-06 · branch `master` · after `d43adce`
**For:** two things landed together and this records both. (1) The **development protocol** — the standing control Adam asked for so the purpose-first reduction never has to be repeated: north star sentence, spec-first, a cut pass over the diff, review that may only find duplication / needless rules / contradictions, and hard word limits. Lives in `CLAUDE.md` → *Development protocol*, with `scripts/words.sh` as its one mechanical check. (2) The **backlog-file feature**, ruled 2026-09-05 (`wip/20260905-1-plan-set-coherence.md` → *Pass 3*) and never built — used here as the protocol's first run.

## The protocol, in Adam's terms

The unit of maintenance is **the change, never the repo.** Every change: say in one sentence what it makes a skill do and name its twin; write the spec first; before committing, delete every added paragraph that would not change what an agent does in a real case; run `scripts/words.sh` and put its net line in the commit; review may ask only *what is said twice, what rules on a case that needs no rule, what contradicts* — never *what is missing*, because that question built the 26,000 words. Hard limits: a skill body under 3,000 words, a reference file under 1,000, no shape paraphrase in a skill that edits an existing doc, no catch-all sections. Whole-repo sweeps are not part of the protocol; if one is ever needed again the protocol has failed and that is the finding.

## The feature

**North star:** a backlog item is a file with four fixed sections, indexed by one `roadmap.md` line; twin: `investigations/` (a small contract, one folder, listed not read).

- `contracts/backlog.md` (new, 304 words; twin 221): `backlog/<slug>.md`, `type: backlog`, sections `## What` / `## Trigger` / `## Shape` / `## Not doing`, literal `Unknown.` for a section not yet known, shape-and-pointers only, leaves by deletion with its line.
- `contracts/roadmap.md`: `## Backlog` is an index — `- [ ] <slug> — <one line> → backlog/<slug>.md`; line and file always added and removed together. **Replaced rule (decision):** "One line, hard" → one index line per item with the detail in the file. The anti-bloat intent survives; the detail now has a computable home instead of being compressed away.
- `ARCHITECTURE.md`: layer row, tree entry, the argument paragraph (why every item gets a file; why the file holds shape and points), routing row, ownership row (`plan` primary C/D; `checkpoint` D on ship; `audit` R; `cleanup` C on migration), cleanup playbook clause.
- Skills: `plan` authors line + file (carries the template — it authors from nothing) and deletes both on promotion; `checkpoint` deletes both on ship; `audit` inventories `backlog/` and flags a fired `## Trigger` for promotion; `setup` creates `backlog/` and carries the index-line template; `cleanup` gains `references/backlog-files.md` (129 words) and a target invariant; `update` gains one old-layout marker (a `## Backlog` line without a `→ backlog/` pointer); `integrate` one word.
- No `schema_version` bump — same precedent as `glossary.md`: the marker lives in `update` Step 3.

## Protocol run on this change

Move 3 (cut pass) trimmed the new contract 333 → 302 words and one plan clause. Move 4 (one fresh reviewer, three questions only) found: `checkpoint` 5f still authored a bare `## Backlog` line — a broken pair — fixed by making the pair explicit there and naming `checkpoint` a creator in the contract and ownership row; the spec's Document Types table lacked a `backlog` row — added; `roadmap-split.md` and `backlog-files.md` disagreed on where old detail goes — `## What` only, the split playbook no longer says otherwise; leftover bare-line routing in `contracts/milestone.md` and `contracts/state.md` — repointed; duplicated anti-patterns in the two contracts — merged. No "what is missing" question was asked. `scripts/words.sh`: **33,604 → 34,533 (+929)**; every skill body under 3,000 (largest: `checkpoint` 2,796), every reference under 1,000.

## Not verified

- Real use. No project has run `/scaffold-plan` against the new routing; clarifi's `roadmap.md` will read as old-layout on the next `/scaffold-update` and route to `/scaffold-cleanup` → `backlog-files.md`, which is the intended path.
- Whether `Unknown.` survives in practice or every migrated item ends up with three `Unknown.` sections forever. `audit` has no rule against a stale `Unknown.`; deliberately — a rule was not added for a case that has not occurred.

## Open for Adam (carried)

1. `go` freshness exemption — "any" vs "solely" a `checkpoint:` commit (spec first).
2. Q3 from the reduction — a deduplication pass over `ARCHITECTURE.md` (now 10,235 words). Under the new protocol this would be a one-off; it is the last whole-file sweep on the table.
