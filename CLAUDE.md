# Scaffold — development repo

**This repo is the factory, not the product.** Its only purpose is to *produce* the
scaffold skills — self-contained artifacts that users download and apply to their own
coding repos. Nothing in this repo ships except the skills.

Two consequences, and they override any instinct to the contrary:

1. **Don't treat this repo's structure as sacred.** `ARCHITECTURE.md`, `contracts/`,
   the self-check — all of it is factory equipment. Users never see it. Optimize
   everything here for one thing: building good skills. If a different structure builds
   better skills, change the structure.
2. **This repo is not itself a scaffold-managed project.** Don't expect (or create) the
   living docs scaffold maintains in a *user's* repo. The thing under development here is
   the system; the system is not applied to its own factory.

## The product (what ships)

Scaffold is a context-persistence system for Claude Code: a family of skills that
maintain a small set of living docs in a user's repo so work survives across sessions.

**The essence — hold this while editing anything here.** The product is a *deterministic
state machine, and its data is the document structure itself.* Skills compute state by
reading sections off disk (`## Next` = what's active, the `milestone.md` checkbox = what's
done, a plan's `## Scope` = what to build). The whole thing works only because **every
piece of information has exactly one *computable* home.** The corollary is a hard
guardrail on every change you make: **never add an open-ended or catch-all section.** A
soft bucket is a non-deterministic home — ambiguous data piles up there, the docs bloat,
and the machine starts misreading its own state. A new kind of datum earns a section with
a membership rule a skill can apply, or it routes to an existing home — never a dumping
ground. (Full statement: `ARCHITECTURE.md` → Design Principles.)
Skills are named in a flat, hyphenated family — **`/scaffold-[skill]`** (e.g.
`/scaffold-status`, `/scaffold-checkpoint`, `/scaffold-audit`). A skill is a folder
(`SKILL.md`, plus its own `references/`/`scripts/` only when that skill is big enough to
warrant splitting — a per-skill pragmatic call). Whatever a skill needs to do its job is
written *into the skill*. Skills carry format guidance as an inline paraphrase of the
contracts — **except `/scaffold-audit`, which bundles verbatim contract copies in its
`references/`** because it grades against the exact contract. That is the one place a
contract ships inside a skill; the copies are generated from `contracts/` by
`scripts/sync-contracts.sh`, never hand-edited.

## The factory (this repo)

The **spec** is `ARCHITECTURE.md` + `contracts/`. We build the skills from it.

- `ARCHITECTURE.md` — the whole-system design: the two Laws, the bands
  (truth/history/execution), routing, and how the skills fit together. The single
  coherent view that **no individual skill holds** (each skill knows only its slice).
  This is why it earns its place and never becomes a double-up. Doesn't ship.
- `contracts/` — the per-document-type format specs, the **master** of each format. We
  author skills *from* them. For most skills the connection is "we read it while building
  the skill" — the skill ships an inline paraphrase, not the contract. **`/scaffold-audit`
  is the exception:** it grades against the exact contract, so `scripts/sync-contracts.sh`
  copies all contracts verbatim into `skills/scaffold-audit/references/` (regenerated from
  here, drift-guarded by `--check`). A contract earns its place when a format is needed by
  more than one skill (or by audit); a format used by a single skill just lives in that
  skill.
- `skills/` — the skill sources that ship as `/scaffold-[skill]`, one folder each, derived
  from the spec. This is the only thing that ships.

**Direction is one-way: the spec is the source; skills are derived from it.** Change the
design in the spec, then propagate to the skills — never hack a skill and let the spec
rot into stale parallel notes. `/scaffold-audit` is the backstop that catches drift.

## Development protocol

Every change to this repo runs the same four moves. **The change is the unit** — the whole repo is never re-swept; that is what this protocol exists to make unnecessary.

1. **North star first, one sentence.** Before editing, write what the change makes a skill *do*, in one sentence, and name its nearest existing twin — a new doc type costs what `investigations/` costs, a new section costs what `## Targets` costs. A change that cannot be said in a sentence is two changes, or is not yet understood.
2. **Spec first, then propagate.** `ARCHITECTURE.md` carries the argument, once. A contract carries the gradeable rule and any verbatim string a check greps for. A skill carries the imperative, with one clause of *why* only where the rule is counter-intuitive enough that an agent would otherwise reason around it. Nothing lands in a skill that the spec does not state.
3. **Cut pass over the diff, before commit.** Every added paragraph answers one question: *if deleted, would the agent do something different in a case that actually occurs?* No → delete. It is the reason → `ARCHITECTURE.md`, once. Rare path → `references/`. A new case earns a clause only when the existing escape — surface it at the confirmation seam and ask — does not cover it; an enumerated branch per edge case is the bloat pattern. Then run `scripts/words.sh` and put its net line in the commit message; a skill body that grew states why.
4. **Review finds contradictions and removals, never gaps.** No lens on this repo asks *what does this fail to say?* — that loop built 26,000 words. The allowed questions: what is said twice, what rules on a case that needs no rule, what contradicts the spec. When existing text was cut, one fresh agent walks the pre-cut text and reports each behaviour kept / moved / weakened / dropped; it may not propose additions. Every dropped behaviour is a named decision in the commit or handoff.

**Hard limits on the result.** A skill body stays under 3,000 words and a reference file under 1,000; over the line, something is cut before the commit. A skill that edits an existing doc never paraphrases that doc's shape — the shape is on disk and audit grades it; only a skill that authors a doc from nothing carries its template. No open-ended or catch-all section, anywhere.

## Active work

**Backlog files + development protocol landed 2026-09-06** — handoff `wip/20260906-4-backlog-files-and-dev-protocol.md`. The purpose-first reduction (`wip/20260905-3-…`) is complete and closure-verified. All nine `/scaffold-[skill]` skills ship from `skills/`; `ARCHITECTURE.md` + `contracts/` are the authority.
